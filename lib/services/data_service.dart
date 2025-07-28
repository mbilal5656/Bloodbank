import 'package:flutter/foundation.dart';
import '../db_helper.dart';
import '../models/user_model.dart';
import '../models/blood_inventory_model.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  // ===== USER OPERATIONS =====

  // Get all users
  Future<List<UserModel>> getAllUsers() async {
    try {
      final users = await _dbHelper.getAllUsers();
      return users.map((user) => UserModel.fromMap(user)).toList();
    } catch (e) {
      debugPrint('Error getting all users: $e');
      return [];
    }
  }

  // Get user by email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final user = await _dbHelper.getUserByEmail(email);
      return user != null ? UserModel.fromMap(user) : null;
    } catch (e) {
      debugPrint('Error getting user by email: $e');
      return null;
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(int userId) async {
    try {
      final user = await _dbHelper.getUserById(userId);
      return user != null ? UserModel.fromMap(user) : null;
    } catch (e) {
      debugPrint('Error getting user by ID: $e');
      return null;
    }
  }

  // Authenticate user
  Future<bool> authenticateUser(String email, String password) async {
    try {
      return await _dbHelper.authenticateUser(email, password);
    } catch (e) {
      debugPrint('Error authenticating user: $e');
      return false;
    }
  }

  // Create new user
  Future<bool> createUser(UserModel user) async {
    try {
      return await _dbHelper.insertUser(user.toMap());
    } catch (e) {
      debugPrint('Error creating user: $e');
      return false;
    }
  }

  // Update user
  Future<bool> updateUser(int userId, Map<String, dynamic> data) async {
    try {
      return await _dbHelper.updateUser(userId, data);
    } catch (e) {
      debugPrint('Error updating user: $e');
      return false;
    }
  }

  // Delete user
  Future<bool> deleteUser(int userId) async {
    try {
      return await _dbHelper.deleteUser(userId);
    } catch (e) {
      debugPrint('Error deleting user: $e');
      return false;
    }
  }

  // Get users by type
  Future<List<UserModel>> getUsersByType(String userType) async {
    try {
      final users = await _dbHelper.getUsersByType(userType);
      return users.map((user) => UserModel.fromMap(user)).toList();
    } catch (e) {
      debugPrint('Error getting users by type: $e');
      return [];
    }
  }

  // Check if email exists
  Future<bool> emailExists(String email) async {
    try {
      return await _dbHelper.emailExists(email);
    } catch (e) {
      debugPrint('Error checking email existence: $e');
      return false;
    }
  }

  // Change password
  Future<bool> changePassword(
    int userId,
    String oldPassword,
    String newPassword,
  ) async {
    try {
      return await _dbHelper.changePassword(userId, oldPassword, newPassword);
    } catch (e) {
      debugPrint('Error changing password: $e');
      return false;
    }
  }

  // ===== BLOOD INVENTORY OPERATIONS =====

  // Get all blood inventory
  Future<List<BloodInventoryModel>> getAllBloodInventory() async {
    try {
      final inventory = await _dbHelper.getAllBloodInventory();
      return inventory
          .map((item) => BloodInventoryModel.fromMap(item))
          .toList();
    } catch (e) {
      debugPrint('Error getting all blood inventory: $e');
      return [];
    }
  }

  // Get blood inventory by group
  Future<BloodInventoryModel?> getBloodInventoryByGroup(
    String bloodGroup,
  ) async {
    try {
      final inventory = await _dbHelper.getBloodInventoryByGroup(bloodGroup);
      return inventory != null ? BloodInventoryModel.fromMap(inventory) : null;
    } catch (e) {
      debugPrint('Error getting blood inventory by group: $e');
      return null;
    }
  }

  // Update blood inventory
  Future<bool> updateBloodInventory(int id, Map<String, dynamic> data) async {
    try {
      return await _dbHelper.updateBloodInventory(id, data);
    } catch (e) {
      debugPrint('Error updating blood inventory: $e');
      return false;
    }
  }

  // Add blood inventory
  Future<bool> addBloodInventory(BloodInventoryModel inventory) async {
    try {
      return await _dbHelper.addBloodInventory(inventory.toMap());
    } catch (e) {
      debugPrint('Error adding blood inventory: $e');
      return false;
    }
  }

  // Delete blood inventory
  Future<bool> deleteBloodInventory(int id) async {
    try {
      return await _dbHelper.deleteBloodInventory(id);
    } catch (e) {
      debugPrint('Error deleting blood inventory: $e');
      return false;
    }
  }

  // Search blood inventory
  Future<List<BloodInventoryModel>> searchBloodInventory(String query) async {
    try {
      final inventory = await _dbHelper.searchBloodInventory(query);
      return inventory
          .map((item) => BloodInventoryModel.fromMap(item))
          .toList();
    } catch (e) {
      debugPrint('Error searching blood inventory: $e');
      return [];
    }
  }

  // Get blood inventory summary
  Future<Map<String, int>> getBloodInventorySummary() async {
    try {
      return await _dbHelper.getBloodInventorySummary();
    } catch (e) {
      debugPrint('Error getting blood inventory summary: $e');
      return {};
    }
  }

  // ===== DONATION OPERATIONS =====

  // Add donation
  Future<bool> addDonation(Map<String, dynamic> donationData) async {
    try {
      return await _dbHelper.addDonation(donationData);
    } catch (e) {
      debugPrint('Error adding donation: $e');
      return false;
    }
  }

  // Get donations by donor
  Future<List<Map<String, dynamic>>> getDonationsByDonor(int donorId) async {
    try {
      return await _dbHelper.getDonationsByDonor(donorId);
    } catch (e) {
      debugPrint('Error getting donations by donor: $e');
      return [];
    }
  }

  // ===== BLOOD REQUEST OPERATIONS =====

  // Add blood request
  Future<bool> addBloodRequest(Map<String, dynamic> requestData) async {
    try {
      return await _dbHelper.addBloodRequest(requestData);
    } catch (e) {
      debugPrint('Error adding blood request: $e');
      return false;
    }
  }

  // Get requests by requester
  Future<List<Map<String, dynamic>>> getRequestsByRequester(
    int requesterId,
  ) async {
    try {
      return await _dbHelper.getRequestsByRequester(requesterId);
    } catch (e) {
      debugPrint('Error getting requests by requester: $e');
      return [];
    }
  }

  // ===== NOTIFICATION OPERATIONS =====

  // Add notification
  Future<bool> addNotification(Map<String, dynamic> notificationData) async {
    try {
      return await _dbHelper.addNotification(notificationData);
    } catch (e) {
      debugPrint('Error adding notification: $e');
      return false;
    }
  }

  // Get notifications by user
  Future<List<Map<String, dynamic>>> getNotificationsByUser(int userId) async {
    try {
      return await _dbHelper.getNotificationsByUser(userId);
    } catch (e) {
      debugPrint('Error getting notifications by user: $e');
      return [];
    }
  }

  // Mark notification as read
  Future<bool> markNotificationAsRead(int notificationId) async {
    try {
      return await _dbHelper.markNotificationAsRead(notificationId);
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      return false;
    }
  }

  // ===== UTILITY METHODS =====

  // Initialize database
  static Future<void> initializeDatabase() async {
    try {
      debugPrint('Starting database initialization...');
      await DatabaseHelper.initializeDatabase();
      debugPrint('Database initialized successfully');
      
      // Test database by checking if admin user exists
      final dbHelper = DatabaseHelper();
      final adminUser = await dbHelper.getUserByEmail('admin@bloodbank.com');
      if (adminUser != null) {
        debugPrint('Admin user found: ${adminUser['name']} (ID: ${adminUser['id']})');
      } else {
        debugPrint('Admin user not found - checking all users...');
        final allUsers = await dbHelper.getAllUsers();
        debugPrint('Total users in database: ${allUsers.length}');
        for (final user in allUsers) {
          debugPrint('User: ${user['name']} (${user['email']}) - ID: ${user['id']}');
        }
      }
    } catch (e) {
      debugPrint('Error initializing database: $e');
      rethrow;
    }
  }

  // Close database
  Future<void> close() async {
    try {
      await _dbHelper.close();
      debugPrint('Database closed successfully');
    } catch (e) {
      debugPrint('Error closing database: $e');
    }
  }

  // Get database statistics
  Future<Map<String, dynamic>> getDatabaseStats() async {
    try {
      final users = await getAllUsers();
      final inventory = await getAllBloodInventory();

      return {
        'totalUsers': users.length,
        'totalInventory': inventory.length,
        'adminUsers': users.where((u) => u.isAdmin).length,
        'donorUsers': users.where((u) => u.isDonor).length,
        'receiverUsers': users.where((u) => u.isReceiver).length,
        'availableBloodGroups': inventory.where((i) => i.isAvailable).length,
        'lowStockGroups': inventory.where((i) => i.isLow).length,
        'criticalStockGroups': inventory.where((i) => i.isCritical).length,
      };
    } catch (e) {
      debugPrint('Error getting database stats: $e');
      return {};
    }
  }

  // Validate user data
  static bool validateUserData(Map<String, dynamic> userData) {
    try {
      final name = userData['name']?.toString() ?? '';
      final email = userData['email']?.toString() ?? '';
      final password = userData['password']?.toString() ?? '';
      final userType = userData['userType']?.toString() ?? '';

      if (name.isEmpty ||
          email.isEmpty ||
          password.isEmpty ||
          userType.isEmpty) {
        return false;
      }

      // Basic email validation
      if (!email.contains('@') || !email.contains('.')) {
        return false;
      }

      // Password length validation
      if (password.length < 6) {
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Error validating user data: $e');
      return false;
    }
  }

  // Validate blood inventory data
  static bool validateBloodInventoryData(Map<String, dynamic> inventoryData) {
    try {
      final bloodGroup = inventoryData['bloodGroup']?.toString() ?? '';
      final quantity = inventoryData['quantity'];

      if (bloodGroup.isEmpty) {
        return false;
      }

      if (quantity == null || quantity is! int || quantity < 0) {
        return false;
      }

      // Validate blood group format
      final validBloodGroups = [
        'A+',
        'A-',
        'B+',
        'B-',
        'AB+',
        'AB-',
        'O+',
        'O-',
      ];
      if (!validBloodGroups.contains(bloodGroup)) {
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Error validating blood inventory data: $e');
      return false;
    }
  }
}
