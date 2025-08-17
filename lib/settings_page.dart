import 'package:flutter/material.dart';
import 'main.dart' show NavigationUtils;
import 'theme_manager.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _biometricEnabled = false;
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    final currentTheme = ThemeManager.currentThemeData;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: currentTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showHelpDialog();
            },
            tooltip: 'Help',
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildSettingsSections(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(Icons.settings, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 20),
        const Text(
          'Settings',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Customize your app experience',
          style: TextStyle(fontSize: 16, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildSettingsSections() {
    return Column(
      children: [
        _buildSection(
          title: 'Notifications',
          icon: Icons.notifications,
          children: [
            _buildSwitchTile(
              title: 'Push Notifications',
              subtitle: 'Receive notifications for blood requests and updates',
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() => _notificationsEnabled = value);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? 'Notifications enabled'
                          : 'Notifications disabled',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSection(
          title: 'Appearance',
          icon: Icons.palette,
          children: [
            _buildThemeTile(),
            const SizedBox(height: 16),
            _buildSwitchTile(
              title: 'Dark Mode',
              subtitle: 'Use dark theme for better visibility',
              value: _darkModeEnabled,
              onChanged: (value) {
                setState(() => _darkModeEnabled = value);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value ? 'Dark mode enabled' : 'Dark mode disabled',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSection(
          title: 'Security',
          icon: Icons.security,
          children: [
            _buildSwitchTile(
              title: 'Biometric Login',
              subtitle: 'Use fingerprint or face ID to login',
              value: _biometricEnabled,
              onChanged: (value) {
                setState(() => _biometricEnabled = value);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? 'Biometric login enabled'
                          : 'Biometric login disabled',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSection(
          title: 'Language',
          icon: Icons.language,
          children: [
            _buildDropdownTile(
              title: 'App Language',
              subtitle: 'Choose your preferred language',
              value: _language,
              items: const [
                'English',
                'Spanish',
                'French',
                'German',
                'Chinese',
              ],
              onChanged: (value) {
                setState(() => _language = value!);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Language changed to $value'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSection(
          title: 'Support',
          icon: Icons.help_outline,
          children: [
            _buildActionTile(
              title: 'Help & FAQ',
              subtitle: 'Get help and find answers',
              icon: Icons.help,
              onTap: () {
                _showHelpAndFAQDialog();
              },
            ),
            _buildActionTile(
              title: 'Contact Support',
              subtitle: 'Get in touch with our team',
              icon: Icons.contact_support,
              onTap: () => NavigationUtils.navigateToContact(context),
            ),
            _buildActionTile(
              title: 'About App',
              subtitle: 'Version 1.0.0',
              icon: Icons.info_outline,
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Blood Bank Management System',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Icon(Icons.bloodtype),
                  children: const [
                    Text(
                      'A comprehensive blood bank management system designed to connect donors and receivers efficiently.',
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSection(
          title: 'Data & Privacy',
          icon: Icons.privacy_tip,
          children: [
            _buildActionTile(
              title: 'Privacy Policy',
              subtitle: 'Read our privacy policy',
              icon: Icons.privacy_tip,
              onTap: () {
                _showPrivacyPolicyDialog();
              },
            ),
            _buildActionTile(
              title: 'Terms of Service',
              subtitle: 'Read our terms of service',
              icon: Icons.description,
              onTap: () {
                _showTermsOfServiceDialog();
              },
            ),
            _buildActionTile(
              title: 'Clear Data',
              subtitle: 'Clear all app data',
              icon: Icons.delete_forever,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear Data'),
                    content: const Text(
                      'Are you sure you want to clear all app data? This action cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Data cleared successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.white,
          activeTrackColor: Colors.white.withValues(alpha: 0.3),
          inactiveThumbColor: Colors.white70,
          inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
        ),
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        trailing: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          dropdownColor: const Color(0xFF1A237E),
          style: const TextStyle(color: Colors.white),
          underline: Container(),
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white70, size: 20),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white70,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildThemeTile() {
    final currentTheme = ThemeManager.currentThemeData;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(Icons.palette, color: Colors.white70, size: 20),
        title: Text(
          'App Theme',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          'Current: ${currentTheme.name}',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: currentTheme.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 16,
            ),
          ],
        ),
        onTap: () {
          Navigator.pushNamed(context, '/theme_selection');
        },
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Text(
          'If you need assistance, please contact our support team or visit our FAQ section.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelpAndFAQDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A237E),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.help_outline,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Help & FAQ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHelpSection(
                        title: 'Getting Started',
                        icon: Icons.play_circle_outline,
                        items: [
                          'How to create an account',
                          'How to log in and out',
                          'Understanding the dashboard',
                          'Navigating the app',
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildHelpSection(
                        title: 'Blood Donation',
                        icon: Icons.volunteer_activism,
                        items: [
                          'How to register as a donor',
                          'Blood donation process',
                          'Donation eligibility requirements',
                          'Donation history tracking',
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildHelpSection(
                        title: 'Blood Requests',
                        icon: Icons.bloodtype,
                        items: [
                          'How to request blood',
                          'Request status tracking',
                          'Emergency blood requests',
                          'Request approval process',
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildHelpSection(
                        title: 'Account Management',
                        icon: Icons.person_outline,
                        items: [
                          'Updating profile information',
                          'Changing password',
                          'Notification preferences',
                          'Privacy settings',
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildHelpSection(
                        title: 'Support & Contact',
                        icon: Icons.support_agent,
                        items: [
                          'Email: support@bloodbank.com',
                          'Phone: +1 (555) 123-4567',
                          'Live chat available 24/7',
                          'Response time: Within 2 hours',
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpSection({
    required String title,
    required IconData icon,
    required List<String> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: const Color(0xFF1A237E)),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_right, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item, style: const TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A237E),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.privacy_tip,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Privacy Policy',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPolicySection(
                        title: 'Information We Collect',
                        content:
                            'We collect personal information such as your name, email address, blood type, and contact information when you register for our service.',
                      ),
                      const SizedBox(height: 16),
                      _buildPolicySection(
                        title: 'How We Use Your Information',
                        content:
                            'Your information is used to facilitate blood donation matching, manage your account, and provide customer support. We do not sell or share your personal information with third parties.',
                      ),
                      const SizedBox(height: 16),
                      _buildPolicySection(
                        title: 'Data Security',
                        content:
                            'We implement industry-standard security measures to protect your personal information. All data is encrypted and stored securely.',
                      ),
                      const SizedBox(height: 16),
                      _buildPolicySection(
                        title: 'Your Rights',
                        content:
                            'You have the right to access, update, or delete your personal information at any time. You can also opt out of certain communications.',
                      ),
                      const SizedBox(height: 16),
                      _buildPolicySection(
                        title: 'Contact Us',
                        content:
                            'If you have any questions about our privacy policy, please contact us at privacy@bloodbank.com',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolicySection({required String title, required String content}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  void _showTermsOfServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A237E),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.description, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Terms of Service',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTermsSection(
                        title: 'Acceptance of Terms',
                        content: 'By using our blood bank management system, you agree to be bound by these terms and conditions. If you do not agree to these terms, please do not use our service.',
                      ),
                      const SizedBox(height: 16),
                      _buildTermsSection(
                        title: 'Service Description',
                        content: 'Our service facilitates blood donation matching between donors and recipients. We provide a platform for blood banks, hospitals, and individuals to manage blood inventory and requests.',
                      ),
                      const SizedBox(height: 16),
                      _buildTermsSection(
                        title: 'User Responsibilities',
                        content: 'Users are responsible for providing accurate information, maintaining the security of their accounts, and complying with all applicable laws and regulations related to blood donation.',
                      ),
                      const SizedBox(height: 16),
                      _buildTermsSection(
                        title: 'Prohibited Activities',
                        content: 'Users may not use our service for illegal purposes, provide false information, or attempt to gain unauthorized access to our systems.',
                      ),
                      const SizedBox(height: 16),
                      _buildTermsSection(
                        title: 'Limitation of Liability',
                        content: 'We are not liable for any damages arising from the use of our service, including but not limited to medical complications or errors in blood matching.',
                      ),
                      const SizedBox(height: 16),
                      _buildTermsSection(
                        title: 'Changes to Terms',
                        content: 'We reserve the right to modify these terms at any time. Users will be notified of significant changes via email or in-app notifications.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermsSection({
    required String title,
    required String content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
