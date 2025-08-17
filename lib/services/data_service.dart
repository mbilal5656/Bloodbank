import 'package:flutter/foundation.dart';
import '../db_helper.dart';
import 'web_database_service.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Initialize database
  static Future<void> initializeDatabase() async {
    try {
      if (kIsWeb) {
        debugPrint(
          'DataService: Web platform - initializing in-memory database',
        );
        await WebDatabaseService.initialize();
        debugPrint('DataService: Web database initialized successfully');
      } else {
        debugPrint('DataService: Mobile platform - initializing SQLite');
        await DatabaseHelper.initializeDatabase();
        debugPrint('DataService: SQLite database initialized successfully');
      }
    } catch (e) {
      debugPrint('DataService: Error initializing database: $e');
      rethrow;
    }
  }

  // ===== USER OPERATIONS =====

  // Get all users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      if (kIsWeb) {
        return await WebDatabaseService.getAllUsers();
      } else {
        return await _dbHelper.getAllUsers();
      }
    } catch (e) {
      debugPrint('DataService: Error getting all users: $e');
      return [];
    }
  }

  // Get all users including inactive
  Future<List<Map<String, dynamic>>> getAllUsersIncludingInactive() async {
    try {
      if (kIsWeb) {
        debugPrint(
          'DataService: Web platform - using WebDatabaseService for getAllUsersIncludingInactive',
        );
        return await WebDatabaseService.getAllUsersIncludingInactive();
      } else {
        debugPrint(
          'DataService: Mobile platform - using SQLite for getAllUsersIncludingInactive',
        );
        return await _dbHelper.getAllUsersIncludingInactive();
      }
    } catch (e) {
      debugPrint('DataService: Error getting all users including inactive: $e');
      return [];
    }
  }

  // Get user by email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      if (kIsWeb) {
        return await WebDatabaseService.getUserByEmail(email);
      } else {
        return await _dbHelper.getUserByEmail(email);
      }
    } catch (e) {
      debugPrint('DataService: Error getting user by email: $e');
      return null;
    }
  }

  // Get user by ID
  Future<Map<String, dynamic>?> getUserById(int userId) async {
    try {
      if (kIsWeb) {
        debugPrint(
          'DataService: Web platform - using WebDatabaseService for getUserById',
        );
        return await WebDatabaseService.getUserById(userId);
      } else {
        debugPrint(
          'DataService: Mobile platform - using SQLite for getUserById',
        );
        return await _dbHelper.getUserById(userId);
      }
    } catch (e) {
      debugPrint('DataService: Error getting user by ID: $e');
      return null;
    }
  }

  // Authenticate user
  Future<Map<String, dynamic>?> authenticateUser(
    String email,
    String password,
  ) async {
    try {
      if (kIsWeb) {
        return await WebDatabaseService.authenticateUser(email, password);
      } else {
        return await _dbHelper.authenticateUser(email, password);
      }
    } catch (e) {
      debugPrint('DataService: Error authenticating user: $e');
      return null;
    }
  }

  // Insert new user
  Future<bool> insertUser(Map<String, dynamic> userData) async {
    try {
      if (kIsWeb) {
        debugPrint(
          'DataService: Web platform - using WebDatabaseService for insertUser',
        );
        return await WebDatabaseService.insertUser(userData);
      } else {
        debugPrint(
          'DataService: Mobile platform - using SQLite for insertUser',
        );
        return await _dbHelper.insertUser(userData);
      }
    } catch (e) {
      debugPrint('DataService: Error inserting user: $e');
      return false;
    }
  }

  // Update user
  Future<bool> updateUser(int userId, Map<String, dynamic> userData) async {
    try {
      if (kIsWeb) {
        debugPrint(
          'DataService: Web platform - using WebDatabaseService for updateUser',
        );
        return await WebDatabaseService.updateUser(userId, userData);
      } else {
        debugPrint(
          'DataService: Mobile platform - using SQLite for updateUser',
        );
        return await _dbHelper.updateUser(userId, userData);
      }
    } catch (e) {
      debugPrint('DataService: Error updating user: $e');
      return false;
    }
  }

  // Delete user (soft delete)
  Future<bool> deleteUser(int userId) async {
    try {
      if (kIsWeb) {
        debugPrint(
          'DataService: Web platform - using WebDatabaseService for deleteUser',
        );
        return await WebDatabaseService.deleteUser(userId);
      } else {
        debugPrint(
          'DataService: Mobile platform - using SQLite for deleteUser',
        );
        return await _dbHelper.deleteUser(userId);
      }
    } catch (e) {
      debugPrint('DataService: Error deleting user: $e');
      return false;
    }
  }

  // Toggle user status
  Future<bool> toggleUserStatus(int userId) async {
    try {
      return await _dbHelper.toggleUserStatus(userId);
    } catch (e) {
      debugPrint('DataService: Error toggling user status: $e');
      return false;
    }
  }

  // Get users by type
  Future<List<Map<String, dynamic>>> getUsersByType(String userType) async {
    try {
      return await _dbHelper.getUsersByType(userType);
    } catch (e) {
      debugPrint('DataService: Error getting users by type: $e');
      return [];
    }
  }

  // Check if email exists
  Future<bool> emailExists(String email) async {
    try {
      return await _dbHelper.emailExists(email);
    } catch (e) {
      debugPrint('DataService: Error checking email existence: $e');
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
      debugPrint('DataService: Error changing password: $e');
      return false;
    }
  }

  // Reset user password
  Future<bool> resetUserPassword(int userId, String newPassword) async {
    try {
      return await _dbHelper.resetUserPassword(userId, newPassword);
    } catch (e) {
      debugPrint('DataService: Error resetting password: $e');
      return false;
    }
  }

  // ===== BLOOD INVENTORY OPERATIONS =====

  // Get all blood inventory
  Future<List<Map<String, dynamic>>> getAllBloodInventory() async {
    try {
      if (kIsWeb) {
        return await WebDatabaseService.getAllBloodInventory();
      } else {
        return await _dbHelper.getAllBloodInventory();
      }
    } catch (e) {
      debugPrint('DataService: Error getting blood inventory: $e');
      return [];
    }
  }

  // Get all donations
  Future<List<Map<String, dynamic>>> getAllDonations() async {
    try {
      if (kIsWeb) {
        return await WebDatabaseService.getAllDonations();
      } else {
        return await _dbHelper.getAllDonations();
      }
    } catch (e) {
      debugPrint('DataService: Error getting donations: $e');
      return [];
    }
  }

  // Get all blood requests
  Future<List<Map<String, dynamic>>> getAllBloodRequests() async {
    try {
      if (kIsWeb) {
        return await WebDatabaseService.getAllBloodRequests();
      } else {
        return await _dbHelper.getAllBloodRequests();
      }
    } catch (e) {
      debugPrint('DataService: Error getting blood requests: $e');
      return [];
    }
  }

  // Get blood inventory by group
  Future<Map<String, dynamic>?> getBloodInventoryByGroup(
    String bloodGroup,
  ) async {
    try {
      if (kIsWeb) {
        return await WebDatabaseService.getBloodInventoryByGroup(bloodGroup);
      } else {
        return await _dbHelper.getBloodInventoryByGroup(bloodGroup);
      }
    } catch (e) {
      debugPrint('DataService: Error getting blood inventory by group: $e');
      return null;
    }
  }

  // Update blood inventory
  Future<bool> updateBloodInventory(int id, Map<String, dynamic> data) async {
    try {
      if (kIsWeb) {
        return await WebDatabaseService.updateBloodInventory(id, data);
      } else {
        return await _dbHelper.updateBloodInventory(id, data);
      }
    } catch (e) {
      debugPrint('DataService: Error updating blood inventory: $e');
      return false;
    }
  }

  // Add new blood inventory item
  Future<bool> addBloodInventory(Map<String, dynamic> data) async {
    try {
      if (kIsWeb) {
        return await WebDatabaseService.insertBloodInventory(data);
      } else {
        return await _dbHelper.addBloodInventory(data);
      }
    } catch (e) {
      debugPrint('DataService: Error adding blood inventory: $e');
      return false;
    }
  }

  // Delete blood inventory item
  Future<bool> deleteBloodInventory(int id) async {
    try {
      if (kIsWeb) {
        return await WebDatabaseService.deleteBloodInventory(id);
      } else {
        return await _dbHelper.deleteBloodInventory(id);
      }
    } catch (e) {
      debugPrint('DataService: Error deleting blood inventory: $e');
      return false;
    }
  }

  // Search blood inventory
  Future<List<Map<String, dynamic>>> searchBloodInventory(String query) async {
    try {
      if (kIsWeb) {
        return await WebDatabaseService.searchBloodInventory(query);
      } else {
        return await _dbHelper.searchBloodInventory(query);
      }
    } catch (e) {
      debugPrint('DataService: Error searching blood inventory: $e');
      return [];
    }
  }

  // Get blood inventory summary
  Future<Map<String, int>> getBloodInventorySummary() async {
    try {
      if (kIsWeb) {
        return await WebDatabaseService.getBloodInventorySummary();
      } else {
        return await _dbHelper.getBloodInventorySummary();
      }
    } catch (e) {
      debugPrint('DataService: Error getting blood inventory summary: $e');
      return {};
    }
  }

  // Reserve blood units
  Future<bool> reserveBloodUnits(String bloodGroup, int quantity) async {
    try {
      return await _dbHelper.reserveBloodUnits(bloodGroup, quantity);
    } catch (e) {
      debugPrint('DataService: Error reserving blood units: $e');
      return false;
    }
  }

  // Release reserved blood units
  Future<bool> releaseBloodUnits(String bloodGroup, int quantity) async {
    try {
      return await _dbHelper.releaseBloodUnits(bloodGroup, quantity);
    } catch (e) {
      debugPrint('DataService: Error releasing blood units: $e');
      return false;
    }
  }

  // ===== DONATION OPERATIONS =====

  // Add donation
  Future<bool> addDonation(Map<String, dynamic> donationData) async {
    try {
      return await _dbHelper.addDonation(donationData);
    } catch (e) {
      debugPrint('DataService: Error adding donation: $e');
      return false;
    }
  }

  // Get donations by donor
  Future<List<Map<String, dynamic>>> getDonationsByDonor(int donorId) async {
    try {
      return await _dbHelper.getDonationsByDonor(donorId);
    } catch (e) {
      debugPrint('DataService: Error getting donations by donor: $e');
      return [];
    }
  }

  // ===== BLOOD REQUEST OPERATIONS =====

  // Add blood request
  Future<bool> addBloodRequest(Map<String, dynamic> requestData) async {
    try {
      return await _dbHelper.addBloodRequest(requestData);
    } catch (e) {
      debugPrint('DataService: Error adding blood request: $e');
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
      debugPrint('DataService: Error getting requests by requester: $e');
      return [];
    }
  }

  // Approve blood request
  Future<bool> approveBloodRequest(int requestId, int approvedBy) async {
    try {
      return await _dbHelper.approveBloodRequest(requestId, approvedBy);
    } catch (e) {
      debugPrint('DataService: Error approving blood request: $e');
      return false;
    }
  }

  // Reject blood request
  Future<bool> rejectBloodRequest(
    int requestId,
    int rejectedBy,
    String reason,
  ) async {
    try {
      return await _dbHelper.rejectBloodRequest(requestId, rejectedBy, reason);
    } catch (e) {
      debugPrint('DataService: Error rejecting blood request: $e');
      return false;
    }
  }

  // Get blood request by ID
  Future<Map<String, dynamic>?> getBloodRequestById(int requestId) async {
    try {
      return await _dbHelper.getBloodRequestById(requestId);
    } catch (e) {
      debugPrint('DataService: Error getting blood request by ID: $e');
      return null;
    }
  }

  // ===== NOTIFICATION OPERATIONS =====

  // Add notification
  Future<bool> addNotification(Map<String, dynamic> notificationData) async {
    try {
      if (kIsWeb) {
        // Web database service doesn't have addNotification method yet
        debugPrint('DataService: Web platform - notification not implemented yet');
        return false;
      } else {
        return await _dbHelper.addNotification(notificationData);
      }
    } catch (e) {
      debugPrint('DataService: Error adding notification: $e');
      return false;
    }
  }

  // ===== CONTACT MESSAGE OPERATIONS =====

  // In-memory storage for contact messages (temporary until database is implemented)
  static final List<Map<String, dynamic>> _contactMessages = [];

  // Add contact message
  Future<bool> addContactMessage({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    try {
      if (kIsWeb) {
        // Web database service doesn't have contact message methods yet
        debugPrint('DataService: Web platform - contact message not implemented yet');
        return false;
      } else {
        // Store in memory for now
        final newMessage = {
          'id': _contactMessages.length + 1,
          'name': name,
          'email': email,
          'subject': subject,
          'message': message,
          'timestamp': DateTime.now().toIso8601String(),
          'isRead': false,
          'adminResponse': null,
        };
        
        _contactMessages.add(newMessage);
        debugPrint('Contact message stored: $name - $subject - $message');
        return true;
      }
    } catch (e) {
      debugPrint('DataService: Error adding contact message: $e');
      return false;
    }
  }

  // Get all contact messages
  Future<List<Map<String, dynamic>>> getAllContactMessages() async {
    try {
      if (kIsWeb) {
        // Web database service doesn't have contact message methods yet
        debugPrint('DataService: Web platform - contact message not implemented yet');
        return [];
      } else {
        // Return in-memory messages for now
        return List.from(_contactMessages);
      }
    } catch (e) {
      debugPrint('DataService: Error getting contact messages: $e');
      return [];
    }
  }

  // Update contact message (mark as read, add response, etc.)
  Future<bool> updateContactMessage(int messageId, Map<String, dynamic> updates) async {
    try {
      if (kIsWeb) {
        // Web database service doesn't have contact message methods yet
        debugPrint('DataService: Web platform - contact message not implemented yet');
        return false;
      } else {
        // Update in-memory message
        final index = _contactMessages.indexWhere((msg) => msg['id'] == messageId);
        if (index != -1) {
          _contactMessages[index].addAll(updates);
          return true;
        }
        return false;
      }
    } catch (e) {
      debugPrint('DataService: Error updating contact message: $e');
      return false;
    }
  }

  // Delete contact message
  Future<bool> deleteContactMessage(int messageId) async {
    try {
      if (kIsWeb) {
        // Web database service doesn't have contact message methods yet
        debugPrint('DataService: Web platform - contact message not implemented yet');
        return false;
      } else {
        // Remove from in-memory storage
        _contactMessages.removeWhere((msg) => msg['id'] == messageId);
        return true;
      }
    } catch (e) {
      debugPrint('DataService: Error deleting contact message: $e');
      return false;
    }
  }

  // Get notifications by user
  Future<List<Map<String, dynamic>>> getNotificationsByUser(int userId) async {
    try {
      return await _dbHelper.getNotificationsByUser(userId);
    } catch (e) {
      debugPrint('DataService: Error getting notifications by user: $e');
      return [];
    }
  }

  // Mark notification as read
  Future<bool> markNotificationAsRead(int notificationId) async {
    try {
      return await _dbHelper.markNotificationAsRead(notificationId);
    } catch (e) {
      debugPrint('DataService: Error marking notification as read: $e');
      return false;
    }
  }

  // Get unread notifications count
  Future<int> getUnreadNotificationsCount(int userId) async {
    try {
      return await _dbHelper.getUnreadNotificationsCount(userId);
    } catch (e) {
      debugPrint('DataService: Error getting unread notifications count: $e');
      return 0;
    }
  }

  // Clear all notifications for user
  Future<bool> clearNotificationsForUser(int userId) async {
    try {
      return await _dbHelper.clearNotificationsForUser(userId);
    } catch (e) {
      debugPrint('DataService: Error clearing notifications for user: $e');
      return false;
    }
  }

  // ===== USER SESSION OPERATIONS =====

  // Create user session
  Future<bool> createUserSession(
    int userId,
    String sessionToken,
    String deviceInfo,
  ) async {
    try {
      return await _dbHelper.createUserSession(
        userId,
        sessionToken,
        deviceInfo,
      );
    } catch (e) {
      debugPrint('DataService: Error creating user session: $e');
      return false;
    }
  }

  // Update session activity
  Future<bool> updateSessionActivity(int userId) async {
    try {
      return await _dbHelper.updateSessionActivity(userId);
    } catch (e) {
      debugPrint('DataService: Error updating session activity: $e');
      return false;
    }
  }

  // Invalidate user session
  Future<bool> invalidateUserSession(int userId) async {
    try {
      return await _dbHelper.invalidateUserSession(userId);
    } catch (e) {
      debugPrint('DataService: Error invalidating user session: $e');
      return false;
    }
  }

  // Get user session
  Future<Map<String, dynamic>?> getUserSession(int userId) async {
    try {
      return await _dbHelper.getUserSession(userId);
    } catch (e) {
      debugPrint('DataService: Error getting user session: $e');
      return null;
    }
  }

  // ===== AUDIT LOG OPERATIONS =====

  // Get audit log
  Future<List<Map<String, dynamic>>> getAuditLog({
    int? userId,
    String? action,
    String? tableName,
    int? limit,
  }) async {
    try {
      return await _dbHelper.getAuditLog(
        userId: userId,
        action: action,
        tableName: tableName,
        limit: limit,
      );
    } catch (e) {
      debugPrint('DataService: Error getting audit log: $e');
      return [];
    }
  }

  // ===== STATISTICS AND ANALYTICS =====

  // Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStatistics() async {
    try {
      return await _dbHelper.getDashboardStatistics();
    } catch (e) {
      debugPrint('DataService: Error getting dashboard statistics: $e');
      return {};
    }
  }

  // Get blood inventory statistics
  Future<Map<String, dynamic>> getBloodInventoryStatistics() async {
    try {
      return await _dbHelper.getBloodInventoryStatistics();
    } catch (e) {
      debugPrint('DataService: Error getting blood inventory statistics: $e');
      return {};
    }
  }

  // Get user activity statistics
  Future<Map<String, dynamic>> getUserActivityStatistics() async {
    try {
      return await _dbHelper.getUserActivityStatistics();
    } catch (e) {
      debugPrint('DataService: Error getting user activity statistics: $e');
      return {};
    }
  }

  // Close database
  Future<void> close() async {
    try {
      await _dbHelper.close();
      debugPrint('DataService: Database closed successfully');
    } catch (e) {
      debugPrint('DataService: Error closing database: $e');
    }
  }

  // Test database connectivity
  Future<Map<String, dynamic>> testDatabaseConnectivity() async {
    try {
      // Test database initialization first
      await DatabaseHelper.initializeDatabaseFactory();

      // Test basic database operations
      final users = await getAllUsers();
      final bloodInventory = await getAllBloodInventory();

      // Test database health
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.database;
      final tables = await db.query(
        'sqlite_master',
        where: 'type = ?',
        whereArgs: ['table'],
      );

      return {
        'status': 'success',
        'users': users.length,
        'bloodInventory': bloodInventory.length,
        'tables': tables.length,
        'message': 'Database connection successful',
        'details': 'All database operations working properly',
      };
    } catch (e) {
      debugPrint('DataService: Error testing database connectivity: $e');
      return {
        'status': 'error',
        'error': e.toString(),
        'message': 'Database connection failed',
        'details': 'Please check database configuration',
      };
    }
  }

  // Test page-specific database operations
  Future<Map<String, dynamic>> testPageDatabaseOperations(
    String pageName,
  ) async {
    try {
      switch (pageName.toLowerCase()) {
        case 'home':
          final users = await getAllUsers();
          final bloodSummary = await getBloodInventorySummary();
          return {
            'status': 'success',
            'page': pageName,
            'operations': ['getAllUsers', 'getBloodInventorySummary'],
            'results': {
              'users': users.length,
              'bloodGroups': bloodSummary.length,
            },
          };

        case 'blood_inventory':
          final inventory = await getAllBloodInventory();
          final summary = await getBloodInventorySummary();
          return {
            'status': 'success',
            'page': pageName,
            'operations': ['getAllBloodInventory', 'getBloodInventorySummary'],
            'results': {
              'inventory': inventory.length,
              'summary': summary.length,
            },
          };

        case 'admin':
          final users = await getAllUsers();
          final donations = await getAllDonations();
          final requests = await getAllBloodRequests();
          return {
            'status': 'success',
            'page': pageName,
            'operations': [
              'getAllUsers',
              'getAllDonations',
              'getAllBloodRequests',
            ],
            'results': {
              'users': users.length,
              'donations': donations.length,
              'requests': requests.length,
            },
          };

        case 'donor':
          final donors = await getUsersByType('Donor');
          final donations = await getAllDonations();
          return {
            'status': 'success',
            'page': pageName,
            'operations': ['getUsersByType', 'getAllDonations'],
            'results': {'donors': donors.length, 'donations': donations.length},
          };

        case 'receiver':
          final receivers = await getUsersByType('Receiver');
          final requests = await getAllBloodRequests();
          return {
            'status': 'success',
            'page': pageName,
            'operations': ['getUsersByType', 'getAllBloodRequests'],
            'results': {
              'receivers': receivers.length,
              'requests': requests.length,
            },
          };

        case 'profile':
          final users = await getAllUsers();
          return {
            'status': 'success',
            'page': pageName,
            'operations': ['getAllUsers'],
            'results': {'users': users.length},
          };

        default:
          return {
            'status': 'error',
            'page': pageName,
            'error': 'Unknown page: $pageName',
          };
      }
    } catch (e) {
      debugPrint(
        'DataService: Error testing page database operations for $pageName: $e',
      );
      return {'status': 'error', 'page': pageName, 'error': e.toString()};
    }
  }

  // Test database connectivity
  Future<Map<String, dynamic>> testConnectivity() async {
    try {
      if (kIsWeb) {
        return await WebDatabaseService.testConnectivity();
      } else {
        final users = await getAllUsers();
        final bloodInventory = await getAllBloodInventory();
        final donations = await getAllDonations();
        final requests = await getAllBloodRequests();

        return {
          'status': 'success',
          'users': users.length,
          'bloodInventory': bloodInventory.length,
          'donations': donations.length,
          'requests': requests.length,
          'message': 'Database connection successful',
          'details': 'All database operations working properly',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'error': e.toString(),
        'message': 'Database connection failed',
        'details': 'Please check database configuration',
      };
    }
  }
}
