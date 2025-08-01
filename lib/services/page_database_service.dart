import 'package:flutter/foundation.dart';
import '../db_helper.dart';
import 'data_service.dart';

class PageDatabaseService {
  static final PageDatabaseService _instance = PageDatabaseService._internal();
  factory PageDatabaseService() => _instance;
  PageDatabaseService._internal();

  final DataService _dataService = DataService();

  // Initialize database for all pages
  static Future<void> initializePageDatabase() async {
    try {
      debugPrint('🔗 Initializing page database connections...');
      await DatabaseHelper.initializeDatabase();
      debugPrint('✅ Page database connections initialized');
    } catch (e) {
      debugPrint('❌ Page database initialization error: $e');
    }
  }

  // ==================== HOME PAGE ====================
  Future<Map<String, dynamic>> getHomeData() async {
    try {
      final users = await _dataService.getAllUsers();
      final inventory = await _dataService.getAllBloodInventory();
      final donations = await _dataService.getAllDonations();
      final requests = await _dataService.getAllBloodRequests();
      
      return {
        'status': 'success',
        'totalUsers': users.length,
        'totalInventory': inventory.length,
        'totalDonations': donations.length,
        'totalRequests': requests.length,
      };
    } catch (e) {
      return {'status': 'error', 'error': e.toString()};
    }
  }

