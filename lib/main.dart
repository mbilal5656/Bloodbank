import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'home_page.dart';
import 'contact_page.dart';
import 'forgot_password_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'admin_page.dart';
import 'donor_page.dart';
import 'receiver_page.dart';
import 'blood_inventory_page.dart';
import 'notification_management_page.dart';
import 'notification_helper.dart';
import 'theme/app_theme.dart';

import 'db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await DatabaseHelper.initializeDatabase();
    await NotificationHelper.initializeNotifications();
  } catch (e) {
    // Handle initialization errors gracefully
    print('Initialization error: $e');
  }

  runApp(const BloodBankApp());
}

class BloodBankApp extends StatelessWidget {
  const BloodBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blood Bank Management System',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      onGenerateRoute: (settings) {
        // Handle unknown routes gracefully
        if (settings.name == '/splash') {
          return MaterialPageRoute(builder: (context) => const SplashScreen());
        }
        if (settings.name == '/login') {
          return MaterialPageRoute(builder: (context) => const LoginPage());
        }
        if (settings.name == '/signup') {
          return MaterialPageRoute(builder: (context) => const SignupPage());
        }
        if (settings.name == '/donor') {
          return MaterialPageRoute(builder: (context) => const DonorPage());
        }
        if (settings.name == '/receiver') {
          return MaterialPageRoute(builder: (context) => const ReceiverPage());
        }
        if (settings.name == '/admin') {
          return MaterialPageRoute(builder: (context) => const AdminPage());
        }
        if (settings.name == '/blood_inventory') {
          return MaterialPageRoute(
            builder: (context) => const BloodInventoryPage(),
          );
        }
        if (settings.name == '/notification_management') {
          return MaterialPageRoute(
            builder: (context) => const NotificationManagementPage(),
          );
        }
        if (settings.name == '/home') {
          return MaterialPageRoute(builder: (context) => const HomePage());
        }
        if (settings.name == '/contact') {
          return MaterialPageRoute(builder: (context) => const ContactPage());
        }
        if (settings.name == '/forgot_password') {
          return MaterialPageRoute(
            builder: (context) => const ForgotPasswordPage(),
          );
        }
        if (settings.name == '/profile') {
          return MaterialPageRoute(builder: (context) => const ProfilePage());
        }
        if (settings.name == '/settings') {
          return MaterialPageRoute(builder: (context) => const SettingsPage());
        }

        // Default fallback
        return MaterialPageRoute(builder: (context) => const HomePage());
      },
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/donor': (context) => const DonorPage(),
        '/receiver': (context) => const ReceiverPage(),
        '/admin': (context) => const AdminPage(),
        '/blood_inventory': (context) => const BloodInventoryPage(),
        '/notification_management': (context) =>
            const NotificationManagementPage(),
        '/home': (context) => const HomePage(),
        '/contact': (context) => const ContactPage(),
        '/forgot_password': (context) => const ForgotPasswordPage(),
        '/profile': (context) => const ProfilePage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}

// Simple user session (for backward compatibility)
class UserSession {
  static String? userType;
  static String? email;
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
