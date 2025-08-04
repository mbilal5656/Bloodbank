import 'package:flutter/foundation.dart';
import '../db_helper.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Initialize database
  static Future<void> initializeDatabase() async {
    try {
      if (kIsWeb) {
        return;
      }
      await DatabaseHelper.initializeDatabase();
    } catch (e) {
      rethrow;
    }
  }



  // ===== USER OPERATIONS =====

  // Get all users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      return await _dbHelper.getAllUsers();
    } catch (e) {
      return [];
    }
  }

  // Get all users including inactive
  Future<List<Map<String, dynamic>>> getAllUsersIncludingInactive() async {
    try {
      return await _dbHelper.getAllUsersIncludingInactive();
    } catch (e) {
      return [];
    }
  }

  // Get user by email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      return await _dbHelper.getUserByEmail(email);
    } catch (e) {
      return null;
    }
  }

  // Get user by ID
  Future<Map<String, dynamic>?> getUserById(int userId) async {
    try {
      return await _dbHelper.getUserById(userId);
    } catch (e) {
      return null;
    }
  }

  // Authenticate user
  Future<Map<String, dynamic>?> authenticateUser(
      String email, String password) async {
    try {
      return await _dbHelper.authenticateUser(email, password);
    } catch (e) {
      return null;
    }
  }

  // Insert new user
  Future<bool> insertUser(Map<String, dynamic> userData) async {
    try {
      return await _dbHelper.insertUser(userData);
    } catch (e) {
      return false;
    }
  }

  // Update user
  Future<bool> updateUser(int userId, Map<String, dynamic> userData) async {
    try {
      return await _dbHelper.updateUser(userId, userData);
    } catch (e) {
      debugPrint('DataService: Error updating user: $e');
      return false;
    }
  }

  // Delete user (soft delete)
  Future<bool> deleteUser(int userId) async {
    try {
      return await _dbHelper.deleteUser(userId);
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
      int userId, String oldPassword, String newPassword) async {
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
      return await _dbHelper.getAllBloodInventory();
    } catch (e) {
      debugPrint('DataService: Error getting blood inventory: $e');
      return [];
    }
  }

  // Get all donations
  Future<List<Map<String, dynamic>>> getAllDonations() async {
    try {
      return await _dbHelper.getAllDonations();
    } catch (e) {
      debugPrint('DataService: Error getting donations: $e');
      return [];
    }
  }

  // Get all blood requests
  Future<List<Map<String, dynamic>>> getAllBloodRequests() async {
    try {
      return await _dbHelper.getAllBloodRequests();
    } catch (e) {
      debugPrint('DataService: Error getting blood requests: $e');
      return [];
    }
  }

  // Get blood inventory by group
  Future<Map<String, dynamic>?> getBloodInventoryByGroup(
      String bloodGroup) async {
    try {
      return await _dbHelper.getBloodInventoryByGroup(bloodGroup);
    } catch (e) {
      debugPrint('DataService: Error getting blood inventory by group: $e');
      return null;
    }
  }

  // Update blood inventory
  Future<bool> updateBloodInventory(int id, Map<String, dynamic> data) async {
    try {
      return await _dbHelper.updateBloodInventory(id, data);
    } catch (e) {
      debugPrint('DataService: Error updating blood inventory: $e');
      return false;
    }
  }

  // Add new blood inventory item
  Future<bool> addBloodInventory(Map<String, dynamic> data) async {
    try {
      return await _dbHelper.addBloodInventory(data);
    } catch (e) {
      debugPrint('DataService: Error adding blood inventory: $e');
      return false;
    }
  }

  // Delete blood inventory item
  Future<bool> deleteBloodInventory(int id) async {
    try {
      return await _dbHelper.deleteBloodInventory(id);
    } catch (e) {
      debugPrint('DataService: Error deleting blood inventory: $e');
      return false;
    }
  }

  // Search blood inventory
  Future<List<Map<String, dynamic>>> searchBloodInventory(String query) async {
    try {
      return await _dbHelper.searchBloodInventory(query);
    } catch (e) {
      debugPrint('DataService: Error searching blood inventory: $e');
      return [];
    }
  }

  // Get blood inventory summary
  Future<Map<String, int>> getBloodInventorySummary() async {
    try {
      return await _dbHelper.getBloodInventorySummary();
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
      int requesterId) async {
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
      int requestId, int rejectedBy, String reason) async {
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
      return await _dbHelper.addNotification(notificationData);
    } catch (e) {
      debugPrint('DataService: Error adding notification: $e');
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
      int userId, String sessionToken, String deviceInfo) async {
    try {
      return await _dbHelper.createUserSession(
          userId, sessionToken, deviceInfo);
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
      // Test basic database operations
      final users = await getAllUsers();
      final bloodInventory = await getAllBloodInventory();
      
      return {
        'status': 'success',
        'users': users.length,
        'bloodInventory': bloodInventory.length,
        'message': 'Database connection successful',
      };
    } catch (e) {
      debugPrint('DataService: Error testing database connectivity: $e');
      return {
        'status': 'error',
        'error': e.toString(),
        'message': 'Database connection failed',
      };
    }
  }
}
