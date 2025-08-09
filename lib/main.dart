import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'splash_screen.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'forgot_password_page.dart';
import 'admin_page.dart';
import 'donor_page.dart';
import 'receiver_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'contact_page.dart';
import 'blood_inventory_page.dart';
import 'notification_management_page.dart';
import 'notification_helper.dart';
import 'session_manager.dart';
import 'db_helper.dart';
import 'services/data_service.dart';
import 'theme/theme_provider.dart';
import 'analytics_dashboard.dart';
import 'qr_code_scanner.dart';
import 'search_filter_page.dart';
import 'theme_manager.dart';
import 'theme_selection_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  try {
    await DataService.initializeDatabase();
    debugPrint('Database initialized successfully');
  } catch (e) {
    debugPrint('Error initializing database: $e');
  }

  // Initialize theme
  try {
    await ThemeManager.initializeTheme();
    debugPrint('Theme initialized successfully');
  } catch (e) {
    debugPrint('Error initializing theme: $e');
  }

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Start the app immediately
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const BloodBankApp(),
    ),
  );
}

class BloodBankApp extends StatelessWidget {
  const BloodBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Blood Bank Management System',
          debugShowCheckedModeBanner: false,
          theme: ThemeManager.getThemeData(),
          home: const SplashScreen(),
          routes: {
            '/home': (context) => const HomePage(),
            '/login': (context) => const LoginPage(),
            '/signup': (context) => const SignupPage(),
            '/forgot-password': (context) => const ForgotPasswordPage(),
            '/admin': (context) => const AdminPage(),
            '/donor': (context) => const DonorPage(),
            '/receiver': (context) => const ReceiverPage(),
            '/profile': (context) => const ProfilePage(),
            '/settings': (context) => const SettingsPage(),
            '/contact': (context) => const ContactPage(),
            '/blood_inventory': (context) => const BloodInventoryPage(),
            '/blood-inventory': (context) => const BloodInventoryPage(),
            '/notification_management': (context) =>
                const NotificationManagementPage(),
            '/notification-management': (context) =>
                const NotificationManagementPage(),
            '/analytics': (context) => const AnalyticsDashboard(),
            '/qr_scanner': (context) => const QRCodeScanner(),
            '/search_filter': (context) => const SearchFilterPage(),
            '/theme_selection': (context) => const ThemeSelectionPage(),
            // Add user-specific routes
            '/user/Admin': (context) => const AdminPage(),
            '/user/Donor': (context) => const DonorPage(),
            '/user/Receiver': (context) => const ReceiverPage(),
          },
        );
      },
    );
  }
}

// Global session management
class UserSession {
  static int? userId;
  static String? email;
  static String? userType;
  static String? userName;
  static bool isLoggedIn = false;

  static void clear() {
    userId = null;
    email = null;
    userType = null;
    userName = null;
    isLoggedIn = false;
  }

  static void update({
    required int id,
    required String userEmail,
    required String type,
    required String name,
  }) {
    userId = id;
    email = userEmail;
    userType = type;
    userName = name;
    isLoggedIn = true;
  }
}

// Navigation utilities
class NavigationUtils {
  static void navigateToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  static void navigateToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  static void navigateToUserPage(BuildContext context, String userType) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/user/$userType',
      (route) => false,
    );
  }

  static void navigateToPage(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }

  static void navigateBack(BuildContext context) {
    Navigator.pop(context);
  }

  static void navigateToProfile(BuildContext context) {
    Navigator.pushNamed(context, '/profile');
  }

  static void navigateToSettings(BuildContext context) {
    Navigator.pushNamed(context, '/settings');
  }

  static void navigateToContact(BuildContext context) {
    Navigator.pushNamed(context, '/contact');
  }

  static void navigateToBloodInventory(BuildContext context) {
    Navigator.pushNamed(context, '/blood-inventory');
  }

  static void navigateToNotificationManagement(BuildContext context) {
    Navigator.pushNamed(context, '/notifications');
  }

  static Future<void> logout(BuildContext context) async {
    try {
      // Clear session
      await SessionManager.clearSession();
      UserSession.clear();

      // Cancel all notifications
      await NotificationHelper.cancelAllScheduledNotifications();

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      debugPrint('Error during logout: $e');
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  static void showErrorDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static void showSuccessDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static void showConfirmationDialog(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}

// Utility functions
class AppUtils {
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static String formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  static String getBloodGroupColor(String bloodGroup) {
    switch (bloodGroup.toUpperCase()) {
      case 'A+':
      case 'A-':
        return '#FF4444';
      case 'B+':
      case 'B-':
        return '#44FF44';
      case 'AB+':
      case 'AB-':
        return '#4444FF';
      case 'O+':
      case 'O-':
        return '#FFAA44';
      default:
        return '#888888';
    }
  }

  static String getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'critical':
        return '#FF0000';
      case 'urgent':
        return '#FF6600';
      case 'normal':
        return '#00AA00';
      default:
        return '#888888';
    }
  }

  static String getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'approved':
        return '#00AA00';
      case 'pending':
        return '#FFAA00';
      case 'rejected':
      case 'cancelled':
        return '#FF0000';
      default:
        return '#888888';
    }
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    return RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(phone);
  }

  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
