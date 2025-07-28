import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseHelper {
  static const String _usersKey = 'users';
  static const String _nextIdKey = 'next_user_id';
  static const String _bloodInventoryKey = 'blood_inventory';
  static const String _nextInventoryIdKey = 'next_inventory_id';

  // Initialize database with default admin user
  static Future<void> initializeDatabase() async {
    try {
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

      // Initialize blood inventory if not exists
      final inventoryJson = prefs.getString(_bloodInventoryKey);
      if (inventoryJson == null) {
        // Create default blood inventory
        final defaultInventory = [
          {
            'id': 1,
            'bloodGroup': 'A+',
            'quantity': 10,
            'lastUpdated': DateTime.now().toIso8601String(),
            'status': 'Available',
          },
          {
            'id': 2,
            'bloodGroup': 'A-',
            'quantity': 5,
            'lastUpdated': DateTime.now().toIso8601String(),
            'status': 'Available',
          },
          {
            'id': 3,
            'bloodGroup': 'B+',
            'quantity': 8,
            'lastUpdated': DateTime.now().toIso8601String(),
            'status': 'Available',
          },
          {
            'id': 4,
            'bloodGroup': 'B-',
            'quantity': 3,
            'lastUpdated': DateTime.now().toIso8601String(),
            'status': 'Available',
          },
          {
            'id': 5,
            'bloodGroup': 'AB+',
            'quantity': 4,
            'lastUpdated': DateTime.now().toIso8601String(),
            'status': 'Available',
          },
          {
            'id': 6,
            'bloodGroup': 'AB-',
            'quantity': 2,
            'lastUpdated': DateTime.now().toIso8601String(),
            'status': 'Available',
          },
          {
            'id': 7,
            'bloodGroup': 'O+',
            'quantity': 12,
            'lastUpdated': DateTime.now().toIso8601String(),
            'status': 'Available',
          },
          {
            'id': 8,
            'bloodGroup': 'O-',
            'quantity': 6,
            'lastUpdated': DateTime.now().toIso8601String(),
            'status': 'Available',
          },
        ];

        await prefs.setString(_bloodInventoryKey, jsonEncode(defaultInventory));
        await prefs.setInt(_nextInventoryIdKey, 9);
      }
    } catch (e) {
      // Handle initialization errors gracefully
      print('Database initialization error: $e');
      // Re-throw to allow the app to handle it
      rethrow;
    }
  }

  // Hash password using simple base64 encoding (in production, use proper hashing)
  static String _hashPassword(String password) {
    try {
      return base64Encode(utf8.encode(password));
    } catch (e) {
      // Fallback to simple encoding if base64 fails
      return password;
    }
  }

  // Get all users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);

      if (usersJson != null) {
        final List<dynamic> decoded = jsonDecode(usersJson);
        return decoded.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    }
  }

  // Get user by email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final users = await getAllUsers();
      return users.firstWhere((user) => user['email'] == email);
    } catch (e) {
      return null;
    }
  }

  // Get user by ID
  Future<Map<String, dynamic>?> getUserById(int userId) async {
    try {
      final users = await getAllUsers();
      return users.firstWhere((user) => user['id'] == userId);
    } catch (e) {
      return null;
    }
  }

  // Authenticate user
  Future<bool> authenticateUser(String email, String password) async {
    try {
      final user = await getUserByEmail(email);
      if (user != null) {
        final hashedPassword = _hashPassword(password);
        return user['password'] == hashedPassword;
      }
      return false;
    } catch (e) {
      print('Authentication error: $e');
      return false;
    }
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
      print('Error inserting user: $e');
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

        // Save updated users list
        await prefs.setString(_usersKey, jsonEncode(users));
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  // Delete user
  Future<bool> deleteUser(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final users = await getAllUsers();

      final userIndex = users.indexWhere((user) => user['id'] == userId);
      if (userIndex != -1) {
        users.removeAt(userIndex);

        // Save updated users list
        await prefs.setString(_usersKey, jsonEncode(users));
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  // Get all blood inventory
  Future<List<Map<String, dynamic>>> getAllBloodInventory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final inventoryJson = prefs.getString(_bloodInventoryKey);

      if (inventoryJson != null) {
        final List<dynamic> decoded = jsonDecode(inventoryJson);
        return decoded.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error getting blood inventory: $e');
      return [];
    }
  }

  // Get blood inventory by group
  Future<Map<String, dynamic>?> getBloodInventoryByGroup(
    String bloodGroup,
  ) async {
    try {
      final inventory = await getAllBloodInventory();
      return inventory.firstWhere((item) => item['bloodGroup'] == bloodGroup);
    } catch (e) {
      return null;
    }
  }

  // Update blood inventory
  Future<bool> updateBloodInventory(int id, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final inventory = await getAllBloodInventory();

      final itemIndex = inventory.indexWhere((item) => item['id'] == id);
      if (itemIndex != -1) {
        inventory[itemIndex].addAll(data);
        inventory[itemIndex]['lastUpdated'] = DateTime.now().toIso8601String();

        await prefs.setString(_bloodInventoryKey, jsonEncode(inventory));
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating blood inventory: $e');
      return false;
    }
  }

  // Add new blood inventory item
  Future<bool> addBloodInventory(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final inventory = await getAllBloodInventory();

      final nextId = prefs.getInt(_nextInventoryIdKey) ?? inventory.length + 1;

      final newItem = {
        'id': nextId,
        'bloodGroup': data['bloodGroup'],
        'quantity': data['quantity'],
        'lastUpdated': DateTime.now().toIso8601String(),
        'status': data['status'] ?? 'Available',
      };

      inventory.add(newItem);

      await prefs.setString(_bloodInventoryKey, jsonEncode(inventory));
      await prefs.setInt(_nextInventoryIdKey, nextId + 1);

      return true;
    } catch (e) {
      print('Error adding blood inventory: $e');
      return false;
    }
  }

  // Delete blood inventory item
  Future<bool> deleteBloodInventory(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final inventory = await getAllBloodInventory();

      final itemIndex = inventory.indexWhere((item) => item['id'] == id);
      if (itemIndex != -1) {
        inventory.removeAt(itemIndex);

        await prefs.setString(_bloodInventoryKey, jsonEncode(inventory));
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting blood inventory: $e');
      return false;
    }
  }

  // Search blood inventory
  Future<List<Map<String, dynamic>>> searchBloodInventory(String query) async {
    try {
      final inventory = await getAllBloodInventory();
      return inventory.where((item) {
        final bloodGroup = item['bloodGroup'].toString().toLowerCase();
        final status = item['status'].toString().toLowerCase();
        final queryLower = query.toLowerCase();

        return bloodGroup.contains(queryLower) || status.contains(queryLower);
      }).toList();
    } catch (e) {
      print('Error searching blood inventory: $e');
      return [];
    }
  }

  // Get blood inventory summary
  Future<Map<String, int>> getBloodInventorySummary() async {
    try {
      final inventory = await getAllBloodInventory();
      final summary = <String, int>{};
      
      for (final item in inventory) {
        final bloodGroup = item['bloodGroup'] as String;
        final quantity = item['quantity'] as int;
        summary[bloodGroup] = quantity;
      }
      
      return summary;
    } catch (e) {
      print('Error getting blood inventory summary: $e');
      return {};
    }
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

      await prefs.setString(_usersKey, jsonEncode(users));
      return true;
    } catch (e) {
      print('Error changing password: $e');
      return false;
    }
  }

  // Get users by type
  Future<List<Map<String, dynamic>>> getUsersByType(String userType) async {
    try {
      final users = await getAllUsers();
      return users.where((user) => user['userType'] == userType).toList();
    } catch (e) {
      print('Error getting users by type: $e');
      return [];
    }
  }

  // Check if email exists
  Future<bool> emailExists(String email) async {
    try {
      final user = await getUserByEmail(email);
      return user != null;
    } catch (e) {
      print('Error checking email existence: $e');
      return false;
    }
  }
}
