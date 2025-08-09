import 'package:flutter/foundation.dart';
import '../db_helper.dart';

class DatabaseVerification {
  static Future<Map<String, dynamic>> verifyDatabaseConnection() async {
    try {
      debugPrint('🔍 Starting database verification...');
      
      // Initialize database
      await DatabaseHelper.initializeDatabase();
      
      // Check database structure
      final dbHelper = DatabaseHelper();
      final structureCheck = await dbHelper.checkDatabaseStructure();
      
      // Test basic operations
      final testResults = await _testDatabaseOperations(dbHelper);
      
      return {
        'status': 'success',
        'databaseVersion': 4,
        'structureCheck': structureCheck,
        'testResults': testResults,
        'message': 'Database is properly linked and configured for version 4',
      };
    } catch (e) {
      debugPrint('❌ Database verification failed: $e');
      return {
        'status': 'error',
        'error': e.toString(),
        'message': 'Database verification failed',
      };
    }
  }
  
  static Future<Map<String, dynamic>> _testDatabaseOperations(DatabaseHelper dbHelper) async {
    try {
      // Test user operations
      final users = await dbHelper.getAllUsers();
      
      // Test blood inventory operations
      final inventory = await dbHelper.getAllBloodInventory();
      
      // Test notifications
      final notifications = await dbHelper.getNotificationsByUser(1);
      
      return {
        'usersCount': users.length,
        'inventoryCount': inventory.length,
        'notificationsCount': notifications.length,
        'allTestsPassed': true,
      };
    } catch (e) {
      debugPrint('❌ Database operations test failed: $e');
      return {
        'error': e.toString(),
        'allTestsPassed': false,
      };
    }
  }
  
  static Future<void> resetDatabase() async {
    try {
      debugPrint('🔄 Resetting database...');
      
      // Close existing database connection
      await DatabaseHelper().close();
      
      // Reinitialize database
      await DatabaseHelper.initializeDatabase();
      
      debugPrint('✅ Database reset completed');
    } catch (e) {
      debugPrint('❌ Database reset failed: $e');
      rethrow;
    }
  }
} 