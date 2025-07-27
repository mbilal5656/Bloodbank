import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _emailNotifications = false;
  bool _smsNotifications = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _emailNotifications = prefs.getBool('emailNotifications') ?? false;
      _smsNotifications = prefs.getBool('smsNotifications') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode);
    await prefs.setBool('notifications', _notificationsEnabled);
    await prefs.setBool('emailNotifications', _emailNotifications);
    await prefs.setBool('smsNotifications', _smsNotifications);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EAF6),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF1A237E),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Settings
            _buildSectionCard(
              title: 'Appearance',
              icon: Icons.palette,
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Switch to dark theme'),
                  value: _isDarkMode,
                  onChanged: (value) {
                    setState(() {
                      _isDarkMode = value;
                    });
                    _saveSettings();
                  },
                  secondary: const Icon(Icons.dark_mode),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Notification Settings
            _buildSectionCard(
              title: 'Notifications',
              icon: Icons.notifications,
              children: [
                SwitchListTile(
                  title: const Text('Enable Notifications'),
                  subtitle: const Text('Receive blood donation alerts'),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                      if (!value) {
                        _emailNotifications = false;
                        _smsNotifications = false;
                      }
                    });
                    _saveSettings();
                  },
                  secondary: const Icon(Icons.notifications_active),
                ),
                if (_notificationsEnabled) ...[
                  SwitchListTile(
                    title: const Text('Email Notifications'),
                    subtitle: const Text('Receive alerts via email'),
                    value: _emailNotifications,
                    onChanged: (value) {
                      setState(() {
                        _emailNotifications = value;
                      });
                      _saveSettings();
                    },
                    secondary: const Icon(Icons.email),
                  ),
                  SwitchListTile(
                    title: const Text('SMS Notifications'),
                    subtitle: const Text('Receive alerts via SMS'),
                    value: _smsNotifications,
                    onChanged: (value) {
                      setState(() {
                        _smsNotifications = value;
                      });
                      _saveSettings();
                    },
                    secondary: const Icon(Icons.sms),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Account Settings
            _buildSectionCard(
              title: 'Account',
              icon: Icons.account_circle,
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Edit Profile'),
                  subtitle: const Text('Update your personal information'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                ),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Change Password'),
                  subtitle: const Text('Update your password'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => Navigator.pushNamed(context, '/forgot-password'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Support & About
            _buildSectionCard(
              title: 'Support & About',
              icon: Icons.help,
              children: [
                ListTile(
                  leading: const Icon(Icons.contact_support),
                  title: const Text('Contact Us'),
                  subtitle: const Text('Get in touch with support'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => Navigator.pushNamed(context, '/contact'),
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('About App'),
                  subtitle: const Text('Version 1.0.0'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _showAboutDialog(),
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('Privacy Policy'),
                  subtitle: const Text('Read our privacy policy'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _showPrivacyDialog(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => _showLogoutDialog(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF1A237E)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
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

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Blood Bank'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text(
              'A comprehensive blood bank management system designed to connect donors and recipients efficiently.',
            ),
            SizedBox(height: 16),
            Text('Features:'),
            Text('• User registration and authentication'),
            Text('• Blood availability checking'),
            Text('• Donor eligibility assessment'),
            Text('• Admin dashboard for inventory management'),
            Text('• Profile management'),
          ],
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

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const Text(
          'Your privacy is important to us. We collect and store only the necessary information to provide blood bank services. Your personal data is encrypted and never shared with third parties without your consent.',
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/home');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
