// Utility script to fix deprecated withValues(alpha:) usage
// This script will be used to replace withValues(alpha:) with withOpacity()

import 'dart:io';
import 'package:flutter/foundation.dart';

void main() async {
  final files = [
    'lib/home_page.dart',
    'lib/login_page.dart',
    'lib/notification_management_page.dart',
    'lib/profile_page.dart',
    'lib/receiver_page.dart',
    'lib/settings_page.dart',
    'lib/settings_page_enhanced.dart',
    'lib/signup_page.dart',
    'lib/splash_screen.dart',
  ];

  for (final file in files) {
    await fixWithOpacity(file);
  }
  
  print('Fixed withOpacity deprecation warnings in all files');
}

Future<void> fixWithOpacity(String filePath) async {
  final file = File(filePath);
  if (!await file.exists()) {
    print('File not found: $filePath');
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
  print('Fixed: $filePath');
}