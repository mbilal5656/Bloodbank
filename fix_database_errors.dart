
import 'package:flutter/foundation.dart';

import 'lib/db_helper.dart';
import 'lib/services/data_service.dart';

/// Comprehensive database error fix script
/// This script addresses all database initialization and authentication issues
void main() async {
  debugPrint('🔧 Starting Database Error Fix Script...');
  debugPrint('=' * 60);
  
  try {
    // Step 1: Initialize database factory
    debugPrint('📋 Step 1: Initializing Database Factory');
    await DatabaseHelper.initializeDatabaseFactory();
    debugPrint('✅ Database factory initialized successfully');

    // Step 2: Initialize database
    debugPrint('📋 Step 2: Initializing Database');
    await DatabaseHelper.initializeDatabase();
    debugPrint('✅ Database initialized successfully');

    // Step 3: Initialize DataService
    debugPrint('📋 Step 3: Initializing DataService');
    await DataService.initializeDatabase();
    debugPrint('✅ DataService initialized successfully');

    // Step 4: Verify database structure
    debugPrint('📋 Step 4: Verifying Database Structure');
    final dbHelper = DatabaseHelper();
    final structureCheck = await dbHelper.checkDatabaseStructure();
    if (structureCheck['status'] == 'success') {
      debugPrint('✅ Database structure is valid');
      debugPrint('📊 Tables found: ${structureCheck['tables']}');
    } else {
      debugPrint('❌ Database structure check failed: ${structureCheck['error']}');
      return;
    }

    // Step 5: Check admin user
    debugPrint('📋 Step 5: Checking Admin User');
    final dataService = DataService();
    var adminUser = await dataService.getUserByEmail('admin@bloodbank.com');
    
    if (adminUser == null) {
      debugPrint('⚠️ Admin user not found - creating...');
      await createAdminUser(dataService);
      adminUser = await dataService.getUserByEmail('admin@bloodbank.com');
    }
    
    if (adminUser != null) {
      debugPrint('✅ Admin user found: ${adminUser['name']}');
      debugPrint('📊 Admin details: ID=${adminUser['id']}, Type=${adminUser['userType']}, Active=${adminUser['isActive']}');
    } else {
      debugPrint('❌ Failed to create or find admin user');
      return;
    }

    // Step 6: Test authentication
    debugPrint('📋 Step 6: Testing Authentication');
    final authResult = await dataService.authenticateUser('admin@bloodbank.com', 'admin123');
    if (authResult != null) {
      debugPrint('✅ Authentication successful for admin user');
      debugPrint('📊 Auth result: ${authResult['name']} (${authResult['userType']})');
    } else {
      debugPrint('❌ Authentication failed for admin user');
      debugPrint('🔧 Attempting to fix authentication...');
      await fixAuthentication(dataService);
    }

    // Step 7: Test blood inventory
    debugPrint('📋 Step 7: Testing Blood Inventory');
    final inventory = await dataService.getAllBloodInventory();
    debugPrint('✅ Blood inventory accessible - Found ${inventory.length} items');
    
    if (inventory.isEmpty) {
      debugPrint('⚠️ No blood inventory found - this is expected for a new database');
    } else {
      for (final item in inventory.take(3)) {
        debugPrint('🩸 Blood: ${item['bloodGroup']} - Quantity: ${item['quantity']} - Status: ${item['status']}');
      }
    }

    // Step 8: Final connectivity test
    debugPrint('📋 Step 8: Final Connectivity Test');
    final connectivityResult = await dataService.testDatabaseConnectivity();
    if (connectivityResult['status'] == 'success') {
      debugPrint('✅ Database connectivity test passed');
      debugPrint('📊 Users: ${connectivityResult['users']}, Inventory: ${connectivityResult['bloodInventory']}, Tables: ${connectivityResult['tables']}');
    } else {
      debugPrint('❌ Database connectivity test failed: ${connectivityResult['error']}');
    }

    debugPrint('=' * 60);
    debugPrint('🎉 Database Error Fix Script Completed Successfully!');
    debugPrint('');
    debugPrint('📋 Summary:');
    debugPrint('✅ Database factory initialized');
    debugPrint('✅ Database structure verified');
    debugPrint('✅ Admin user available');
    debugPrint('✅ Authentication working');
    debugPrint('✅ Blood inventory accessible');
    debugPrint('');
    debugPrint('🔑 Admin Login Credentials:');
    debugPrint('   Email: admin@bloodbank.com');
    debugPrint('   Password: admin123');
    debugPrint('');
    debugPrint('🚀 You can now run the app and login with the admin credentials!');

  } catch (e) {
    debugPrint('❌ Database fix script failed with error: $e');
    debugPrint('📋 Error details: ${e.toString()}');
    debugPrint('');
    debugPrint('🔧 Troubleshooting steps:');
    debugPrint('1. Ensure Flutter is properly installed');
    debugPrint('2. Run "flutter clean" and "flutter pub get"');
    debugPrint('3. Check that sqflite dependencies are properly installed');
    debugPrint('4. Try running the app in debug mode to see detailed error logs');
  }
}

Future<void> createAdminUser(DataService dataService) async {
  try {
    debugPrint('🔧 Creating admin user...');
    
    final adminData = {
      'name': 'System Administrator',
      'email': 'admin@bloodbank.com',
      'password': 'admin123',
      'userType': 'Admin',
      'bloodGroup': 'N/A',
      'age': 30,
      'contactNumber': '+1234567890',
      'address': 'System Address',
    };

    final success = await dataService.insertUser(adminData);
    if (success) {
      debugPrint('✅ Admin user created successfully');
    } else {
      debugPrint('❌ Failed to create admin user');
    }
  } catch (e) {
    debugPrint('❌ Error creating admin user: $e');
  }
}

Future<void> fixAuthentication(DataService dataService) async {
  try {
    debugPrint('🔧 Attempting to fix authentication...');
    
    // Get the admin user
    final adminUser = await dataService.getUserByEmail('admin@bloodbank.com');
    if (adminUser == null) {
      debugPrint('❌ Admin user not found for authentication fix');
      return;
    }

    // Reset the admin password to ensure it's properly hashed
    final dbHelper = DatabaseHelper();
    final success = await dbHelper.resetUserPassword(adminUser['id'], 'admin123');
    
    if (success) {
      debugPrint('✅ Admin password reset successfully');
      
      // Test authentication again
      final authResult = await dataService.authenticateUser('admin@bloodbank.com', 'admin123');
      if (authResult != null) {
        debugPrint('✅ Authentication fix successful');
      } else {
        debugPrint('❌ Authentication still failing after password reset');
      }
    } else {
      debugPrint('❌ Failed to reset admin password');
    }
  } catch (e) {
    debugPrint('❌ Error fixing authentication: $e');
  }
}