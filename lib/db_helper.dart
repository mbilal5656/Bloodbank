import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseHelper {
  static const String _usersKey = 'users';
  static const String _nextIdKey = 'next_user_id';

  // Initialize database with default admin user
  static Future<void> initializeDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);

    if (usersJson == null) {
      // Create default admin user with specified credentials
      final adminUser = {
        'id': 1,
        'name': 'Admin',
        'email': 'mbilalpk56@gmail.com',
        'password': _hashPassword('1Q2w3e5R'),
        'userType': 'Admin',
        'bloodGroup': 'N/A',
        'age': 30,
        'contactNumber': 'N/A',
        'createdAt': DateTime.now().toIso8601String(),
      };

      final users = [adminUser];
      await prefs.setString(_usersKey, jsonEncode(users));
      await prefs.setInt(_nextIdKey, 2);
    }
  }

  // Hash password using simple base64 encoding (in production, use proper hashing)
  static String _hashPassword(String password) {
    return base64Encode(utf8.encode(password));
  }

  // Get all users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);

    if (usersJson != null) {
      final List<dynamic> decoded = jsonDecode(usersJson);
      return decoded.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Get user by email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final users = await getAllUsers();
    try {
      return users.firstWhere((user) => user['email'] == email);
    } catch (e) {
      return null;
    }
  }

  // Get user by ID
  Future<Map<String, dynamic>?> getUserById(int userId) async {
    final users = await getAllUsers();
    try {
      return users.firstWhere((user) => user['id'] == userId);
    } catch (e) {
      return null;
    }
  }

  // Authenticate user
  Future<bool> authenticateUser(String email, String password) async {
    final user = await getUserByEmail(email);
    if (user != null) {
      final hashedPassword = _hashPassword(password);
      return user['password'] == hashedPassword;
    }
    return false;
  }

  // Insert new user
  Future<bool> insertUser(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final users = await getAllUsers();

      // Get next user ID
      final nextId = prefs.getInt(_nextIdKey) ?? users.length + 1;

      // Hash password
      final hashedPassword = _hashPassword(userData['password']);

      // Create new user
      final newUser = {
        'id': nextId,
        'name': userData['name'],
        'email': userData['email'],
        'password': hashedPassword,
        'userType': userData['userType'],
        'bloodGroup': userData['bloodGroup'],
        'age': userData['age'],
        'contactNumber': userData['contactNumber'],
        'createdAt': DateTime.now().toIso8601String(),
      };

      users.add(newUser);

      // Save updated users list
      await prefs.setString(_usersKey, jsonEncode(users));
      await prefs.setInt(_nextIdKey, nextId + 1);

      return true;
    } catch (e) {
      // In production, use proper logging instead of print
      return false;
    }
  }

  // Update user
  Future<bool> updateUser(int userId, Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final users = await getAllUsers();

      final userIndex = users.indexWhere((user) => user['id'] == userId);
      if (userIndex != -1) {
        // Handle password update specifically
        if (userData.containsKey('password')) {
          users[userIndex]['password'] = _hashPassword(userData['password']);
        } else {
          users[userIndex].addAll(userData);
        }
        users[userIndex]['updatedAt'] = DateTime.now().toIso8601String();

        await prefs.setString(_usersKey, jsonEncode(users));
        return true;
      }
      return false;
    } catch (e) {
      // In production, use proper logging instead of print
      return false;
    }
  }

  // Delete user
  Future<bool> deleteUser(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final users = await getAllUsers();

      users.removeWhere((user) => user['id'] == userId);

      await prefs.setString(_usersKey, jsonEncode(users));
      return true;
    } catch (e) {
      // In production, use proper logging instead of print
      return false;
    }
  }

  // Get users by type
  Future<List<Map<String, dynamic>>> getUsersByType(String userType) async {
    final users = await getAllUsers();
    return users.where((user) => user['userType'] == userType).toList();
  }

  // Check if email exists
  Future<bool> emailExists(String email) async {
    final user = await getUserByEmail(email);
    return user != null;
  }

  // Change password
  Future<bool> changePassword(
    int userId,
    String oldPassword,
    String newPassword,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final users = await getAllUsers();

      final userIndex = users.indexWhere((user) => user['id'] == userId);
      if (userIndex == -1) return false;

      final user = users[userIndex];
      final oldHashedPassword = _hashPassword(oldPassword);

      // Verify old password
      if (user['password'] != oldHashedPassword) {
        return false;
      }

      // Update password
      users[userIndex]['password'] = _hashPassword(newPassword);
      users[userIndex]['updatedAt'] = DateTime.now().toIso8601String();

      await prefs.setString(_usersKey, jsonEncode(users));
      return true;
    } catch (e) {
      // In production, use proper logging instead of print
      return false;
    }
  }
}
