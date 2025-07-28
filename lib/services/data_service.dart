import '../db_helper.dart';
import '../models/user_model.dart';
import '../models/blood_inventory_model.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  // ===== USER OPERATIONS =====

  // Get all users with proper error handling
  Future<List<UserModel>> getAllUsers() async {
    try {
      final users = await _dbHelper.getAllUsers();
      return users.map((user) => UserModel.fromMap(user)).toList();
    } catch (e) {
      print('DataService: Error getting all users: $e');
      return [];
    }
  }

  // Get user by email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final user = await _dbHelper.getUserByEmail(email);
      return user != null ? UserModel.fromMap(user) : null;
    } catch (e) {
      print('DataService: Error getting user by email: $e');
      return null;
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(int userId) async {
    try {
      final user = await _dbHelper.getUserById(userId);
      return user != null ? UserModel.fromMap(user) : null;
    } catch (e) {
      print('DataService: Error getting user by ID: $e');
      return null;
    }
  }

  // Authenticate user
  Future<bool> authenticateUser(String email, String password) async {
    try {
      return await _dbHelper.authenticateUser(email, password);
    } catch (e) {
      print('DataService: Error authenticating user: $e');
      return false;
    }
  }

  // Create new user
  Future<bool> createUser(UserModel user) async {
    try {
      return await _dbHelper.insertUser(user.toMap());
    } catch (e) {
      print('DataService: Error creating user: $e');
      return false;
    }
  }

  // Update user
  Future<bool> updateUser(int userId, Map<String, dynamic> userData) async {
    try {
      return await _dbHelper.updateUser(userId, userData);
    } catch (e) {
      print('DataService: Error updating user: $e');
      return false;
    }
  }

  // Delete user
  Future<bool> deleteUser(int userId) async {
    try {
      return await _dbHelper.deleteUser(userId);
    } catch (e) {
      print('DataService: Error deleting user: $e');
      return false;
    }
  }

  // Get users by type
  Future<List<UserModel>> getUsersByType(String userType) async {
    try {
      final users = await _dbHelper.getUsersByType(userType);
      return users.map((user) => UserModel.fromMap(user)).toList();
    } catch (e) {
      print('DataService: Error getting users by type: $e');
      return [];
    }
  }

  // Check if email exists
  Future<bool> emailExists(String email) async {
    try {
      return await _dbHelper.emailExists(email);
    } catch (e) {
      print('DataService: Error checking email existence: $e');
      return false;
    }
  }

  // Change password
  Future<bool> changePassword(int userId, String oldPassword, String newPassword) async {
    try {
      return await _dbHelper.changePassword(userId, oldPassword, newPassword);
    } catch (e) {
      print('DataService: Error changing password: $e');
      return false;
    }
  }

  // ===== BLOOD INVENTORY OPERATIONS =====

  // Get all blood inventory
  Future<List<BloodInventoryModel>> getAllBloodInventory() async {
    try {
      final inventory = await _dbHelper.getAllBloodInventory();
      return inventory.map((item) => BloodInventoryModel.fromMap(item)).toList();
    } catch (e) {
      print('DataService: Error getting blood inventory: $e');
      return [];
    }
  }

  // Get blood inventory by group
  Future<BloodInventoryModel?> getBloodInventoryByGroup(String bloodGroup) async {
    try {
      final inventory = await _dbHelper.getBloodInventoryByGroup(bloodGroup);
      return inventory != null ? BloodInventoryModel.fromMap(inventory) : null;
    } catch (e) {
      print('DataService: Error getting blood inventory by group: $e');
      return null;
    }
  }

  // Update blood inventory
  Future<bool> updateBloodInventory(int id, Map<String, dynamic> data) async {
    try {
      return await _dbHelper.updateBloodInventory(id, data);
    } catch (e) {
      print('DataService: Error updating blood inventory: $e');
      return false;
    }
  }

  // Add new blood inventory item
  Future<bool> addBloodInventory(BloodInventoryModel inventory) async {
    try {
      return await _dbHelper.addBloodInventory(inventory.toMap());
    } catch (e) {
      print('DataService: Error adding blood inventory: $e');
      return false;
    }
  }

  // Delete blood inventory item
  Future<bool> deleteBloodInventory(int id) async {
    try {
      return await _dbHelper.deleteBloodInventory(id);
    } catch (e) {
      print('DataService: Error deleting blood inventory: $e');
      return false;
    }
  }

  // Search blood inventory
  Future<List<BloodInventoryModel>> searchBloodInventory(String query) async {
    try {
      final inventory = await _dbHelper.searchBloodInventory(query);
      return inventory.map((item) => BloodInventoryModel.fromMap(item)).toList();
    } catch (e) {
      print('DataService: Error searching blood inventory: $e');
      return [];
    }
  }

  // Get blood inventory summary
  Future<Map<String, int>> getBloodInventorySummary() async {
    try {
      return await _dbHelper.getBloodInventorySummary();
    } catch (e) {
      print('DataService: Error getting blood inventory summary: $e');
      return {};
    }
  }

  // ===== DONATION OPERATIONS =====

  // Add donation
  Future<bool> addDonation(Map<String, dynamic> donationData) async {
    try {
      return await _dbHelper.addDonation(donationData);
    } catch (e) {
      print('DataService: Error adding donation: $e');
      return false;
    }
  }

  // Get donations by donor
  Future<List<Map<String, dynamic>>> getDonationsByDonor(int donorId) async {
    try {
      return await _dbHelper.getDonationsByDonor(donorId);
    } catch (e) {
      print('DataService: Error getting donations by donor: $e');
      return [];
    }
  }

  // ===== BLOOD REQUEST OPERATIONS =====

  // Add blood request
  Future<bool> addBloodRequest(Map<String, dynamic> requestData) async {
    try {
      return await _dbHelper.addBloodRequest(requestData);
    } catch (e) {
      print('DataService: Error adding blood request: $e');
      return false;
    }
  }

  // Get requests by requester
  Future<List<Map<String, dynamic>>> getRequestsByRequester(int requesterId) async {
    try {
      return await _dbHelper.getRequestsByRequester(requesterId);
    } catch (e) {
      print('DataService: Error getting requests by requester: $e');
      return [];
    }
  }

  // ===== NOTIFICATION OPERATIONS =====

  // Add notification
  Future<bool> addNotification(Map<String, dynamic> notificationData) async {
    try {
      return await _dbHelper.addNotification(notificationData);
    } catch (e) {
      print('DataService: Error adding notification: $e');
      return false;
    }
  }

  // Get notifications by user
  Future<List<Map<String, dynamic>>> getNotificationsByUser(int userId) async {
    try {
      return await _dbHelper.getNotificationsByUser(userId);
    } catch (e) {
      print('DataService: Error getting notifications by user: $e');
      return [];
    }
  }

  // Mark notification as read
  Future<bool> markNotificationAsRead(int notificationId) async {
    try {
      return await _dbHelper.markNotificationAsRead(notificationId);
    } catch (e) {
      print('DataService: Error marking notification as read: $e');
      return false;
    }
  }

  // ===== UTILITY METHODS =====

  // Initialize database
  static Future<void> initializeDatabase() async {
    try {
      await DatabaseHelper.initializeDatabase();
      print('DataService: Database initialized successfully');
    } catch (e) {
      print('DataService: Error initializing database: $e');
      rethrow;
    }
  }

  // Close database
  Future<void> close() async {
    try {
      await _dbHelper.close();
      print('DataService: Database closed successfully');
    } catch (e) {
      print('DataService: Error closing database: $e');
    }
  }

  // Get database statistics
  Future<Map<String, dynamic>> getDatabaseStats() async {
    try {
      final users = await getAllUsers();
      final inventory = await getAllBloodInventory();
      final donations = await _dbHelper.getDonationsByDonor(1); // Sample query
      final requests = await _dbHelper.getRequestsByRequester(1); // Sample query

      return {
        'totalUsers': users.length,
        'totalInventory': inventory.length,
        'totalDonations': donations.length,
        'totalRequests': requests.length,
        'adminUsers': users.where((u) => u.isAdmin).length,
        'donorUsers': users.where((u) => u.isDonor).length,
        'receiverUsers': users.where((u) => u.isReceiver).length,
        'availableBlood': inventory.where((i) => i.isAvailable).length,
        'lowStockBlood': inventory.where((i) => i.isLow).length,
        'criticalBlood': inventory.where((i) => i.isCritical).length,
      };
    } catch (e) {
      print('DataService: Error getting database stats: $e');
      return {};
    }
  }

  // Validate user data
  static bool validateUserData(Map<String, dynamic> userData) {
    final requiredFields = ['name', 'email', 'password', 'userType'];
    
    for (final field in requiredFields) {
      if (userData[field] == null || userData[field].toString().isEmpty) {
        print('DataService: Missing required field: $field');
        return false;
      }
    }

    // Validate email format
    final email = userData['email'].toString();
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      print('DataService: Invalid email format: $email');
      return false;
    }

    // Validate password strength
    final password = userData['password'].toString();
    if (password.length < 6) {
      print('DataService: Password too short');
      return false;
    }

    // Validate user type
    final userType = userData['userType'].toString();
    if (!['Admin', 'Donor', 'Receiver'].contains(userType)) {
      print('DataService: Invalid user type: $userType');
      return false;
    }

    return true;
  }

  // Validate blood inventory data
  static bool validateBloodInventoryData(Map<String, dynamic> inventoryData) {
    final requiredFields = ['bloodGroup', 'quantity'];
    
    for (final field in requiredFields) {
      if (inventoryData[field] == null) {
        print('DataService: Missing required field: $field');
        return false;
      }
    }

    // Validate blood group
    final bloodGroup = inventoryData['bloodGroup'].toString();
    final validBloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    if (!validBloodGroups.contains(bloodGroup)) {
      print('DataService: Invalid blood group: $bloodGroup');
      return false;
    }

    // Validate quantity
    final quantity = inventoryData['quantity'];
    if (quantity is! int || quantity < 0) {
      print('DataService: Invalid quantity: $quantity');
      return false;
    }

    return true;
  }
} 