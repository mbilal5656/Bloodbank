import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'bloodbank.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        userType TEXT NOT NULL,
        bloodGroup TEXT,
        age INTEGER,
        contactNumber TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    // Blood inventory table
    await db.execute('''
      CREATE TABLE blood_inventory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bloodType TEXT UNIQUE NOT NULL,
        units INTEGER NOT NULL,
        lastUpdated TEXT NOT NULL
      )
    ''');

    // Insert default admin user
    await db.insert('users', {
      'name': 'Admin',
      'email': 'admin@bloodbank.com',
      'password': _hashPassword('admin123'),
      'userType': 'Admin',
      'bloodGroup': 'N/A',
      'age': 30,
      'contactNumber': '1234567890',
      'createdAt': DateTime.now().toIso8601String(),
    });

    // Insert default blood inventory
    final bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    final units = [10, 5, 8, 3, 4, 2, 12, 6];
    
    for (int i = 0; i < bloodTypes.length; i++) {
      await db.insert('blood_inventory', {
        'bloodType': bloodTypes[i],
        'units': units[i],
        'lastUpdated': DateTime.now().toIso8601String(),
      });
    }
  }

  // Password hashing
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // User CRUD operations
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    user['password'] = _hashPassword(user['password']);
    user['createdAt'] = DateTime.now().toIso8601String();
    return await db.insert('users', user);
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query('users', orderBy: 'createdAt DESC');
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<bool> authenticateUser(String email, String password) async {
    final user = await getUserByEmail(email);
    if (user == null) return false;
    return user['password'] == _hashPassword(password);
  }

  Future<int> updateUser(int id, Map<String, dynamic> userData) async {
    final db = await database;
    if (userData.containsKey('password')) {
      userData['password'] = _hashPassword(userData['password']);
    }
    return await db.update(
      'users',
      userData,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> changePassword(int userId, String oldPassword, String newPassword) async {
    final user = await getUserById(userId);
    if (user == null) return false;
    
    if (user['password'] != _hashPassword(oldPassword)) {
      return false;
    }

    await updateUser(userId, {'password': newPassword});
    return true;
  }

  // Blood inventory CRUD operations
  Future<List<Map<String, dynamic>>> getAllBloodInventory() async {
    final db = await database;
    return await db.query('blood_inventory', orderBy: 'bloodType');
  }

  Future<Map<String, dynamic>?> getBloodInventoryByType(String bloodType) async {
    final db = await database;
    final results = await db.query(
      'blood_inventory',
      where: 'bloodType = ?',
      whereArgs: [bloodType],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateBloodInventory(String bloodType, int units) async {
    final db = await database;
    return await db.update(
      'blood_inventory',
      {
        'units': units,
        'lastUpdated': DateTime.now().toIso8601String(),
      },
      where: 'bloodType = ?',
      whereArgs: [bloodType],
    );
  }

  Future<int> insertBloodInventory(Map<String, dynamic> inventory) async {
    final db = await database;
    inventory['lastUpdated'] = DateTime.now().toIso8601String();
    return await db.insert('blood_inventory', inventory);
  }

  Future<int> deleteBloodInventory(String bloodType) async {
    final db = await database;
    return await db.delete(
      'blood_inventory',
      where: 'bloodType = ?',
      whereArgs: [bloodType],
    );
  }

  Future<bool> checkBloodAvailability(String bloodType) async {
    final inventory = await getBloodInventoryByType(bloodType);
    return inventory != null && inventory['units'] > 0;
  }

  Future<int> getBloodUnits(String bloodType) async {
    final inventory = await getBloodInventoryByType(bloodType);
    return inventory?['units'] ?? 0;
  }
} 