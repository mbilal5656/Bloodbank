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
      debugPrint('Web platform detected - skipping SQLite initialization');
      return;
    }

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
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
          'SQLite is not supported on web platforms. Please use a web-compatible database.');
    }

    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    debugPrint('Database path: $path');
    debugPrint('Database name: $_databaseName');
    debugPrint('Database version: $_databaseVersion');

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Create database tables
  Future<void> _onCreate(Database db, int version) async {
    debugPrint('Creating database tables...');

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
    debugPrint('Users table created successfully');

    // Blood inventory table
    await db.execute('''
      CREATE TABLE $_bloodInventoryTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bloodGroup TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        reservedQuantity INTEGER DEFAULT 0,
        status TEXT NOT NULL,
        lastUpdated TEXT NOT NULL,
        createdBy INTEGER,
        notes TEXT
      )
    ''');
    debugPrint('Blood inventory table created successfully');

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
        createdBy INTEGER
      )
    ''');
    debugPrint('Donations table created successfully');

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
        createdBy INTEGER
      )
    ''');
    debugPrint('Blood requests table created successfully');

    // Notifications table
    await db.execute('''
      CREATE TABLE $_notificationsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        type TEXT NOT NULL,
        isRead INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');
    debugPrint('Notifications table created successfully');

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
    debugPrint('User sessions table created successfully');

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
    debugPrint('Audit log table created successfully');

    // Insert default admin user
    await _insertDefaultAdmin(db);
  }

  // Update database schema
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint('Upgrading database from version $oldVersion to $newVersion');
    
    if (oldVersion < 2) {
      debugPrint('Upgrading to version 2...');
      // Add new columns or tables for version 2
    }
    
    if (oldVersion < 3) {
      debugPrint('Upgrading to version 3...');
      // Add new columns or tables for version 3
    }
    
    if (oldVersion < 4) {
      debugPrint('Upgrading to version 4...');
      // Update audit_log table schema for version 4
      try {
        debugPrint('Updating audit_log table schema for version 4...');
        
        // Drop the old audit_log table if it exists
        await db.execute('DROP TABLE IF EXISTS $_auditLogTable');
        
        // Create the new audit_log table with correct schema
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
        
        debugPrint('Audit_log table schema updated successfully for version 4');
      } catch (e) {
        debugPrint('Error updating audit_log table schema: $e');
      }
    }
    
    debugPrint('Database upgrade completed from version $oldVersion to $newVersion');
  }

  // Insert default admin user
  Future<void> _insertDefaultAdmin(Database db) async {
    try {
      debugPrint('Creating default admin user...');

      // Check if admin user already exists
      final existingAdmin = await db.query(
        _usersTable,
        where: 'email = ?',
        whereArgs: ['admin@bloodbank.com'],
        limit: 1,
      );

      if (existingAdmin.isNotEmpty) {
        debugPrint('Admin user already exists');
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

      final id = await db.insert(_usersTable, adminUser);
      debugPrint('Admin user created with ID: $id');

      // Insert sample blood inventory data
      await _insertSampleBloodInventory(db);
    } catch (e) {
      debugPrint('Error creating admin user: $e');
    }
  }

  // Insert sample blood inventory data
  Future<void> _insertSampleBloodInventory(Database db) async {
    try {
      debugPrint('Adding sample blood inventory data...');
      
      final bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
      final quantities = [150, 75, 120, 45, 60, 30, 180, 90];
      final statuses = ['Available', 'Available', 'Available', 'Available', 'Available', 'Available', 'Available', 'Available'];

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
      
      debugPrint('Sample blood inventory data added successfully');
    } catch (e) {
      debugPrint('Error adding sample blood inventory: $e');
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
      debugPrint('Database already initialized');
      return;
    }

    try {
      debugPrint('Starting database initialization...');
      debugPrint('Database version: $_databaseVersion');
      
      // Initialize database factory for desktop platforms
      await initializeDatabaseFactory();
      
      final dbHelper = DatabaseHelper();
      await dbHelper.database;
      _isInitialized = true;
      debugPrint('Database initialization completed successfully');
      
      // Verify database structure
      final structureCheck = await dbHelper.checkDatabaseStructure();
      if (structureCheck['status'] == 'success') {
        debugPrint('Database structure verification passed');
      } else {
        debugPrint('Database structure verification failed: ${structureCheck['error']}');
      }
    } catch (e) {
      debugPrint('Database initialization error: $e');
      rethrow;
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
      debugPrint('Error getting all users: $e');
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
      debugPrint('Error getting all users including inactive: $e');
      return [];
    }
  }

  // Get user by email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      debugPrint('🔍 Looking up user by email: $email');
      final db = await database;
      debugPrint('✅ Database connection established for user lookup');

      final result = await db.query(
        _usersTable,
        where: 'email = ? AND isActive = ?',
        whereArgs: [email, 1],
      );

      debugPrint('📊 Query result: ${result.length} rows found');

      if (result.isNotEmpty) {
        debugPrint(
            '✅ User found: ${result.first['name']} (${result.first['userType']})');
        return result.first;
      } else {
        debugPrint('❌ User not found for email: $email');
        // Let's check if the user exists but is inactive
        final allUsers = await db.query(
          _usersTable,
          where: 'email = ?',
          whereArgs: [email],
        );
        if (allUsers.isNotEmpty) {
          debugPrint(
              '⚠️ User exists but is inactive: ${allUsers.first['name']}');
        }
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error getting user by email: $e');
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
      debugPrint('Error getting user by ID: $e');
      return null;
    }
  }

  // Authenticate user
  Future<Map<String, dynamic>?> authenticateUser(
      String email, String password) async {
    try {
      debugPrint('🔐 Attempting authentication for email: $email');
      final user = await getUserByEmail(email);
      if (user != null) {
        debugPrint('✅ User found: ${user['name']} (${user['userType']})');
        final hashedPassword = _hashPassword(password);
        final passwordMatch = user['password'] == hashedPassword;
        debugPrint('🔑 Password match: $passwordMatch');

        if (passwordMatch) {
          debugPrint('✅ Authentication successful');
          // Update last login
          await updateUser(
              user['id'], {'lastLogin': DateTime.now().toIso8601String()});
          return user;
        } else {
          debugPrint('❌ Password mismatch');
        }
      } else {
        debugPrint('❌ User not found for email: $email');
      }
      return null;
    } catch (e) {
      debugPrint('❌ Authentication error: $e');
      return null;
    }
  }

  // Insert new user
  Future<bool> insertUser(Map<String, dynamic> userData) async {
    try {
      debugPrint('🔧 Attempting to create user: ${userData['email']}');
      final db = await database;
      debugPrint('✅ Database connection established for user creation');

      // Hash password
      final hashedPassword = _hashPassword(userData['password']);
      debugPrint('🔐 Password hashed successfully');

      // Prepare user data
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

      debugPrint('📝 User data prepared: ${user['name']} (${user['email']})');
      debugPrint('📝 User type: ${user['userType']}');
      debugPrint('📝 Blood group: ${user['bloodGroup']}');

      final id = await db.insert(_usersTable, user);
      debugPrint('✅ User created with ID: $id');

      // Verify the insertion
      final verifyUser = await getUserByEmail(userData['email']);
      if (verifyUser != null) {
        debugPrint('✅ User verification successful: ${verifyUser['name']}');
      } else {
        debugPrint(
            '❌ User verification failed - user not found after insertion');
      }

      // Log the action
      await _logAuditAction(
          null, 'CREATE', _usersTable, id, null, jsonEncode(user));

      return id > 0;
    } catch (e) {
      debugPrint('❌ Error inserting user: $e');
      debugPrint('❌ Error details: ${e.toString()}');
      return false;
    }
  }

  // Update user
  Future<bool> updateUser(int userId, Map<String, dynamic> userData) async {
    try {
      final db = await database;

      // Get old values for audit log
      final oldUser = await getUserById(userId);
      final oldValues = oldUser != null ? jsonEncode(oldUser) : null;

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

      if (count > 0) {
        // Log the action
        await _logAuditAction(userId, 'UPDATE', _usersTable, userId, oldValues,
            jsonEncode(userData));
      }

      return count > 0;
    } catch (e) {
      debugPrint('Error updating user: $e');
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
        // Log the action
        await _logAuditAction(
            userId, 'DELETE', _usersTable, userId, null, null);
      }

      return count > 0;
    } catch (e) {
      debugPrint('Error deleting user: $e');
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
      debugPrint('Error toggling user status: $e');
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
      debugPrint('Error getting users by type: $e');
      return [];
    }
  }

  // Check if email exists
  Future<bool> emailExists(String email) async {
    try {
      final user = await getUserByEmail(email);
      return user != null;
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
      final user = await getUserById(userId);
      if (user == null) return false;

      final oldHashedPassword = _hashPassword(oldPassword);
      if (user['password'] != oldHashedPassword) return false;

      final newHashedPassword = _hashPassword(newPassword);
      final success = await updateUser(userId, {'password': newHashedPassword});
      return success;
    } catch (e) {
      debugPrint('Error changing password: $e');
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
      debugPrint('Error resetting password: $e');
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
      debugPrint('Error getting blood inventory: $e');
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
      debugPrint('Error getting blood inventory by group: $e');
      return null;
    }
  }

  // Update blood inventory
  Future<bool> updateBloodInventory(int id, Map<String, dynamic> data) async {
    try {
      final db = await database;

      // Get old values for audit log
      final oldInventory = await db.query(
        _bloodInventoryTable,
        where: 'id = ?',
        whereArgs: [id],
      );
      final oldValues =
          oldInventory.isNotEmpty ? jsonEncode(oldInventory.first) : null;

      data['lastUpdated'] = DateTime.now().toIso8601String();

      final count = await db.update(
        _bloodInventoryTable,
        data,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (count > 0) {
        // Log the action
        await _logAuditAction(null, 'UPDATE', _bloodInventoryTable, id,
            oldValues, jsonEncode(data));
      }

      return count > 0;
    } catch (e) {
      debugPrint('Error updating blood inventory: $e');
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
        // Log the action
        await _logAuditAction(null, 'CREATE', _bloodInventoryTable, id, null,
            jsonEncode(inventory));
      }

      return id > 0;
    } catch (e) {
      debugPrint('Error adding blood inventory: $e');
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
        // Log the action
        await _logAuditAction(
            null, 'DELETE', _bloodInventoryTable, id, null, null);
      }

      return count > 0;
    } catch (e) {
      debugPrint('Error deleting blood inventory: $e');
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
      debugPrint('Error searching blood inventory: $e');
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
      debugPrint('Error getting blood inventory summary: $e');
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
      debugPrint('Error reserving blood units: $e');
      return false;
    }
  }

  // Release reserved blood units
  Future<bool> releaseBloodUnits(String bloodGroup, int quantity) async {
    try {
      final inventory = await getBloodInventoryByGroup(bloodGroup);
      if (inventory == null) return false;

      final reservedQuantity = inventory['reservedQuantity'] as int;
      final newReservedQuantity =
          (reservedQuantity - quantity).clamp(0, reservedQuantity);

      final success = await updateBloodInventory(inventory['id'], {
        'reservedQuantity': newReservedQuantity,
      });
      return success;
    } catch (e) {
      debugPrint('Error releasing blood units: $e');
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

      // Update blood inventory
      if (id > 0) {
        await _updateBloodInventoryAfterDonation(
            donationData['bloodGroup'], donationData['quantity']);

        // Log the action
        await _logAuditAction(donationData['donorId'], 'CREATE',
            _donationsTable, id, null, jsonEncode(donation));
      }

      return id > 0;
    } catch (e) {
      debugPrint('Error adding donation: $e');
      return false;
    }
  }

  // Update blood inventory after donation
  Future<void> _updateBloodInventoryAfterDonation(
      String bloodGroup, int quantity) async {
    try {
      final inventory = await getBloodInventoryByGroup(bloodGroup);
      if (inventory != null) {
        final currentQuantity = inventory['quantity'] as int;
        await updateBloodInventory(inventory['id'], {
          'quantity': currentQuantity + quantity,
        });
      }
    } catch (e) {
      debugPrint('Error updating blood inventory after donation: $e');
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
      debugPrint('Error getting donations by donor: $e');
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
      debugPrint('Error getting all donations: $e');
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
        'doctorName': requestData['doctorName'],
        'contactNumber': requestData['contactNumber'],
        'notes': requestData['notes'],
      };

      final id = await db.insert(_requestsTable, request);

      if (id > 0) {
        // Log the action
        await _logAuditAction(requestData['requesterId'], 'CREATE',
            _requestsTable, id, null, jsonEncode(request));
      }

      return id > 0;
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
      final db = await database;
      final result = await db.query(
        _requestsTable,
        where: 'requesterId = ?',
        whereArgs: [requesterId],
        orderBy: 'requestDate DESC',
      );
      return result;
    } catch (e) {
      debugPrint('Error getting requests by requester: $e');
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
      debugPrint('Error getting all blood requests: $e');
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
        // Log the action
        await _logAuditAction(approvedBy, 'UPDATE', _requestsTable, requestId,
            null, jsonEncode({'status': 'Approved'}));
      }

      return count > 0;
    } catch (e) {
      debugPrint('Error approving blood request: $e');
      return false;
    }
  }

  // Reject blood request
  Future<bool> rejectBloodRequest(
      int requestId, int rejectedBy, String reason) async {
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
        // Log the action
        await _logAuditAction(rejectedBy, 'UPDATE', _requestsTable, requestId,
            null, jsonEncode({'status': 'Rejected'}));
      }

      return count > 0;
    } catch (e) {
      debugPrint('Error rejecting blood request: $e');
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
      debugPrint('Error getting blood request by ID: $e');
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
      debugPrint('Error adding notification: $e');
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
      debugPrint('Error getting notifications by user: $e');
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
      debugPrint('Error marking notification as read: $e');
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
      debugPrint('Error getting unread notifications count: $e');
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
      debugPrint('Error clearing notifications for user: $e');
      return false;
    }
  }

  // ===== USER SESSION OPERATIONS =====

  // Create user session
  Future<bool> createUserSession(
      int userId, String sessionToken, String deviceInfo) async {
    try {
      final db = await database;
      final session = {
        'userId': userId,
        'sessionToken': sessionToken,
        'expiresAt': DateTime.now().add(const Duration(days: 7)).toIso8601String(), // 7 days expiry
        'createdAt': DateTime.now().toIso8601String(),
      };

      final id = await db.insert(_userSessionsTable, session);
      return id > 0;
    } catch (e) {
      debugPrint('Error creating user session: $e');
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
      debugPrint('Error updating session activity: $e');
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
      debugPrint('Error invalidating user session: $e');
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
      debugPrint('Error getting user session: $e');
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
      debugPrint('Error logging audit action: $e');
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
      debugPrint('Error getting audit log: $e');
      return [];
    }
  }

  // ===== STATISTICS AND ANALYTICS =====

  // Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStatistics() async {
    try {
      final db = await database;

      // Get user counts
      final userCounts = await db.rawQuery('''
        SELECT userType, COUNT(*) as count 
        FROM $_usersTable 
        WHERE isActive = 1 
        GROUP BY userType
      ''');

      // Get blood inventory summary
      final bloodSummary = await db.rawQuery('''
        SELECT SUM(quantity) as totalUnits, COUNT(*) as bloodGroups
        FROM $_bloodInventoryTable
      ''');

      // Get recent donations
      final recentDonations = await db.rawQuery('''
        SELECT COUNT(*) as count 
        FROM $_donationsTable 
        WHERE donationDate >= datetime('now', '-7 days')
      ''');

      // Get pending requests
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
      debugPrint('Error getting dashboard statistics: $e');
      return {};
    }
  }

  // Get blood inventory statistics
  Future<Map<String, dynamic>> getBloodInventoryStatistics() async {
    try {
      final db = await database;

      // Get total units by blood group
      final bloodGroupStats = await db.rawQuery('''
        SELECT bloodGroup, SUM(quantity) as totalUnits, SUM(reservedQuantity) as reservedUnits
        FROM $_bloodInventoryTable
        GROUP BY bloodGroup
        ORDER BY bloodGroup
      ''');

      // Get low stock items
      final lowStockItems = await db.rawQuery('''
        SELECT bloodGroup, quantity, reservedQuantity
        FROM $_bloodInventoryTable
        WHERE (quantity - reservedQuantity) <= 10
        ORDER BY (quantity - reservedQuantity) ASC
      ''');

      // Get expiring items
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
      debugPrint('Error getting blood inventory statistics: $e');
      return {};
    }
  }

  // Get user activity statistics
  Future<Map<String, dynamic>> getUserActivityStatistics() async {
    try {
      final db = await database;

      // Get recent logins
      final recentLogins = await db.rawQuery('''
        SELECT u.name, u.email, u.lastLogin
        FROM $_usersTable u
        WHERE u.lastLogin IS NOT NULL
        ORDER BY u.lastLogin DESC
        LIMIT 10
      ''');

      // Get active sessions
      final activeSessions = await db.rawQuery('''
        SELECT COUNT(*) as count
        FROM $_userSessionsTable
        WHERE expiresAt > ?
      ''', [DateTime.now().toIso8601String()]);

      // Get user registrations by month
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
      debugPrint('Error getting user activity statistics: $e');
      return {};
    }
  }

  // Close database
  Future<void> close() async {
    try {
      await _database?.close();
      debugPrint('Database closed successfully');
    } catch (e) {
      debugPrint('Error closing database: $e');
    }
  }

  // Check database structure
  Future<Map<String, dynamic>> checkDatabaseStructure() async {
    try {
      debugPrint('🔍 Checking database structure...');
      final db = await database;
      
      // Check if users table exists
      final tables = await db.query('sqlite_master', 
        where: 'type = ? AND name = ?', 
        whereArgs: ['table', _usersTable]);
      
      if (tables.isEmpty) {
        debugPrint('❌ Users table not found');
        return {
          'status': 'error',
          'error': 'Users table not found',
          'message': 'Database structure is incomplete'
        };
      }
      
      // Check table columns
      final columns = await db.rawQuery('PRAGMA table_info($_usersTable)');
      final requiredColumns = [
        'id', 'name', 'email', 'password', 'userType', 
        'bloodGroup', 'age', 'contactNumber', 'address', 
        'isActive', 'lastLogin', 'createdAt', 'updatedAt'
      ];
      
      final existingColumns = columns.map((col) => col['name'] as String).toList();
      final missingColumns = requiredColumns.where((col) => !existingColumns.contains(col)).toList();
      
      if (missingColumns.isNotEmpty) {
        debugPrint('❌ Missing columns: $missingColumns');
        return {
          'status': 'error',
          'error': 'Missing columns: $missingColumns',
          'message': 'Database structure is incomplete'
        };
      }
      
      debugPrint('✅ Database structure check passed');
      return {
        'status': 'success',
        'message': 'Database structure is correct',
        'tables': ['users', 'blood_inventory', 'donations', 'blood_requests', 'notifications', 'user_sessions', 'audit_log'],
        'columns': existingColumns
      };
    } catch (e) {
      debugPrint('❌ Database structure check failed: $e');
      return {
        'status': 'error',
        'error': e.toString(),
        'message': 'Database structure check failed'
      };
    }
  }
}
