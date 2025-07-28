import 'package:flutter/material.dart';
import 'services/data_service.dart';
import 'notification_helper.dart';
import 'session_manager.dart';
import 'splash_screen.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'admin_page.dart';
import 'donor_page.dart';
import 'receiver_page.dart';
import 'profile_page.dart';
import 'contact_page.dart';
import 'settings_page.dart';
import 'forgot_password_page.dart';
import 'blood_inventory_page.dart';
import 'notification_management_page.dart';

// Global user session class
class UserSession {
  static String userType = '';
  static String email = '';
  static String userName = '';
  static int userId = 0;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize SQLite database with default admin user
    await DataService.initializeDatabase();

    // Initialize notifications
    await NotificationHelper.initializeNotifications();

    // Load user session if exists
    final sessionData = await SessionManager.getSessionData();
    if (sessionData.isNotEmpty) {
      UserSession.userId = sessionData['userId'] ?? 0;
      UserSession.email = sessionData['email'] ?? '';
      UserSession.userType = sessionData['userType'] ?? '';
      UserSession.userName = sessionData['userName'] ?? '';
    }

    debugPrint('Blood Bank App initialized successfully');
  } catch (e) {
    debugPrint('Error initializing app: $e');
    // Continue with app launch even if there are initialization errors
  }

  runApp(const BloodBankApp());
}

class BloodBankApp extends StatelessWidget {
  const BloodBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blood Bank Management System',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/admin': (context) => const AdminPage(),
        '/donor': (context) => const DonorPage(),
        '/receiver': (context) => const ReceiverPage(),
        '/profile': (context) => const ProfilePage(),
        '/contact': (context) => const ContactPage(),
        '/settings': (context) => const SettingsPage(),
        '/forgot_password': (context) => const ForgotPasswordPage(),
        '/blood_inventory': (context) => const BloodInventoryPage(),
        '/notification_management': (context) =>
            const NotificationManagementPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

// Enhanced Blood Inventory with database integration
class BloodInventory {
  static final DataService _dataService = DataService();

  static Future<Map<String, int>> getBloodStock() async {
    try {
      return await _dataService.getBloodInventorySummary();
    } catch (e) {
      debugPrint('Error getting blood stock: $e');
      return {};
    }
  }

  static Future<bool> checkBloodAvailability(String bloodType) async {
    try {
      final inventory = await _dataService.getBloodInventoryByGroup(bloodType);
      return inventory != null && inventory.isAvailable;
    } catch (e) {
      debugPrint('Error checking blood availability: $e');
      return false;
    }
  }

  static Future<bool> updateBloodStock(String bloodType, int quantity) async {
    try {
      final inventory = await _dataService.getBloodInventoryByGroup(bloodType);
      if (inventory != null) {
        return await _dataService.updateBloodInventory(inventory.id!, {
          'quantity': quantity,
        });
      }
      return false;
    } catch (e) {
      debugPrint('Error updating blood stock: $e');
      return false;
    }
  }
}

// Enhanced Donor Eligibility Checker with database integration
class DonorEligibility {
  static final DataService _dataService = DataService();

  static Future<bool> checkEligibility(
    int age,
    String bloodType, {
    bool hasRecentDonation = false,
  }) async {
    try {
      // Check age requirements
      if (age < 18 || age > 65) return false;

      // Check recent donation
      if (hasRecentDonation) return false;

      // Check blood type availability
      final isAvailable = await BloodInventory.checkBloodAvailability(
        bloodType,
      );
      return isAvailable;
    } catch (e) {
      debugPrint('Error checking donor eligibility: $e');
      return false;
    }
  }

  static Future<bool> checkDonorHistory(int donorId) async {
    try {
      final donations = await _dataService.getDonationsByDonor(donorId);
      if (donations.isEmpty) return true;

      // Check if last donation was within 3 months
      final lastDonation = donations.first;
      final lastDonationDate = DateTime.parse(lastDonation['donationDate']);
      final threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));

      return lastDonationDate.isBefore(threeMonthsAgo);
    } catch (e) {
      debugPrint('Error checking donor history: $e');
      return false;
    }
  }
}

// Database utility functions
class DatabaseUtils {
  static final DataService _dataService = DataService();

  // Get database statistics
  static Future<Map<String, dynamic>> getDatabaseStats() async {
    try {
      return await _dataService.getDatabaseStats();
    } catch (e) {
      debugPrint('Error getting database stats: $e');
      return {};
    }
  }

  // Validate user data
  static bool validateUserData(Map<String, dynamic> userData) {
    return DataService.validateUserData(userData);
  }

  // Validate blood inventory data
  static bool validateBloodInventoryData(Map<String, dynamic> inventoryData) {
    return DataService.validateBloodInventoryData(inventoryData);
  }

  // Close database connection
  static Future<void> closeDatabase() async {
    try {
      await _dataService.close();
    } catch (e) {
      debugPrint('Error closing database: $e');
    }
  }
}
