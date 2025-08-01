import 'package:flutter/foundation.dart';
import '../db_helper.dart';
import 'data_service.dart';

class DatabaseConnectivityService {
  static final DatabaseConnectivityService _instance = DatabaseConnectivityService._internal();
  factory DatabaseConnectivityService() => _instance;
  DatabaseConnectivityService._internal();

  final DataService _dataService = DataService();

  // Database connection status
  bool _isConnected = false;
  String _lastError = '';
  DateTime? _lastConnectionTest;

  bool get isConnected => _isConnected;
  String get lastError => _lastError;
  DateTime? get lastConnectionTest => _lastConnectionTest;

  // Initialize database connection
  Future<bool> initializeConnection() async {
    try {
      debugPrint('DatabaseConnectivityService: Initializing connection...');
      
      if (kIsWeb) {
        debugPrint('DatabaseConnectivityService: Web platform - using mock data');
        _isConnected = true;
        _lastConnectionTest = DateTime.now();
        return true;
      }

      // Test basic database operations
      await DatabaseHelper.initializeDatabase();
      
      // Test connectivity with a simple query
      final testResult = await _testBasicConnectivity();
      
      _isConnected = testResult;
      _lastConnectionTest = DateTime.now();
      
      if (_isConnected) {
        debugPrint('DatabaseConnectivityService: Connection established successfully');
      } else {
        debugPrint('DatabaseConnectivityService: Connection failed');
      }
      
      return _isConnected;
    } catch (e) {
      _isConnected = false;
      _lastError = e.toString();
      _lastConnectionTest = DateTime.now();
      debugPrint('DatabaseConnectivityService: Connection error: $e');
      return false;
    }
  }

  // Test basic connectivity
  Future<bool> _testBasicConnectivity() async {
    try {
      // Test user table access
      final users = await _dataService.getAllUsers();
      debugPrint('DatabaseConnectivityService: Users table accessible, count: ${users.length}');
      
      // Test blood inventory table access
      final inventory = await _dataService.getAllBloodInventory();
      debugPrint('DatabaseConnectivityService: Blood inventory table accessible, count: ${inventory.length}');
      
      return true;
    } catch (e) {
      debugPrint('DatabaseConnectivityService: Basic connectivity test failed: $e');
      return false;
    }
  }

  // Test connectivity for specific page
  Future<Map<String, dynamic>> testPageConnectivity(String pageName) async {
    try {
      debugPrint('DatabaseConnectivityService: Testing connectivity for $pageName...');
      
      if (!_isConnected) {
        final reconnected = await initializeConnection();
        if (!reconnected) {
          return {
            'status': 'error',
            'error': 'Database not connected',
            'page': pageName,
          };
        }
      }

      switch (pageName.toLowerCase()) {
        case 'home':
          return await _testHomePageConnectivity();
        case 'admin':
          return await _testAdminPageConnectivity();
        case 'donor':
          return await _testDonorPageConnectivity();
        case 'receiver':
          return await _testReceiverPageConnectivity();
        case 'blood_inventory':
          return await _testBloodInventoryPageConnectivity();
        case 'profile':
          return await _testProfilePageConnectivity();
        case 'settings':
          return await _testSettingsPageConnectivity();
        case 'login':
          return await _testLoginPageConnectivity();
        case 'signup':
          return await _testSignupPageConnectivity();
        default:
          return await _testGenericPageConnectivity(pageName);
      }
    } catch (e) {
      debugPrint('DatabaseConnectivityService: Page connectivity test failed for $pageName: $e');
      return {
        'status': 'error',
        'error': e.toString(),
        'page': pageName,
      };
    }
  }

  // Test home page connectivity
  Future<Map<String, dynamic>> _testHomePageConnectivity() async {
    try {
      final users = await _dataService.getAllUsers();
      final inventory = await _dataService.getBloodInventorySummary();
      final stats = await _dataService.getDashboardStatistics();
      
      return {
        'status': 'success',
        'userCount': users.length,
        'inventorySummary': inventory,
        'statistics': stats,
        'page': 'home',
      };
    } catch (e) {
      return {
        'status': 'error',
        'error': e.toString(),
        'page': 'home',
      };
    }
  }

  // Test admin page connectivity
  Future<Map<String, dynamic>> _testAdminPageConnectivity() async {
    try {
      final users = await _dataService.getAllUsers();
      final inventory = await _dataService.getAllBloodInventory();
      final donations = await _dataService.getAllDonations();
      final requests = await _dataService.getAllBloodRequests();
      
      return {
        'status': 'success',
        'userCount': users.length,
        'inventoryCount': inventory.length,
        'donationCount': donations.length,
        'requestCount': requests.length,
        'page': 'admin',
      };
    } catch (e) {
      return {
        'status': 'error',
        'error': e.toString(),
        'page': 'admin',
      };
    }
  }

  // Test donor page connectivity
  Future<Map<String, dynamic>> _testDonorPageConnectivity() async {
    try {
      final donations = await _dataService.getAllDonations();
      final donors = await _dataService.getUsersByType('Donor');
      final inventory = await _dataService.getBloodInventorySummary();
      
      return {
        'status': 'success',
        'donationCount': donations.length,
        'donorCount': donors.length,
        'inventorySummary': inventory,
        'page': 'donor',
      };
    } catch (e) {
      return {
        'status': 'error',
        'error': e.toString(),
        'page': 'donor',
      };
    }
  }

