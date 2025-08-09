import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';

class DatabaseHelper {
  static Database? _database;
  static const String _databaseName = 'bloodbank.db';
  static const int _databaseVersion = 4;
  static bool _isInitialized = false;

  // Table names
  static const String _usersTable = 'users';
  static const String _bloodInventoryTable = 'blood_inventory';
  static const String _donationsTable = 'donations';
  static const String _requestsTable = 'blood_requests';
  static const String _notificationsTable = 'notifications';
  static const String _userSessionsTable = 'user_sessions';
  static const String _auditLogTable = 'audit_log';

  // Singleton pattern
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // Initialize database factory for web/desktop platforms
  static Future<void> initializeDatabaseFactory() async {
    if (kIsWeb) {
      // Web platform detected - skipping SQLite initialization
      return;
    }

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      try {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      } catch (e) {
        // Error initializing database factory
      }
    }
  }

  // Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize database
  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      throw UnsupportedError(
        'SQLite is not supported on web platforms. Please use a web-compatible database.',
      );
    }

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
        address TEXT,
        isActive INTEGER DEFAULT 1,
        lastLogin TEXT,
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
        reservedQuantity INTEGER DEFAULT 0,
        status TEXT NOT NULL,
        expiryDate TEXT,
        lastUpdated TEXT NOT NULL,
        createdBy INTEGER,
        notes TEXT
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
        createdBy INTEGER,
        healthCheck TEXT
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
        notes TEXT,
        createdBy INTEGER,
        patientName TEXT,
        hospital TEXT,
        doctorName TEXT,
        contactNumber TEXT,
        approvedBy INTEGER,
        approvedAt TEXT
      )
    ''');

    // Notifications table
    await db.execute('''
      CREATE TABLE $_notificationsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        type TEXT NOT NULL,
        priority TEXT DEFAULT 'Normal',
        isRead INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        payload TEXT
      )
    ''');

    // User sessions table
    await db.execute('''
      CREATE TABLE $_userSessionsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        sessionToken TEXT NOT NULL,
        expiresAt TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    // Audit log table
    await db.execute('''
      CREATE TABLE $_auditLogTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        action TEXT NOT NULL,
        tableName TEXT,
        recordId INTEGER,
        oldValues TEXT,
        newValues TEXT,
        timestamp TEXT NOT NULL,
        ipAddress TEXT,
        userAgent TEXT
      )
    ''');

    // Insert default admin user
    await _insertDefaultAdmin(db);
  }

  // Update database schema
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    for (int i = oldVersion + 1; i <= newVersion; i++) {
      await _upgradeToVersion(db, i);
    }
  }

  Future<void> _upgradeToVersion(Database db, int version) async {
    switch (version) {
      case 2:
        // Add new columns or tables for version 2
        break;
      case 3:
        // Add new columns or tables for version 3
        break;
      case 4:
        try {
          // Update blood_requests table with new columns
          await db.execute(
            'ALTER TABLE $_requestsTable ADD COLUMN patientName TEXT',
          );
          await db.execute(
            'ALTER TABLE $_requestsTable ADD COLUMN hospital TEXT',
          );
          await db.execute(
            'ALTER TABLE $_requestsTable ADD COLUMN doctorName TEXT',
          );
          await db.execute(
            'ALTER TABLE $_requestsTable ADD COLUMN contactNumber TEXT',
          );
          await db.execute(
            'ALTER TABLE $_requestsTable ADD COLUMN approvedBy INTEGER',
          );
          await db.execute(
            'ALTER TABLE $_requestsTable ADD COLUMN approvedAt TEXT',
          );

          // Update notifications table with new columns
          await db.execute(
            'ALTER TABLE $_notificationsTable ADD COLUMN priority TEXT DEFAULT "Normal"',
          );
          await db.execute(
            'ALTER TABLE $_notificationsTable ADD COLUMN payload TEXT',
          );

          // Recreate audit_log table
          await db.execute('DROP TABLE IF EXISTS $_auditLogTable');
          await db.execute('''
            CREATE TABLE $_auditLogTable (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              userId INTEGER,
              action TEXT NOT NULL,
              tableName TEXT,
              recordId INTEGER,
              oldValues TEXT,
              newValues TEXT,
              timestamp TEXT NOT NULL,
              ipAddress TEXT,
              userAgent TEXT
            )
          ''');
        } catch (e) {
          // Error updating table schema
        }
        break;
    }
  }

  // Insert default admin user
  Future<void> _insertDefaultAdmin(Database db) async {
    try {
      final existingAdmin = await db.query(
        _usersTable,
        where: 'email = ?',
        whereArgs: ['admin@bloodbank.com'],
        limit: 1,
      );

      if (existingAdmin.isNotEmpty) {
        return;
      }

      final adminUser = {
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
      };

      await db.insert(_usersTable, adminUser);

      // Insert sample donor and receiver users
      await _insertSampleUsers(db);

      // Insert sample blood inventory data
      await _insertSampleBloodInventory(db);
    } catch (e) {
      // Error creating admin user
    }
  }

  // Insert sample users (donor and receiver)
  Future<void> _insertSampleUsers(Database db) async {
    try {
      // Sample donor user
      final donorUser = {
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
      };

      // Sample receiver user
      final receiverUser = {
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
      };

      // Check if users already exist
      final existingDonor = await db.query(
        _usersTable,
        where: 'email = ?',
        whereArgs: ['donor@bloodbank.com'],
        limit: 1,
      );

      final existingReceiver = await db.query(
        _usersTable,
        where: 'email = ?',
        whereArgs: ['receiver@bloodbank.com'],
        limit: 1,
      );

      if (existingDonor.isEmpty) {
        await db.insert(_usersTable, donorUser);
      }

      if (existingReceiver.isEmpty) {
        await db.insert(_usersTable, receiverUser);
      }
    } catch (e) {
      // Error creating sample users
    }
  }

  // Insert sample blood inventory data
  Future<void> _insertSampleBloodInventory(Database db) async {
    try {
      final bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
      final quantities = [150, 75, 120, 45, 60, 30, 180, 90];
      final statuses = [
        'Available',
        'Available',
        'Available',
        'Available',
        'Available',
        'Available',
        'Available',
        'Available',
      ];

      for (int i = 0; i < bloodGroups.length; i++) {
        final inventory = {
          'bloodGroup': bloodGroups[i],
          'quantity': quantities[i],
          'reservedQuantity': 0,
          'status': statuses[i],
          'lastUpdated': DateTime.now().toIso8601String(),
          'createdBy': 1, // Admin user ID
          'notes': 'Initial stock - Sample data',
        };

        await db.insert(_bloodInventoryTable, inventory);
      }
    } catch (e) {
      // Error adding sample blood inventory
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
    if (_isInitialized) {
      return;
    }

    try {
      await initializeDatabaseFactory();

      final dbHelper = DatabaseHelper();
      await dbHelper.database;
      _isInitialized = true;

      // Check database structure and create admin user if needed
      final structureCheck = await dbHelper.checkDatabaseStructure();
      if (structureCheck['status'] == 'success') {
        await createAdminUser();
      }
    } catch (e) {
      debugPrint('Error initializing database: $e');
      rethrow;
    }
  }

  // Create admin user (public method)
  static Future<bool> createAdminUser() async {
    try {
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.database;

      final existingAdmin = await db.query(
        _usersTable,
        where: 'email = ?',
        whereArgs: ['admin@bloodbank.com'],
        limit: 1,
      );

      if (existingAdmin.isNotEmpty) {
        return true; // Admin already exists
      }

      final adminUser = {
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
      };

      final id = await db.insert(_usersTable, adminUser);
      return id > 0;
    } catch (e) {
      return false;
    }
  }

  // ===== USER OPERATIONS =====

  // Get all users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final db = await database;
      final result = await db.query(
        _usersTable,
        orderBy: 'createdAt DESC',
        where: 'isActive = ?',
        whereArgs: [1],
      );
      return result;
    } catch (e) {
      return [];
    }
  }

  // Get all users including inactive
  Future<List<Map<String, dynamic>>> getAllUsersIncludingInactive() async {
    try {
      final db = await database;
      final result = await db.query(_usersTable, orderBy: 'createdAt DESC');
      return result;
    } catch (e) {
      return [];
    }
  }

  // Get user by email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final db = await database;

      final result = await db.query(
        _usersTable,
        where: 'email = ? AND isActive = ?',
        whereArgs: [email, 1],
      );

      if (result.isNotEmpty) {
        return result.first;
      } else {
        final allUsers = await db.query(
          _usersTable,
          where: 'email = ?',
          whereArgs: [email],
        );
        return null;
      }
    } catch (e) {
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
      return null;
    }
  }

  // Authenticate user
  Future<Map<String, dynamic>?> authenticateUser(
    String email,
    String password,
  ) async {
    try {
      final user = await getUserByEmail(email);
      if (user != null) {
        final hashedPassword = _hashPassword(password);
        final passwordMatch = user['password'] == hashedPassword;

        if (passwordMatch) {
          await updateUser(user['id'], {
            'lastLogin': DateTime.now().toIso8601String(),
          });
          return user;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Insert new user
  Future<bool> insertUser(Map<String, dynamic> userData) async {
    try {
      final db = await database;

      final hashedPassword = _hashPassword(userData['password']);

      final user = {
        'name': userData['name'],
        'email': userData['email'],
        'password': hashedPassword,
        'userType': userData['userType'],
        'bloodGroup': userData['bloodGroup'] ?? 'N/A',
        'age': userData['age'] ?? 0,
        'contactNumber': userData['contactNumber'] ?? '',
        'address': userData['address'] ?? '',
        'isActive': 1,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final id = await db.insert(_usersTable, user);

      await _logAuditAction(
        null,
        'CREATE',
        _usersTable,
        id,
        null,
        jsonEncode(user),
      );

      return id > 0;
    } catch (e) {
      return false;
    }
  }

  // Update user
  Future<bool> updateUser(int userId, Map<String, dynamic> userData) async {
    try {
      final db = await database;

      final oldUser = await getUserById(userId);
      final oldValues = oldUser != null ? jsonEncode(oldUser) : null;

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

      if (count > 0) {
        await _logAuditAction(
          userId,
          'UPDATE',
          _usersTable,
          userId,
          oldValues,
          jsonEncode(userData),
        );
      }

      return count > 0;
    } catch (e) {
      return false;
    }
  }

  // Delete user (soft delete)
  Future<bool> deleteUser(int userId) async {
    try {
      final db = await database;
      final count = await db.update(
        _usersTable,
        {'isActive': 0, 'updatedAt': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (count > 0) {
        await _logAuditAction(
          userId,
          'DELETE',
          _usersTable,
          userId,
          null,
          null,
        );
      }

      return count > 0;
    } catch (e) {
      return false;
    }
  }

  // Toggle user status
  Future<bool> toggleUserStatus(int userId) async {
    try {
      final user = await getUserById(userId);
      if (user == null) return false;

      final newStatus = user['isActive'] == 1 ? 0 : 1;
      final success = await updateUser(userId, {'isActive': newStatus});
      return success;
    } catch (e) {
      return false;
    }
  }

  // Get users by type
  Future<List<Map<String, dynamic>>> getUsersByType(String userType) async {
    try {
      final db = await database;
      final result = await db.query(
        _usersTable,
        where: 'userType = ? AND isActive = ?',
        whereArgs: [userType, 1],
        orderBy: 'createdAt DESC',
      );
      return result;
    } catch (e) {
      return [];
    }
  }

  // Check if email exists
  Future<bool> emailExists(String email) async {
    try {
      final user = await getUserByEmail(email);
      return user != null;
    } catch (e) {
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
      final user = await getUserById(userId);
      if (user == null) return false;

      final oldHashedPassword = _hashPassword(oldPassword);
      if (user['password'] != oldHashedPassword) return false;

      final newHashedPassword = _hashPassword(newPassword);
      final success = await updateUser(userId, {'password': newHashedPassword});
      return success;
    } catch (e) {
      return false;
    }
  }

  // Reset user password
  Future<bool> resetUserPassword(int userId, String newPassword) async {
    try {
      final newHashedPassword = _hashPassword(newPassword);
      final success = await updateUser(userId, {'password': newHashedPassword});
      return success;
    } catch (e) {
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
      return [];
    }
  }

  // Get blood inventory by group
  Future<Map<String, dynamic>?> getBloodInventoryByGroup(
    String bloodGroup,
  ) async {
    try {
      final db = await database;
      final result = await db.query(
        _bloodInventoryTable,
        where: 'bloodGroup = ?',
        whereArgs: [bloodGroup],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      return null;
    }
  }

  // Update blood inventory
  Future<bool> updateBloodInventory(int id, Map<String, dynamic> data) async {
    try {
      final db = await database;

      final oldInventory = await db.query(
        _bloodInventoryTable,
        where: 'id = ?',
        whereArgs: [id],
      );
      final oldValues = oldInventory.isNotEmpty
          ? jsonEncode(oldInventory.first)
          : null;

      data['lastUpdated'] = DateTime.now().toIso8601String();

      final count = await db.update(
        _bloodInventoryTable,
        data,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (count > 0) {
        await _logAuditAction(
          null,
          'UPDATE',
          _bloodInventoryTable,
          id,
          oldValues,
          jsonEncode(data),
        );
      }

      return count > 0;
    } catch (e) {
      return false;
    }
  }

  // Add new blood inventory item
  Future<bool> addBloodInventory(Map<String, dynamic> data) async {
    try {
      final db = await database;

      final inventory = {
        'bloodGroup': data['bloodGroup'],
        'quantity': data['quantity'] ?? 0,
        'reservedQuantity': data['reservedQuantity'] ?? 0,
        'status': data['status'] ?? 'Available',
        'expiryDate': data['expiryDate'],
        'lastUpdated': DateTime.now().toIso8601String(),
        'createdBy': data['createdBy'] ?? 1,
        'notes': data['notes'],
      };

      final id = await db.insert(_bloodInventoryTable, inventory);

      if (id > 0) {
        await _logAuditAction(
          null,
          'CREATE',
          _bloodInventoryTable,
          id,
          null,
          jsonEncode(inventory),
        );
      }

      return id > 0;
    } catch (e) {
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

      if (count > 0) {
        await _logAuditAction(
          null,
          'DELETE',
          _bloodInventoryTable,
          id,
          null,
          null,
        );
      }

      return count > 0;
    } catch (e) {
      return false;
    }
  }

  // Search blood inventory
  Future<List<Map<String, dynamic>>> searchBloodInventory(String query) async {
    try {
      final db = await database;
      final result = await db.query(
        _bloodInventoryTable,
        where: 'bloodGroup LIKE ? OR status LIKE ? OR notes LIKE ?',
        whereArgs: ['%$query%', '%$query%', '%$query%'],
        orderBy: 'bloodGroup ASC',
      );
      return result;
    } catch (e) {
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
      return {};
    }
  }

  // Reserve blood units
  Future<bool> reserveBloodUnits(String bloodGroup, int quantity) async {
    try {
      final inventory = await getBloodInventoryByGroup(bloodGroup);
      if (inventory == null) return false;

      final availableQuantity = inventory['quantity'] as int;
      final reservedQuantity = inventory['reservedQuantity'] as int;
      final totalReserved = reservedQuantity + quantity;

      if (availableQuantity < totalReserved) return false;

      final success = await updateBloodInventory(inventory['id'], {
        'reservedQuantity': totalReserved,
      });
      return success;
    } catch (e) {
      return false;
    }
  }

  // Release reserved blood units
  Future<bool> releaseBloodUnits(String bloodGroup, int quantity) async {
    try {
      final inventory = await getBloodInventoryByGroup(bloodGroup);
      if (inventory == null) return false;

      final reservedQuantity = inventory['reservedQuantity'] as int;
      final newReservedQuantity = (reservedQuantity - quantity).clamp(
        0,
        reservedQuantity,
      );

      final success = await updateBloodInventory(inventory['id'], {
        'reservedQuantity': newReservedQuantity,
      });
      return success;
    } catch (e) {
      return false;
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
        'healthCheck': donationData['healthCheck'],
      };

      final id = await db.insert(_donationsTable, donation);

      if (id > 0) {
        await _updateBloodInventoryAfterDonation(
          donationData['bloodGroup'],
          donationData['quantity'],
        );

        await _logAuditAction(
          donationData['donorId'],
          'CREATE',
          _donationsTable,
          id,
          null,
          jsonEncode(donation),
        );
      }

      return id > 0;
    } catch (e) {
      return false;
    }
  }

  // Update blood inventory after donation
  Future<void> _updateBloodInventoryAfterDonation(
    String bloodGroup,
    int quantity,
  ) async {
    try {
      final inventory = await getBloodInventoryByGroup(bloodGroup);
      if (inventory != null) {
        final currentQuantity = inventory['quantity'] as int;
        await updateBloodInventory(inventory['id'], {
          'quantity': currentQuantity + quantity,
        });
      }
    } catch (e) {
      // Error updating blood inventory after donation
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
      return [];
    }
  }

  // Get all donations
  Future<List<Map<String, dynamic>>> getAllDonations() async {
    try {
      final db = await database;
      final result = await db.query(
        _donationsTable,
        orderBy: 'donationDate DESC',
      );
      return result;
    } catch (e) {
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
        'patientName': requestData['patientName'] ?? '',
        'hospital': requestData['hospital'] ?? '',
        'doctorName': requestData['doctorName'] ?? '',
        'contactNumber': requestData['contactNumber'] ?? '',
        'notes': requestData['notes'] ?? '',
      };

      final id = await db.insert(_requestsTable, request);

      if (id > 0) {
        await _logAuditAction(
          requestData['requesterId'],
          'CREATE',
          _requestsTable,
          id,
          null,
          jsonEncode(request),
        );
      }

      return id > 0;
    } catch (e) {
      return false;
    }
  }

  // Get requests by requester
  Future<List<Map<String, dynamic>>> getRequestsByRequester(
    int requesterId,
  ) async {
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
      return [];
    }
  }

  // Get all blood requests
  Future<List<Map<String, dynamic>>> getAllBloodRequests() async {
    try {
      final db = await database;
      final result = await db.query(
        _requestsTable,
        orderBy: 'requestDate DESC',
      );
      return result;
    } catch (e) {
      return [];
    }
  }

  // Approve blood request
  Future<bool> approveBloodRequest(int requestId, int approvedBy) async {
    try {
      final db = await database;
      final count = await db.update(
        _requestsTable,
        {
          'status': 'Approved',
          'approvedBy': approvedBy,
          'approvedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [requestId],
      );

      if (count > 0) {
        await _logAuditAction(
          approvedBy,
          'UPDATE',
          _requestsTable,
          requestId,
          null,
          jsonEncode({'status': 'Approved'}),
        );
      }

      return count > 0;
    } catch (e) {
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
      final db = await database;
      final requestData = await getBloodRequestById(requestId);
      if (requestData == null) return false;

      final count = await db.update(
        _requestsTable,
        {
          'status': 'Rejected',
          'approvedBy': rejectedBy,
          'approvedAt': DateTime.now().toIso8601String(),
          'notes': '${requestData['notes'] ?? ''}\nRejection Reason: $reason',
        },
        where: 'id = ?',
        whereArgs: [requestId],
      );

      if (count > 0) {
        await _logAuditAction(
          rejectedBy,
          'UPDATE',
          _requestsTable,
          requestId,
          null,
          jsonEncode({'status': 'Rejected'}),
        );
      }

      return count > 0;
    } catch (e) {
      return false;
    }
  }

  // Get blood request by ID
  Future<Map<String, dynamic>?> getBloodRequestById(int requestId) async {
    try {
      final db = await database;
      final result = await db.query(
        _requestsTable,
        where: 'id = ?',
        whereArgs: [requestId],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      return null;
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
        'priority': notificationData['priority'] ?? 'Normal',
        'isRead': 0,
        'createdAt': DateTime.now().toIso8601String(),
        'payload': notificationData['payload'] != null
            ? jsonEncode(notificationData['payload'])
            : null,
      };

      final id = await db.insert(_notificationsTable, notification);
      return id > 0;
    } catch (e) {
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
      return false;
    }
  }

  // Get unread notifications count
  Future<int> getUnreadNotificationsCount(int userId) async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_notificationsTable WHERE (userId = ? OR userId IS NULL) AND isRead = 0',
        [userId],
      );
      return result.first['count'] as int;
    } catch (e) {
      return 0;
    }
  }

  // Clear all notifications for user
  Future<bool> clearNotificationsForUser(int userId) async {
    try {
      final db = await database;
      final count = await db.delete(
        _notificationsTable,
        where: 'userId = ?',
        whereArgs: [userId],
      );
      return count > 0;
    } catch (e) {
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
      final db = await database;
      final session = {
        'userId': userId,
        'sessionToken': sessionToken,
        'expiresAt': DateTime.now()
            .add(const Duration(days: 7))
            .toIso8601String(), // 7 days expiry
        'createdAt': DateTime.now().toIso8601String(),
      };

      final id = await db.insert(_userSessionsTable, session);
      return id > 0;
    } catch (e) {
      return false;
    }
  }

  // Update session activity
  Future<bool> updateSessionActivity(int userId) async {
    try {
      final db = await database;
      final count = await db.update(
        _userSessionsTable,
        {'lastActivity': DateTime.now().toIso8601String()},
        where: 'userId = ? AND expiresAt > ?', // Only update if not expired
        whereArgs: [userId, DateTime.now().toIso8601String()],
      );
      return count > 0;
    } catch (e) {
      return false;
    }
  }

  // Invalidate user session
  Future<bool> invalidateUserSession(int userId) async {
    try {
      final db = await database;
      final count = await db.update(
        _userSessionsTable,
        {'isActive': 0},
        where: 'userId = ?',
        whereArgs: [userId],
      );
      return count > 0;
    } catch (e) {
      return false;
    }
  }

  // Get user session
  Future<Map<String, dynamic>?> getUserSession(int userId) async {
    try {
      final db = await database;
      final result = await db.query(
        _userSessionsTable,
        where: 'userId = ? AND expiresAt > ?', // Only get if not expired
        whereArgs: [userId, DateTime.now().toIso8601String()],
        orderBy: 'lastActivity DESC',
        limit: 1,
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      return null;
    }
  }

  // ===== AUDIT LOG OPERATIONS =====

  // Log audit action
  Future<void> _logAuditAction(
    int? userId,
    String action,
    String tableName,
    int? recordId,
    String? oldValues,
    String? newValues,
  ) async {
    try {
      final db = await database;
      final auditLog = {
        'userId': userId,
        'action': action,
        'tableName': tableName,
        'recordId': recordId,
        'oldValues': oldValues,
        'newValues': newValues,
        'timestamp': DateTime.now().toIso8601String(),
        'ipAddress': 'localhost', // In a real app, get from request
        'userAgent': 'BloodBank App', // In a real app, get from request
      };

      await db.insert(_auditLogTable, auditLog);
    } catch (e) {
      // Error logging audit action
    }
  }

  // Get audit log
  Future<List<Map<String, dynamic>>> getAuditLog({
    int? userId,
    String? action,
    String? tableName,
    int? limit,
  }) async {
    try {
      final db = await database;
      String whereClause = '';
      List<dynamic> whereArgs = [];

      if (userId != null) {
        whereClause += 'userId = ?';
        whereArgs.add(userId);
      }

      if (action != null) {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause += 'action = ?';
        whereArgs.add(action);
      }

      if (tableName != null) {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause += 'tableName = ?';
        whereArgs.add(tableName);
      }

      final result = await db.query(
        _auditLogTable,
        where: whereClause.isEmpty ? null : whereClause,
        whereArgs: whereArgs.isEmpty ? null : whereArgs,
        orderBy: 'timestamp DESC',
        limit: limit,
      );
      return result;
    } catch (e) {
      return [];
    }
  }

  // ===== STATISTICS AND ANALYTICS =====

  // Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStatistics() async {
    try {
      final db = await database;

      final userCounts = await db.rawQuery('''
        SELECT userType, COUNT(*) as count 
        FROM $_usersTable 
        WHERE isActive = 1 
        GROUP BY userType
      ''');

      final bloodSummary = await db.rawQuery('''
        SELECT SUM(quantity) as totalUnits, COUNT(*) as bloodGroups
        FROM $_bloodInventoryTable
      ''');

      final recentDonations = await db.rawQuery('''
        SELECT COUNT(*) as count 
        FROM $_donationsTable 
        WHERE donationDate >= datetime('now', '-7 days')
      ''');

      final pendingRequests = await db.rawQuery('''
        SELECT COUNT(*) as count 
        FROM $_requestsTable 
        WHERE status = 'Pending'
      ''');

      return {
        'userCounts': userCounts,
        'bloodSummary': bloodSummary.first,
        'recentDonations': recentDonations.first['count'],
        'pendingRequests': pendingRequests.first['count'],
      };
    } catch (e) {
      return {};
    }
  }

  // Get blood inventory statistics
  Future<Map<String, dynamic>> getBloodInventoryStatistics() async {
    try {
      final db = await database;

      final bloodGroupStats = await db.rawQuery('''
        SELECT bloodGroup, SUM(quantity) as totalUnits, SUM(reservedQuantity) as reservedUnits
        FROM $_bloodInventoryTable
        GROUP BY bloodGroup
        ORDER BY bloodGroup
      ''');

      final lowStockItems = await db.rawQuery('''
        SELECT bloodGroup, quantity, reservedQuantity
        FROM $_bloodInventoryTable
        WHERE (quantity - reservedQuantity) <= 10
        ORDER BY (quantity - reservedQuantity) ASC
      ''');

      final expiringItems = await db.rawQuery('''
        SELECT bloodGroup, quantity, expiryDate
        FROM $_bloodInventoryTable
        WHERE expiryDate IS NOT NULL 
        AND expiryDate <= datetime('now', '+7 days')
        ORDER BY expiryDate ASC
      ''');

      return {
        'bloodGroupStats': bloodGroupStats,
        'lowStockItems': lowStockItems,
        'expiringItems': expiringItems,
      };
    } catch (e) {
      return {};
    }
  }

  // Get user activity statistics
  Future<Map<String, dynamic>> getUserActivityStatistics() async {
    try {
      final db = await database;

      final recentLogins = await db.rawQuery('''
        SELECT u.name, u.email, u.lastLogin
        FROM $_usersTable u
        WHERE u.lastLogin IS NOT NULL
        ORDER BY u.lastLogin DESC
        LIMIT 10
      ''');

      final activeSessions = await db.rawQuery(
        '''
        SELECT COUNT(*) as count
        FROM $_userSessionsTable
        WHERE expiresAt > ?
      ''',
        [DateTime.now().toIso8601String()],
      );

      final registrationsByMonth = await db.rawQuery('''
        SELECT strftime('%Y-%m', createdAt) as month, COUNT(*) as count
        FROM $_usersTable
        WHERE createdAt >= datetime('now', '-12 months')
        GROUP BY month
        ORDER BY month DESC
      ''');

      return {
        'recentLogins': recentLogins,
        'activeSessions': activeSessions.first['count'],
        'registrationsByMonth': registrationsByMonth,
      };
    } catch (e) {
      return {};
    }
  }

  // Close database
  Future<void> close() async {
    try {
      await _database?.close();
    } catch (e) {
      // Error closing database
    }
  }

  // Check database structure
  Future<Map<String, dynamic>> checkDatabaseStructure() async {
    try {
      final db = await database;

      final tables = await db.query(
        'sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['table', _usersTable],
      );

      if (tables.isEmpty) {
        return {
          'status': 'error',
          'error': 'Users table not found',
          'message': 'Database structure is incomplete',
        };
      }

      final columns = await db.rawQuery('PRAGMA table_info($_usersTable)');
      final requiredColumns = [
        'id',
        'name',
        'email',
        'password',
        'userType',
        'bloodGroup',
        'age',
        'contactNumber',
        'address',
        'isActive',
        'lastLogin',
        'createdAt',
        'updatedAt',
      ];

      final existingColumns = columns
          .map((col) => col['name'] as String)
          .toList();
      final missingColumns = requiredColumns
          .where((col) => !existingColumns.contains(col))
          .toList();

      if (missingColumns.isNotEmpty) {
        return {
          'status': 'error',
          'error': 'Missing columns: $missingColumns',
          'message': 'Database structure is incomplete',
        };
      }

      return {
        'status': 'success',
        'message': 'Database structure is correct',
        'tables': [
          'users',
          'blood_inventory',
          'donations',
          'blood_requests',
          'notifications',
          'user_sessions',
          'audit_log',
        ],
        'columns': existingColumns,
      };
    } catch (e) {
      return {
        'status': 'error',
        'error': e.toString(),
        'message': 'Database structure check failed',
      };
    }
  }
}
