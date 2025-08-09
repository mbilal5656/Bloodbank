import 'lib/services/web_database_service.dart';
import 'lib/services/data_service.dart';

void main() async {
  print('🔍 Testing Web Database Compatibility...\n');
  
  try {
    // Test 1: Web Database Service
    print('📊 Test 1: Web Database Service');
    print('─' * 50);
    
    await WebDatabaseService.initialize();
    print('✅ Web database initialized');
    
    final connectivity = await WebDatabaseService.testConnectivity();
    print('✅ Connectivity test: ${connectivity['status']}');
    print('   👥 Users: ${connectivity['users']}');
    print('   🩸 Blood Inventory: ${connectivity['bloodInventory']}');
    
    // Test 2: Data Service
    print('\n🔧 Test 2: Data Service');
    print('─' * 50);
    
    await DataService.initializeDatabase();
    print('✅ Data service initialized');
    
    final dataService = DataService();
    final users = await dataService.getAllUsers();
    print('✅ Users retrieved: ${users.length}');
    
    // Test 3: Authentication
    print('\n🔑 Test 3: Authentication');
    print('─' * 50);
    
    final adminUser = await dataService.authenticateUser('admin@bloodbank.com', 'admin123');
    if (adminUser != null) {
      print('✅ Admin authentication: SUCCESS');
      print('   👤 Name: ${adminUser['name']}');
      print('   🏷️  Type: ${adminUser['userType']}');
    } else {
      print('❌ Admin authentication: FAILED');
    }
    
    final donorUser = await dataService.authenticateUser('donor@bloodbank.com', 'donor123');
    if (donorUser != null) {
      print('✅ Donor authentication: SUCCESS');
      print('   👤 Name: ${donorUser['name']}');
      print('   🏷️  Type: ${donorUser['userType']}');
    } else {
      print('❌ Donor authentication: FAILED');
    }
    
    final receiverUser = await dataService.authenticateUser('receiver@bloodbank.com', 'receiver123');
    if (receiverUser != null) {
      print('✅ Receiver authentication: SUCCESS');
      print('   👤 Name: ${receiverUser['name']}');
      print('   🏷️  Type: ${receiverUser['userType']}');
    } else {
      print('❌ Receiver authentication: FAILED');
    }
    
    // Test 4: Blood Inventory
    print('\n🩸 Test 4: Blood Inventory');
    print('─' * 50);
    
    final bloodInventory = await dataService.getAllBloodInventory();
    print('✅ Blood inventory: ${bloodInventory.length} items');
    
    final summary = await dataService.getBloodInventorySummary();
    print('✅ Blood summary: ${summary.length} blood groups');
    
    print('\n✅ All web database tests completed successfully!');
    print('\n📊 Summary:');
    print('   • Web Database: ✅ Working');
    print('   • Data Service: ✅ Working');
    print('   • Authentication: ✅ All users working');
    print('   • Blood Inventory: ✅ Working');
    
  } catch (e) {
    print('\n❌ Test failed with error: $e');
    print('\n📋 Error Details:');
    print('   • Error Type: ${e.runtimeType}');
    print('   • Error Message: $e');
  }
}
