import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';

class DatabaseHelper {
  static Database? _database;
  static const String _databaseName = 'bloodbank.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String _usersTable = 'users';
  static const String _bloodInventoryTable = 'blood_inventory';
  static const String _donationsTable = 'donations';
  static const String _requestsTable = 'blood_requests';
  static const String _notificationsTable = 'notifications';

  // Singleton pattern
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize database
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Create database tables
  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE $_usersTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        userType TEXT NOT NULL,
        bloodGroup TEXT,
        age INTEGER,
        contactNumber TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Blood inventory table
    await db.execute('''
      CREATE TABLE $_bloodInventoryTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bloodGroup TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        status TEXT NOT NULL,
        lastUpdated TEXT NOT NULL,
        createdBy INTEGER,
        FOREIGN KEY (createdBy) REFERENCES $_usersTable (id)
      )
    ''');

    // Donations table
    await db.execute('''
      CREATE TABLE $_donationsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        donorId INTEGER NOT NULL,
        bloodGroup TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        donationDate TEXT NOT NULL,
        status TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (donorId) REFERENCES $_usersTable (id)
      )
    ''');

    // Blood requests table
    await db.execute('''
      CREATE TABLE $_requestsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        requesterId INTEGER NOT NULL,
        bloodGroup TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        urgency TEXT NOT NULL,
        requestDate TEXT NOT NULL,
        status TEXT NOT NULL,
        patientName TEXT,
        hospital TEXT,
        notes TEXT,
        FOREIGN KEY (requesterId) REFERENCES $_usersTable (id)
      )
    ''');

    // Notifications table
    await db.execute('''
      CREATE TABLE $_notificationsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        type TEXT NOT NULL,
        isRead INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES $_usersTable (id)
      )
    ''');

    // Insert default admin user
    await _insertDefaultAdmin(db);
    