  // ==================== LOGIN PAGE ====================
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      final user = await _dataService.getUserByEmail(email);
      if (user != null && user['password'] == password) {
        return {'status': 'success', 'user': user};
      }
      return {'status': 'error', 'message': 'Invalid credentials'};
    } catch (e) {
      return {'status': 'error', 'error': e.toString()};
    }
  }

  // ==================== SIGNUP PAGE ====================
  Future<Map<String, dynamic>> registerUser(Map<String, dynamic> userData) async {
    try {
      final success = await _dataService.insertUser(userData);
      return success 
        ? {'status': 'success', 'message': 'Registration successful'}
        : {'status': 'error', 'message': 'Registration failed'};
    } catch (e) {
      return {'status': 'error', 'error': e.toString()};
    }
  }

  // ==================== ADMIN PAGE ====================
  Future<Map<String, dynamic>> getAdminData() async {
    try {
      final users = await _dataService.getAllUsers();
      final inventory = await _dataService.getAllBloodInventory();
      final donations = await _dataService.getAllDonations();
      final requests = await _dataService.getAllBloodRequests();
      
      return {
        'status': 'success',
        'users': users,
        'inventory': inventory,
        'donations': donations,
        'requests': requests,
        'stats': {
          'totalUsers': users.length,
          'totalInventory': inventory.length,
          'totalDonations': donations.length,
          'totalRequests': requests.length,
        }
      };
    } catch (e) {
      return {'status': 'error', 'error': e.toString()};
    }
  }

  // ==================== DONOR PAGE ====================
  Future<Map<String, dynamic>> getDonorData(int userId) async {
    try {
      final user = await _dataService.getUserById(userId);
      final donations = await _dataService.getDonationsByDonor(userId);
      
      return {
        'status': 'success',
        'user': user,
        'donations': donations,
        'totalDonations': donations.length,
      };
    } catch (e) {
      return {'status': 'error', 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> createDonation(Map<String, dynamic> donationData) async {
    try {
      final success = await _dataService.addDonation(donationData);
      return success 
        ? {'status': 'success', 'message': 'Donation recorded'}
        : {'status': 'error', 'message': 'Failed to record donation'};
    } catch (e) {
      return {'status': 'error', 'error': e.toString()};
    }
  }

  // ==================== RECEIVER PAGE ====================
  Future<Map<String, dynamic>> getReceiverData(int userId) async {
    try {
      final user = await _dataService.getUserById(userId);
      final requests = await _dataService.getRequestsByRequester(userId);
      
      return {
        'status': 'success',
        'user': user,
        'requests': requests,
        'totalRequests': requests.length,
      };
    } catch (e) {
      return {'status': 'error', 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> createBloodRequest(Map<String, dynamic> requestData) async {
    try {
      final success = await _dataService.addBloodRequest(requestData);
      return success 
        ? {'status': 'success', 'message': 'Request submitted'}
        : {'status': 'error', 'message': 'Failed to submit request'};
    } catch (e) {
      return {'status': 'error', 'error': e.toString()};
    }
  }

  // ==================== BLOOD INVENTORY PAGE ====================
  Future<Map<String, dynamic>> getInventoryData() async {
    try {
      final inventory = await _dataService.getAllBloodInventory();
      final donations = await _dataService.getAllDonations();
      final requests = await _dataService.getAllBloodRequests();
      
      return {
        'status': 'success',
        'inventory': inventory,
        'donations': donations,
        'requests': requests,
        'stats': {
          'totalInventory': inventory.length,
          'totalDonations': donations.length,
          'totalRequests': requests.length,
        }
      };
    } catch (e) {
      return {'status': 'error', 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> addInventory(Map<String, dynamic> inventoryData) async {
    try {
      final success = await _dataService.addBloodInventory(inventoryData);
      return success 
        ? {'status': 'success', 'message': 'Inventory added'}
        : {'status': 'error', 'message': 'Failed to add inventory'};
    } catch (e) {
      return {'status': 'error', 'error': e.toString()};
    }
  }

  // ==================== PROFILE PAGE ====================
  Future<Map<String, dynamic>> getProfileData(int userId) async {
    try {
      final user = await _dataService.getUserById(userId);
      if (user != null) {
        Map<String, dynamic> additionalData = {};
        
        if (user['userType'] == 'Donor') {
          final donations = await _dataService.getDonationsByDonor(userId);
          additionalData['donations'] = donations;
        } else if (user['userType'] == 'Receiver') {
          final requests = await _dataService.getRequestsByRequester(userId);
          additionalData['requests'] = requests;
        }
        
        return {
          'status': 'success',
          'user': user,
          'additionalData': additionalData,
        };
      }
      return {'status': 'error', 'message': 'User not found'};
    } catch (e) {
      return {'status': 'error', 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateProfile(int userId, Map<String, dynamic> userData) async {
    try {
      final success = await _dataService.updateUser(userId, userData);
      return success 
        ? {'status': 'success', 'message': 'Profile updated'}
        : {'status': 'error', 'message': 'Failed to update profile'};
    } catch (e) {
      return {'status': 'error', 'error': e.toString()};
    }
  }

  // ==================== NOTIFICATIONS PAGE ====================
  Future<Map<String, dynamic>> getNotificationsData(int userId) async {
    try {
      final notifications = await _dataService.getNotificationsByUser(userId);
      return {
        'status': 'success',
        'notifications': notifications,
        'totalNotifications': notifications.length,
        'unreadCount': notifications.where((n) => n['isRead'] == 0).length,
      };
    } catch (e) {
      return {'status': 'error', 'error': e.toString()};
    }
  }

  // ==================== SETTINGS PAGE ====================
  Future<Map<String, dynamic>> getSettingsData() async {
    try {
      final users = await _dataService.getAllUsers();
      final inventory = await _dataService.getAllBloodInventory();
      final donations = await _dataService.getAllDonations();
      final requests = await _dataService.getAllBloodRequests();
      
      return {
        'status': 'success',
        'stats': {
          'totalUsers': users.length,
          'totalInventory': inventory.length,
          'totalDonations': donations.length,
          'totalRequests': requests.length,
        },
        'systemInfo': {
          'databaseVersion': 3,
          'platform': kIsWeb ? 'Web' : 'Mobile',
        },
      };
    } catch (e) {
      return {'status': 'error', 'error': e.toString()};
    }
  }

  // ==================== UNIVERSAL PAGE DATA ====================
  Future<Map<String, dynamic>> getPageData(String pageName, {Map<String, dynamic>? params}) async {
    try {
      switch (pageName.toLowerCase()) {
        case 'home':
          return await getHomeData();
        case 'admin':
          return await getAdminData();
        case 'donor':
          final userId = params?['userId'] as int? ?? 1;
          return await getDonorData(userId);
        case 'receiver':
          final userId = params?['userId'] as int? ?? 1;
          return await getReceiverData(userId);
        case 'blood_inventory':
          return await getInventoryData();
        case 'profile':
          final userId = params?['userId'] as int? ?? 1;
          return await getProfileData(userId);
        case 'notifications':
          final userId = params?['userId'] as int? ?? 1;
          return await getNotificationsData(userId);
        case 'settings':
          return await getSettingsData();
        default:
          return {'status': 'error', 'message': 'Unknown page: $pageName'};
      }
    } catch (e) {
      return {'status': 'error', 'error': e.toString()};
    }
  }

  // Test all page connections
  Future<Map<String, dynamic>> testAllPageConnections() async {
    try {
      final pages = ['home', 'admin', 'donor', 'receiver', 'blood_inventory', 'profile', 'notifications', 'settings'];
      final results = <String, Map<String, dynamic>>{};
      
      for (final page in pages) {
        results[page] = await getPageData(page);
      }
      
      final successCount = results.values.where((r) => r['status'] == 'success').length;
      
      return {
        'status': 'success',
        'results': results,
        'summary': {
          'totalPages': pages.length,
          'successfulPages': successCount,
          'failedPages': pages.length - successCount,
        }
      };
    } catch (e) {
      return {'status': 'error', 'error': e.toString()};
    }
  }
} 