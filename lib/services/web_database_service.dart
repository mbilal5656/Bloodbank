import 'dart:convert';
import 'package:flutter/foundation.dart';

class WebDatabaseService {
  static bool _isInitialized = false;
  
  // In-memory storage for web
  static final Map<String, List<Map<String, dynamic>>> _storage = {
    'users': [],
    'blood_inventory': [],
    'donations': [],
    'blood_requests': [],
    'notifications': [],
    'user_sessions': [],
    'audit_log': [],
  };

  // Initialize web database
  static Future<void> initialize() async {
    try {
      if (kIsWeb) {
        // Only create tables and insert sample data if not already initialized
        if (!_isInitialized) {
          await _createTables();
          await _insertSampleData();
          _isInitialized = true;
          debugPrint('✅ Web database initialized successfully');
        } else {
          debugPrint('✅ Web database already initialized');
        }
      }
    } catch (e) {
      debugPrint('❌ Error initializing web database: $e');
      rethrow;
    }
  }

  // Create tables (for compatibility)
  static Future<void> _createTables() async {
    // Only initialize if tables are empty
    if (_storage['users']!.isEmpty) {
      _storage['users'] = [];
      _storage['blood_inventory'] = [];
      _storage['donations'] = [];
      _storage['blood_requests'] = [];
      _storage['notifications'] = [];
      _storage['user_sessions'] = [];
      _storage['audit_log'] = [];
      debugPrint('✅ Web database tables created');
    } else {
      debugPrint('✅ Web database tables already exist');
    }
  }

  // Insert sample data
  static Future<void> _insertSampleData() async {
    try {
      // Check if admin user already exists
      final existingAdmin = await getUserByEmail('admin@bloodbank.com');
      if (existingAdmin == null) {
        await insertUser({
          'id': 1,
          'name': 'System Administrator',
          'email': 'admin@bloodbank.com',
          'password': _hashPassword('admin123'),
          'userType': 'Admin',
          'bloodGroup': 'N/A',
          'age': 30,
          'contactNumber': '+1234567890',
          'address': 'System Address',
          'isActive': 1,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        });
        debugPrint('✅ Admin user created');
      } else {
        debugPrint('✅ Admin user already exists');
      }

      // Check if donor user already exists
      final existingDonor = await getUserByEmail('donor@bloodbank.com');
      if (existingDonor == null) {
        await insertUser({
          'id': 2,
          'name': 'John Donor',
          'email': 'donor@bloodbank.com',
          'password': _hashPassword('donor123'),
          'userType': 'Donor',
          'bloodGroup': 'O+',
          'age': 28,
          'contactNumber': '+1234567891',
          'address': '123 Donor Street, City',
          'isActive': 1,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        });
        debugPrint('✅ Donor user created');
      } else {
        debugPrint('✅ Donor user already exists');
      }

      // Check if receiver user already exists
      final existingReceiver = await getUserByEmail('receiver@bloodbank.com');
      if (existingReceiver == null) {
        await insertUser({
          'id': 3,
          'name': 'Jane Receiver',
          'email': 'receiver@bloodbank.com',
          'password': _hashPassword('receiver123'),
          'userType': 'Receiver',
          'bloodGroup': 'A+',
          'age': 35,
          'contactNumber': '+1234567892',
          'address': '456 Receiver Avenue, City',
          'isActive': 1,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        });
        debugPrint('✅ Receiver user created');
      } else {
        debugPrint('✅ Receiver user already exists');
      }

      // Insert sample blood inventory
      final bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
      final quantities = [150, 75, 120, 45, 60, 30, 180, 90];

      for (int i = 0; i < bloodGroups.length; i++) {
        final existingInventory = await getBloodInventoryByGroup(bloodGroups[i]);
        if (existingInventory == null) {
          await insertBloodInventory({
            'id': i + 1,
            'bloodGroup': bloodGroups[i],
            'quantity': quantities[i],
            'reservedQuantity': 0,
            'status': 'Available',
            'lastUpdated': DateTime.now().toIso8601String(),
            'createdBy': 1,
            'notes': 'Initial stock - Sample data',
          });
        }
      }
      debugPrint('✅ Sample blood inventory created');
    } catch (e) {
      debugPrint('❌ Error inserting sample data: $e');
    }
  }

  // Hash password
  static String _hashPassword(String password) {
    // Simple hash for demo - in production use proper hashing
    return base64.encode(utf8.encode(password));
  }

