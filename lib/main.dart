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
import 'theme/app_theme.dart';

import 'db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.initializeDatabase();
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
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/donor': (context) => const DonorPage(),
        '/receiver': (context) => const ReceiverPage(),
        '/admin': (context) => const AdminPage(),
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
