import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'db_helper.dart';
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
import 'theme/app_theme.dart';

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
    // Initialize database with default admin user
    await DatabaseHelper.initializeDatabase();

    // Initialize notifications
    await NotificationHelper.initializeNotifications();

    // Load user session if exists
    final sessionData = await SessionManager.getSessionData();
    if (sessionData != null) {
      UserSession.userId = sessionData['userId'] ?? 0;
      UserSession.email = sessionData['email'] ?? '';
      UserSession.userType = sessionData['userType'] ?? '';
      UserSession.userName = sessionData['userName'] ?? '';
    }
  } catch (e) {
    print('Error initializing app: $e');
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

// Simulated Blood Inventory
class BloodInventory {
  static const Map<String, int> bloodStock = {
    'A+': 10,
    'A-': 5,
    'B+': 8,
    'B-': 3,
    'AB+': 4,
    'AB-': 2,
    'O+': 12,
    'O-': 6,
  };

  static bool checkBloodAvailability(String bloodType) {
    return bloodStock.containsKey(bloodType) && bloodStock[bloodType]! > 0;
  }
}

// Donor Eligibility Checker
class DonorEligibility {
  static bool checkEligibility(
    int age,
    String bloodType, {
    bool hasRecentDonation = false,
  }) {
    return age >= 18 &&
        age <= 65 &&
        !hasRecentDonation &&
        BloodInventory.bloodStock.containsKey(bloodType);
  }
}
