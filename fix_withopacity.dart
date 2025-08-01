import 'dart:io';
import 'package:flutter/foundation.dart';

void main() async {
  final files = [
    'lib/splash_screen.dart',
    'lib/signup_page.dart',
    'lib/settings_page.dart',
    'lib/receiver_page.dart',
    'lib/profile_page.dart',
    'lib/notification_management_page.dart',
    'lib/login_page.dart',
    'lib/home_page.dart',
    'lib/forgot_password_page.dart',
    'lib/contact_page.dart',
    'lib/blood_inventory_page.dart',
    'lib/admin_page.dart',
  ];

  for (final file in files) {
    await fixWithOpacity(file);
  }
}

Future<void> fixWithOpacity(String filePath) async {
  final file = File(filePath);
  if (!await file.exists()) {
    debugPrint('File $filePath does not exist');
    return;
  }

  String content = await file.readAsString();
  
  // Replace withOpacity with withValues
  content = content.replaceAllMapped(
    RegExp(r'\.withOpacity\(([^)]+)\)'),
    (match) {
      final opacity = match.group(1);
      return '.withValues(alpha: $opacity)';
    },
  );

  await file.writeAsString(content);
  debugPrint('Fixed $filePath');
} 