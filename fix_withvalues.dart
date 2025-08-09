import 'dart:io';

void main() async {
  print('Fixing deprecated withValues(alpha:) usage...');
  
  final files = [
    'lib/contact_page.dart',
    'lib/fix_emulator_issues.dart',
    'lib/forgot_password_page.dart',
    'lib/login_page.dart',
    'lib/notification_management_page.dart',
    'lib/receiver_page.dart',
    'lib/settings_page.dart',
    'lib/splash_screen.dart',
    'lib/signup_page.dart',
  ];

  for (final file in files) {
    await fixFile(file);
  }
  
  print('All files fixed successfully!');
}

Future<void> fixFile(String filePath) async {
  try {
    final file = File(filePath);
    if (!await file.exists()) {
      print('File not found: $filePath');
      return;
    }

    String content = await file.readAsString();
    
    // Replace all withValues(alpha: x) with withOpacity(x)
    content = content.replaceAllMapped(
      RegExp(r'\.withValues\(alpha:\s*([^)]+)\)'),
      (match) => '.withOpacity(${match.group(1)})',
    );
    
    await file.writeAsString(content);
    print('Fixed: $filePath');
  } catch (e) {
    print('Error fixing $filePath: $e');
  }
}