  // User operations
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      return List.from(_storage['users']!);
    } catch (e) {
      debugPrint('❌ Error getting all users: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final users = _storage['users']!;
      for (final user in users) {
        if (user['email'] == email) {
          return Map.from(user);
        }
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting user by email: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getUserById(int id) async {
    try {
      final users = _storage['users']!;
      for (final user in users) {
        if (user['id'] == id) {
          return Map.from(user);
        }
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting user by ID: $e');
      return null;
    }
  }

  static Future<bool> insertUser(Map<String, dynamic> userData) async {
    try {
      final users = _storage['users']!;
      users.add(Map.from(userData));
      return true;
    } catch (e) {
      debugPrint('❌ Error inserting user: $e');
      return false;
    }
  }

  static Future<bool> updateUser(int id, Map<String, dynamic> userData) async {
    try {
      final users = _storage['users']!;
      for (int i = 0; i < users.length; i++) {
        if (users[i]['id'] == id) {
          users[i] = Map.from(userData)..['id'] = id;
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error updating user: $e');
      return false;
    }
  }

  static Future<bool> deleteUser(int id) async {
    try {
      final users = _storage['users']!;
      users.removeWhere((user) => user['id'] == id);
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting user: $e');
      return false;
    }
  }

  // Blood inventory operations
  static Future<List<Map<String, dynamic>>> getAllBloodInventory() async {
    try {
      return List.from(_storage['blood_inventory']!);
    } catch (e) {
      debugPrint('❌ Error getting blood inventory: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getBloodInventoryByGroup(String bloodGroup) async {
    try {
      final inventory = _storage['blood_inventory']!;
      for (final item in inventory) {
        if (item['bloodGroup'] == bloodGroup) {
          return Map.from(item);
        }
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting blood inventory by group: $e');
      return null;
    }
  }

  static Future<bool> insertBloodInventory(Map<String, dynamic> data) async {
    try {
      final inventory = _storage['blood_inventory']!;
      inventory.add(Map.from(data));
      return true;
    } catch (e) {
      debugPrint('❌ Error inserting blood inventory: $e');
      return false;
    }
  }

  static Future<bool> updateBloodInventory(int id, Map<String, dynamic> data) async {
    try {
      final inventory = _storage['blood_inventory']!;
      for (int i = 0; i < inventory.length; i++) {
        if (inventory[i]['id'] == id) {
          inventory[i] = Map.from(data)..['id'] = id;
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error updating blood inventory: $e');
      return false;
    }
  }

  // Donation operations
  static Future<List<Map<String, dynamic>>> getAllDonations() async {
    try {
      return List.from(_storage['donations']!);
    } catch (e) {
      debugPrint('❌ Error getting donations: $e');
      return [];
    }
  }

  static Future<bool> insertDonation(Map<String, dynamic> data) async {
    try {
      final donations = _storage['donations']!;
      donations.add(Map.from(data));
      return true;
    } catch (e) {
      debugPrint('❌ Error inserting donation: $e');
      return false;
    }
  }

  // Blood request operations
  static Future<List<Map<String, dynamic>>> getAllBloodRequests() async {
    try {
      return List.from(_storage['blood_requests']!);
    } catch (e) {
      debugPrint('❌ Error getting blood requests: $e');
      return [];
    }
  }

  static Future<bool> insertBloodRequest(Map<String, dynamic> data) async {
    try {
      final requests = _storage['blood_requests']!;
      requests.add(Map.from(data));
      return true;
    } catch (e) {
      debugPrint('❌ Error inserting blood request: $e');
      return false;
    }
  }

  // Notification operations
  static Future<List<Map<String, dynamic>>> getAllNotifications() async {
    try {
      return List.from(_storage['notifications']!);
    } catch (e) {
      debugPrint('❌ Error getting notifications: $e');
      return [];
    }
  }

  static Future<bool> insertNotification(Map<String, dynamic> data) async {
    try {
      final notifications = _storage['notifications']!;
      notifications.add(Map.from(data));
      return true;
    } catch (e) {
      debugPrint('❌ Error inserting notification: $e');
      return false;
    }
  }

  // Authentication
  static Future<Map<String, dynamic>?> authenticateUser(String email, String password) async {
    try {
      final user = await getUserByEmail(email);
      if (user != null) {
        final hashedPassword = _hashPassword(password);
        if (user['password'] == hashedPassword) {
          // Update last login
          await updateUser(user['id'], {
            'lastLogin': DateTime.now().toIso8601String(),
          });
          return user;
        }
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error authenticating user: $e');
      return null;
    }
  }

  // Get blood inventory summary
  static Future<Map<String, int>> getBloodInventorySummary() async {
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
      debugPrint('❌ Error getting blood inventory summary: $e');
      return {};
    }
  }

  // Test database connectivity
  static Future<Map<String, dynamic>> testConnectivity() async {
    try {
      await initialize();
      
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
        'message': 'Web database connection successful',
        'details': 'All database operations working properly',
      };
    } catch (e) {
      return {
        'status': 'error',
        'error': e.toString(),
        'message': 'Web database connection failed',
        'details': 'Please check web storage support',
      };
    }
  }
}
