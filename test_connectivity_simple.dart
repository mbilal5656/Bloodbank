import 'dart:io';
import 'lib/db_helper.dart';
import 'lib/services/data_service.dart';
import 'lib/session_manager.dart';

void main() async {
  print('🔍 Starting comprehensive connectivity and database test...\n');
  
  // Test 1: Database Initialization
  await testDatabaseInitialization();
  
  // Test 2: Database Structure
  await testDatabaseStructure();
  
  // Test 3: Data Service Operations
  await testDataServiceOperations();
  
  // Test 4: Session Management
  await testSessionManagement();
  
  // Test 5: User Authentication Flow
  await testUserAuthenticationFlow();
  
  // Test 6: Page Database Operations
  await testPageDatabaseOperations();
  
  print('\n✅ All tests completed!');
}

Future<void> testDatabaseInitialization() async {
  print('📊 Test 1: Database Initialization');
  print('─' * 50);
  
  try {
    await DatabaseHelper.initializeDatabaseFactory();
    print('✅ Database factory initialized');
    
    await DatabaseHelper.initializeDatabase();
    print('✅ Database initialized successfully');
    
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    print('✅ Database connection established');
    
    final tables = await db.query('sqlite_master', where: 'type = ?', whereArgs: ['table']);
    print('✅ Found ${tables.length} tables in database');
    
    for (final table in tables) {
      print('   📋 Table: ${table['name']}');
    }
    
  } catch (e) {
    print('❌ Database initialization failed: $e');
  }
  print('');
}

Future<void> testDatabaseStructure() async {
  print('🏗️  Test 2: Database Structure');
  print('─' * 50);
  
  try {
    final dbHelper = DatabaseHelper();
    final structure = await dbHelper.checkDatabaseStructure();
    
    if (structure['status'] == 'success') {
      print('✅ Database structure is correct');
      print('   📋 Tables: ${structure['tables']}');
      print('   📋 Columns: ${structure['columns']?.length} columns in users table');
    } else {
      print('❌ Database structure issues:');
      print('   Error: ${structure['error']}');
      print('   Message: ${structure['message']}');
    }
    
  } catch (e) {
    print('❌ Database structure test failed: $e');
  }
  print('');
}

Future<void> testDataServiceOperations() async {
  print('🔧 Test 3: Data Service Operations');
  print('─' * 50);
  
  try {
    final dataService = DataService();
    
    // Test connectivity
    final connectivity = await dataService.testDatabaseConnectivity();
    if (connectivity['status'] == 'success') {
      print('✅ Database connectivity test passed');
      print('   👥 Users: ${connectivity['users']}');
      print('   🩸 Blood Inventory: ${connectivity['bloodInventory']}');
      print('   📊 Tables: ${connectivity['tables']}');
    } else {
      print('❌ Database connectivity test failed: ${connectivity['error']}');
    }
    
    // Test user operations
    final users = await dataService.getAllUsers();
    print('✅ User operations: ${users.length} users found');
    
    // Test blood inventory operations
    final bloodInventory = await dataService.getAllBloodInventory();
    print('✅ Blood inventory operations: ${bloodInventory.length} items found');
    
    // Test donations
    final donations = await dataService.getAllDonations();
    print('✅ Donation operations: ${donations.length} donations found');
    
    // Test blood requests
    final requests = await dataService.getAllBloodRequests();
    print('✅ Blood request operations: ${requests.length} requests found');
    
  } catch (e) {
    print('❌ Data service operations test failed: $e');
  }
  print('');
}

Future<void> testSessionManagement() async {
  print('🔐 Test 4: Session Management');
  print('─' * 50);
  
  try {
    // Test session creation
    final testSession = {
      'userId': 1,
      'email': 'test@example.com',
      'userType': 'Admin',
      'userName': 'Test User',
    };
    
    await SessionManager.saveSessionData(testSession);
    print('✅ Session data saved');
    
    // Test session retrieval
    final retrievedSession = await SessionManager.getSessionData();
    if (retrievedSession.isNotEmpty) {
      print('✅ Session data retrieved successfully');
      print('   👤 User: ${retrievedSession['userName']}');
      print('   📧 Email: ${retrievedSession['email']}');
      print('   🏷️  Type: ${retrievedSession['userType']}');
    } else {
      print('❌ Session data retrieval failed');
    }
    
    // Test session clearing
    await SessionManager.clearSession();
    final clearedSession = await SessionManager.getSessionData();
    if (clearedSession.isEmpty) {
      print('✅ Session cleared successfully');
    } else {
      print('❌ Session clearing failed');
    }
    
  } catch (e) {
    print('❌ Session management test failed: $e');
  }
  print('');
}

Future<void> testUserAuthenticationFlow() async {
  print('🔑 Test 5: User Authentication Flow');
  print('─' * 50);
  
  try {
    final dataService = DataService();
    
    // Test admin authentication
    final adminUser = await dataService.authenticateUser('admin@bloodbank.com', 'admin123');
    if (adminUser != null) {
      print('✅ Admin authentication successful');
      print('   👤 Name: ${adminUser['name']}');
      print('   🏷️  Type: ${adminUser['userType']}');
    } else {
      print('❌ Admin authentication failed');
    }
    
    // Test donor authentication
    final donorUser = await dataService.authenticateUser('donor@bloodbank.com', 'donor123');
    if (donorUser != null) {
      print('✅ Donor authentication successful');
      print('   👤 Name: ${donorUser['name']}');
      print('   🏷️  Type: ${donorUser['userType']}');
    } else {
      print('❌ Donor authentication failed');
    }
    
    // Test receiver authentication
    final receiverUser = await dataService.authenticateUser('receiver@bloodbank.com', 'receiver123');
    if (receiverUser != null) {
      print('✅ Receiver authentication successful');
      print('   👤 Name: ${receiverUser['name']}');
      print('   🏷️  Type: ${receiverUser['userType']}');
    } else {
      print('❌ Receiver authentication failed');
    }
    
    // Test invalid authentication
    final invalidUser = await dataService.authenticateUser('invalid@example.com', 'wrongpassword');
    if (invalidUser == null) {
      print('✅ Invalid authentication correctly rejected');
    } else {
      print('❌ Invalid authentication should have been rejected');
    }
    
  } catch (e) {
    print('❌ User authentication flow test failed: $e');
  }
  print('');
}

Future<void> testPageDatabaseOperations() async {
  print('📱 Test 6: Page Database Operations');
  print('─' * 50);
  
  try {
    final dataService = DataService();
    
    final pages = [
      'home',
      'admin',
      'donor',
      'receiver',
      'blood_inventory',
      'profile'
    ];
    
    for (final page in pages) {
      final result = await dataService.testPageDatabaseOperations(page);
      if (result['status'] == 'success') {
        print('✅ $page page: ${result['operations']} operations working');
        print('   📊 Results: ${result['results']}');
      } else {
        print('❌ $page page: ${result['error']}');
      }
    }
    
  } catch (e) {
    print('❌ Page database operations test failed: $e');
  }
  print('');
}