  // Test receiver page connectivity
  Future<Map<String, dynamic>> _testReceiverPageConnectivity() async {
    try {
      final requests = await _dataService.getAllBloodRequests();
      final receivers = await _dataService.getUsersByType('Receiver');
      final inventory = await _dataService.getBloodInventorySummary();
      
      return {
        'status': 'success',
        'requestCount': requests.length,
        'receiverCount': receivers.length,
        'inventorySummary': inventory,
        'page': 'receiver',
      };
    } catch (e) {
      return {
        'status': 'error',
        'error': e.toString(),
        'page': 'receiver',
      };
    }
  }

  // Test blood inventory page connectivity
  Future<Map<String, dynamic>> _testBloodInventoryPageConnectivity() async {
    try {
      final inventory = await _dataService.getAllBloodInventory();
      final summary = await _dataService.getBloodInventorySummary();
      final stats = await _dataService.getBloodInventoryStatistics();
      
      return {
        'status': 'success',
        'inventoryCount': inventory.length,
        'summary': summary,
        'statistics': stats,
        'page': 'blood_inventory',
      };
    } catch (e) {
      return {
        'status': 'error',
        'error': e.toString(),
        'page': 'blood_inventory',
      };
    }
  }

  // Test profile page connectivity
  Future<Map<String, dynamic>> _testProfilePageConnectivity() async {
    try {
      final users = await _dataService.getAllUsers();
      
      return {
        'status': 'success',
        'userCount': users.length,
        'page': 'profile',
      };
    } catch (e) {
      return {
        'status': 'error',
        'error': e.toString(),
        'page': 'profile',
      };
    }
  }

  // Test settings page connectivity
  Future<Map<String, dynamic>> _testSettingsPageConnectivity() async {
    try {
      final users = await _dataService.getAllUsers();
      
      return {
        'status': 'success',
        'userCount': users.length,
        'page': 'settings',
      };
    } catch (e) {
      return {
        'status': 'error',
        'error': e.toString(),
        'page': 'settings',
      };
    }
  }

  // Test login page connectivity
  Future<Map<String, dynamic>> _testLoginPageConnectivity() async {
    try {
      final users = await _dataService.getAllUsers();
      
      return {
        'status': 'success',
        'userCount': users.length,
        'page': 'login',
      };
    } catch (e) {
      return {
        'status': 'error',
        'error': e.toString(),
        'page': 'login',
      };
    }
  }

  // Test signup page connectivity
  Future<Map<String, dynamic>> _testSignupPageConnectivity() async {
    try {
      final users = await _dataService.getAllUsers();
      
      return {
        'status': 'success',
        'userCount': users.length,
        'page': 'signup',
      };
    } catch (e) {
      return {
        'status': 'error',
        'error': e.toString(),
        'page': 'signup',
      };
    }
  }

  // Test generic page connectivity
  Future<Map<String, dynamic>> _testGenericPageConnectivity(String pageName) async {
    try {
      final users = await _dataService.getAllUsers();
      
      return {
        'status': 'success',
        'userCount': users.length,
        'page': pageName,
      };
    } catch (e) {
      return {
        'status': 'error',
        'error': e.toString(),
        'page': pageName,
      };
    }
  }

  // Get comprehensive database status
  Future<Map<String, dynamic>> getDatabaseStatus() async {
    try {
      final isConnected = await initializeConnection();
      
      if (!isConnected) {
        return {
          'status': 'disconnected',
          'error': _lastError,
          'lastTest': _lastConnectionTest?.toIso8601String(),
        };
      }

      // Get comprehensive statistics
      final users = await _dataService.getAllUsers();
      final inventory = await _dataService.getAllBloodInventory();
      final donations = await _dataService.getAllDonations();
      final requests = await _dataService.getAllBloodRequests();
      final stats = await _dataService.getDashboardStatistics();

      return {
        'status': 'connected',
        'lastTest': _lastConnectionTest?.toIso8601String(),
        'statistics': {
          'users': users.length,
          'inventory': inventory.length,
          'donations': donations.length,
          'requests': requests.length,
        },
        'dashboard': stats,
      };
    } catch (e) {
      return {
        'status': 'error',
        'error': e.toString(),
        'lastTest': _lastConnectionTest?.toIso8601String(),
      };
    }
  }

  // Refresh database connection
  Future<bool> refreshConnection() async {
    try {
      debugPrint('DatabaseConnectivityService: Refreshing connection...');
      _isConnected = false;
      _lastError = '';
      return await initializeConnection();
    } catch (e) {
      _lastError = e.toString();
      debugPrint('DatabaseConnectivityService: Connection refresh failed: $e');
      return false;
    }
  }

  // Close database connection
  Future<void> closeConnection() async {
    try {
      await _dataService.close();
      _isConnected = false;
      debugPrint('DatabaseConnectivityService: Connection closed');
    } catch (e) {
      debugPrint('DatabaseConnectivityService: Error closing connection: $e');
    }
  }
} 