    // Insert default blood inventory
    await _insertDefaultBloodInventory(db);
  }

  // Upgrade database
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      // Add migration logic here if needed
      print('Database upgraded from version $oldVersion to $newVersion');
    }
  }

  // Insert default admin user
  Future<void> _insertDefaultAdmin(Database db) async {
    final adminUser = {
      'name': 'Admin',
      'email': 'mbilalpk56@gmail.com',
      'password': _hashPassword('1Q2w3e5R'),
      'userType': 'Admin',
      'bloodGroup': 'N/A',
      'age': 30,
      'contactNumber': 'N/A',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    await db.insert(_usersTable, adminUser);
  }

  // Insert default blood inventory
  Future<void> _insertDefaultBloodInventory(Database db) async {
    final bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    final quantities = [10, 5, 8, 3, 4, 2, 12, 6];

    for (int i = 0; i < bloodGroups.length; i++) {
      final inventory = {
        'bloodGroup': bloodGroups[i],
        'quantity': quantities[i],
        'status': 'Available',
        'lastUpdated': DateTime.now().toIso8601String(),
        'createdBy': 1, // Admin user ID
      };

      await db.insert(_bloodInventoryTable, inventory);
    }
  }

  // Hash password using SHA-256
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Initialize database (public method)
  static Future<void> initializeDatabase() async {
    try {
      final dbHelper = DatabaseHelper();
      await dbHelper.database;
      print('Database initialized successfully');
    } catch (e) {
      print('Database initialization error: $e');
      rethrow;
    }
  }

  // ===== USER OPERATIONS =====

  // Get all users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final db = await database;
      final result = await db.query(_usersTable, orderBy: 'createdAt DESC');
      return result;
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    }
  }

  // Get user by email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final db = await database;
      final result = await db.query(
        _usersTable,
        where: 'email = ?',
        whereArgs: [email],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('Error getting user by email: $e');
      return null;
    }
  }

  // Get user by ID
  Future<Map<String, dynamic>?> getUserById(int userId) async {
    try {
      final db = await database;
      final result = await db.query(
        _usersTable,
        where: 'id = ?',
        whereArgs: [userId],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('Error getting user by ID: $e');
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
      final db = await database;
      
      // Hash password
      final hashedPassword = _hashPassword(userData['password']);
      
      // Prepare user data
      final user = {
        'name': userData['name'],
        'email': userData['email'],
        'password': hashedPassword,
        'userType': userData['userType'],
        'bloodGroup': userData['bloodGroup'],
        'age': userData['age'],
        'contactNumber': userData['contactNumber'],
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final id = await db.insert(_usersTable, user);
      return id > 0;
    } catch (e) {
      print('Error inserting user: $e');
      return false;
    }
  }

  // Update user
  Future<bool> updateUser(int userId, Map<String, dynamic> userData) async {
    try {
      final db = await database;
      
      // Handle password update
      if (userData.containsKey('password')) {
        userData['password'] = _hashPassword(userData['password']);
      }
      
      userData['updatedAt'] = DateTime.now().toIso8601String();

      final count = await db.update(
        _usersTable,
        userData,
        where: 'id = ?',
        whereArgs: [userId],
      );
      return count > 0;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  // Delete user
  Future<bool> deleteUser(int userId) async {
    try {
      final db = await database;
      final count = await db.delete(
        _usersTable,
        where: 'id = ?',
        whereArgs: [userId],
      );
      return count > 0;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  // Get users by type
  Future<List<Map<String, dynamic>>> getUsersByType(String userType) async {
    try {
      final db = await database;
      final result = await db.query(
        _usersTable,
        where: 'userType = ?',
        whereArgs: [userType],
        orderBy: 'createdAt DESC',
      );
      return result;
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

  // Change password
  Future<bool> changePassword(int userId, String oldPassword, String newPassword) async {
    try {
      final user = await getUserById(userId);
      if (user == null) return false;

      final oldHashedPassword = _hashPassword(oldPassword);
      if (user['password'] != oldHashedPassword) return false;

      final newHashedPassword = _hashPassword(newPassword);
      final success = await updateUser(userId, {'password': newHashedPassword});
      return success;
    } catch (e) {
      print('Error changing password: $e');
      return false;
    }
  }

  // ===== BLOOD INVENTORY OPERATIONS =====

  // Get all blood inventory
  Future<List<Map<String, dynamic>>> getAllBloodInventory() async {
    try {
      final db = await database;
      final result = await db.query(
        _bloodInventoryTable,
        orderBy: 'bloodGroup ASC',
      );
      return result;
    } catch (e) {
      print('Error getting blood inventory: $e');
      return [];
    }
  }

  // Get blood inventory by group
  Future<Map<String, dynamic>?> getBloodInventoryByGroup(String bloodGroup) async {
    try {
      final db = await database;
      final result = await db.query(
        _bloodInventoryTable,
        where: 'bloodGroup = ?',
        whereArgs: [bloodGroup],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('Error getting blood inventory by group: $e');
      return null;
    }
  }

  // Update blood inventory
  Future<bool> updateBloodInventory(int id, Map<String, dynamic> data) async {
    try {
      final db = await database;
      data['lastUpdated'] = DateTime.now().toIso8601String();
      
      final count = await db.update(
        _bloodInventoryTable,
        data,
        where: 'id = ?',
        whereArgs: [id],
      );
      return count > 0;
    } catch (e) {
      print('Error updating blood inventory: $e');
      return false;
    }
  }

  // Add new blood inventory item
  Future<bool> addBloodInventory(Map<String, dynamic> data) async {
    try {
      final db = await database;
      
      final inventory = {
        'bloodGroup': data['bloodGroup'],
        'quantity': data['quantity'],
        'status': data['status'] ?? 'Available',
        'lastUpdated': DateTime.now().toIso8601String(),
        'createdBy': data['createdBy'] ?? 1,
      };

      final id = await db.insert(_bloodInventoryTable, inventory);
      return id > 0;
    } catch (e) {
      print('Error adding blood inventory: $e');
      return false;
    }
  }

  // Delete blood inventory item
  Future<bool> deleteBloodInventory(int id) async {
    try {
      final db = await database;
      final count = await db.delete(
        _bloodInventoryTable,
        where: 'id = ?',
        whereArgs: [id],
      );
      return count > 0;
    } catch (e) {
      print('Error deleting blood inventory: $e');
      return false;
    }
  }

  // Search blood inventory
  Future<List<Map<String, dynamic>>> searchBloodInventory(String query) async {
    try {
      final db = await database;
      final result = await db.query(
        _bloodInventoryTable,
        where: 'bloodGroup LIKE ? OR status LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'bloodGroup ASC',
      );
      return result;
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

  // ===== DONATION OPERATIONS =====

  // Add donation
  Future<bool> addDonation(Map<String, dynamic> donationData) async {
    try {
      final db = await database;
      
      final donation = {
        'donorId': donationData['donorId'],
        'bloodGroup': donationData['bloodGroup'],
        'quantity': donationData['quantity'],
        'donationDate': DateTime.now().toIso8601String(),
        'status': donationData['status'] ?? 'Completed',
        'notes': donationData['notes'],
      };

      final id = await db.insert(_donationsTable, donation);
      return id > 0;
    } catch (e) {
      print('Error adding donation: $e');
      return false;
    }
  }

  // Get donations by donor
  Future<List<Map<String, dynamic>>> getDonationsByDonor(int donorId) async {
    try {
      final db = await database;
      final result = await db.query(
        _donationsTable,
        where: 'donorId = ?',
        whereArgs: [donorId],
        orderBy: 'donationDate DESC',
      );
      return result;
    } catch (e) {
      print('Error getting donations by donor: $e');
      return [];
    }
  }

  // ===== BLOOD REQUEST OPERATIONS =====

  // Add blood request
  Future<bool> addBloodRequest(Map<String, dynamic> requestData) async {
    try {
      final db = await database;
      
      final request = {
        'requesterId': requestData['requesterId'],
        'bloodGroup': requestData['bloodGroup'],
        'quantity': requestData['quantity'],
        'urgency': requestData['urgency'],
        'requestDate': DateTime.now().toIso8601String(),
        'status': requestData['status'] ?? 'Pending',
        'patientName': requestData['patientName'],
        'hospital': requestData['hospital'],
        'notes': requestData['notes'],
      };

      final id = await db.insert(_requestsTable, request);
      return id > 0;
    } catch (e) {
      print('Error adding blood request: $e');
      return false;
    }
  }

  // Get requests by requester
  Future<List<Map<String, dynamic>>> getRequestsByRequester(int requesterId) async {
    try {
      final db = await database;
      final result = await db.query(
        _requestsTable,
        where: 'requesterId = ?',
        whereArgs: [requesterId],
        orderBy: 'requestDate DESC',
      );
      return result;
    } catch (e) {
      print('Error getting requests by requester: $e');
      return [];
    }
  }

  // ===== NOTIFICATION OPERATIONS =====

  // Add notification
  Future<bool> addNotification(Map<String, dynamic> notificationData) async {
    try {
      final db = await database;
      
      final notification = {
        'userId': notificationData['userId'],
        'title': notificationData['title'],
        'message': notificationData['message'],
        'type': notificationData['type'],
        'isRead': 0,
        'createdAt': DateTime.now().toIso8601String(),
      };

      final id = await db.insert(_notificationsTable, notification);
      return id > 0;
    } catch (e) {
      print('Error adding notification: $e');
      return false;
    }
  }

  // Get notifications by user
  Future<List<Map<String, dynamic>>> getNotificationsByUser(int userId) async {
    try {
      final db = await database;
      final result = await db.query(
        _notificationsTable,
        where: 'userId = ? OR userId IS NULL',
        whereArgs: [userId],
        orderBy: 'createdAt DESC',
      );
      return result;
    } catch (e) {
      print('Error getting notifications by user: $e');
      return [];
    }
  }

  // Mark notification as read
  Future<bool> markNotificationAsRead(int notificationId) async {
    try {
      final db = await database;
      final count = await db.update(
        _notificationsTable,
        {'isRead': 1},
        where: 'id = ?',
        whereArgs: [notificationId],
      );
      return count > 0;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
