import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main.dart' show NavigationUtils;
import 'theme/theme_provider.dart';
import 'services/data_service.dart';
import 'session_manager.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  bool _isLoading = false;
  Map<String, dynamic> _userInfo = {};

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      setState(() => _isLoading = true);
      final userId = await SessionManager.getUserId();
      if (userId != null) {
        final dataService = DataService();
        final user = await dataService.getUserById(userId);
        if (user != null) {
          setState(() => _userInfo = user);
        }
      }
    } catch (e) {
      debugPrint('Error loading user info: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: isDark ? Colors.white : const Color(0xFF1A237E),
              ),
            )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
                  _buildUserInfoSection(),
                  const SizedBox(height: 24),
            _buildSettingsSections(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark 
                ? [const Color(0xFF1A237E), const Color(0xFF3949AB)]
                : [const Color(0xFF1A237E), const Color(0xFF5C6BC0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A237E).withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.settings,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Settings',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: isDark ? Colors.white : const Color(0xFF1A237E),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Customize your app experience',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: isDark ? Colors.white70 : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfoSection() {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: isDark ? Colors.white : const Color(0xFF1A237E),
                ),
                const SizedBox(width: 12),
                Text(
                  'User Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: isDark ? Colors.white : const Color(0xFF1A237E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_userInfo.isNotEmpty) ...[
              _buildInfoRow('Name', _userInfo['name'] ?? 'N/A'),
              _buildInfoRow('Email', _userInfo['email'] ?? 'N/A'),
              _buildInfoRow('User Type', _userInfo['userType'] ?? 'N/A'),
              if (_userInfo['bloodGroup'] != null && _userInfo['bloodGroup'].isNotEmpty)
                _buildInfoRow('Blood Group', _userInfo['bloodGroup']),
            ] else ...[
              const Text(
                'User information not available',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSections() {
    return Column(
      children: [
        _buildAppearanceSection(),
        const SizedBox(height: 24),
        _buildNotificationSection(),
        const SizedBox(height: 24),
        _buildSecuritySection(),
        const SizedBox(height: 24),
        _buildDatabaseSection(),
        const SizedBox(height: 24),
        _buildAboutSection(),
      ],
    );
  }

  Widget _buildAppearanceSection() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.palette,
                      color: isDark ? Colors.white : const Color(0xFF1A237E),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Appearance',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: isDark ? Colors.white : const Color(0xFF1A237E),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    color: isDark ? Colors.white : const Color(0xFF1A237E),
                  ),
                  title: Text(
                    'Dark Mode',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    isDark ? 'Enabled' : 'Disabled',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                  trailing: Switch(
                    value: isDark,
                    onChanged: (value) {
                      themeProvider.toggleTheme();
                    },
                    activeColor: const Color(0xFF1A237E),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: Icon(
                    Icons.color_lens,
                    color: isDark ? Colors.white : const Color(0xFF1A237E),
                  ),
                  title: Text(
                    'Theme',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    isDark ? 'Dark Theme' : 'Light Theme',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                  onTap: () {
                    themeProvider.toggleTheme();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationSection() {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
      children: [
                Icon(
                  Icons.notifications,
                  color: isDark ? Colors.white : const Color(0xFF1A237E),
                ),
                const SizedBox(width: 12),
                Text(
                  'Notifications',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: isDark ? Colors.white : const Color(0xFF1A237E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                'Push Notifications',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Receive notifications for blood requests and updates',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
              ),
              trailing: Switch(
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() => _notificationsEnabled = value);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                        value ? 'Notifications enabled' : 'Notifications disabled',
                ),
                backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
              ),
            );
          },
                activeColor: const Color(0xFF1A237E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection() {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
      children: [
                Icon(
                  Icons.security,
                  color: isDark ? Colors.white : const Color(0xFF1A237E),
                ),
                const SizedBox(width: 12),
                Text(
                  'Security',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: isDark ? Colors.white : const Color(0xFF1A237E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                'Biometric Login',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Use fingerprint or face ID to login',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
              ),
              trailing: Switch(
          value: _biometricEnabled,
          onChanged: (value) {
            setState(() => _biometricEnabled = value);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                        value ? 'Biometric login enabled' : 'Biometric login disabled',
                ),
                backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
              ),
            );
          },
                activeColor: const Color(0xFF1A237E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatabaseSection() {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storage,
                  color: isDark ? Colors.white : const Color(0xFF1A237E),
                ),
                const SizedBox(width: 12),
                Text(
                  'Database',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: isDark ? Colors.white : const Color(0xFF1A237E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(
                Icons.health_and_safety,
                color: isDark ? Colors.white : const Color(0xFF1A237E),
              ),
              title: Text(
                'Test Database Connection',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Check database connectivity and health',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
              ),
              onTap: _testDatabaseConnection,
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                Icons.refresh,
                color: isDark ? Colors.white : const Color(0xFF1A237E),
              ),
              title: Text(
                'Refresh Data',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Reload all data from database',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
              ),
              onTap: _refreshData,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
      children: [
                Icon(
                  Icons.info_outline,
                  color: isDark ? Colors.white : const Color(0xFF1A237E),
                ),
                const SizedBox(width: 12),
                Text(
                  'About',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: isDark ? Colors.white : const Color(0xFF1A237E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(
                Icons.help,
                color: isDark ? Colors.white : const Color(0xFF1A237E),
              ),
              title: Text(
                'Help & FAQ',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Get help and find answers',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
              ),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Help functionality coming soon!'),
                backgroundColor: Colors.blue,
                    behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
            const Divider(),
            ListTile(
              leading: Icon(
                Icons.contact_support,
                color: isDark ? Colors.white : const Color(0xFF1A237E),
              ),
              title: Text(
                'Contact Support',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Get in touch with our team',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
              ),
          onTap: () => NavigationUtils.navigateToContact(context),
        ),
            const Divider(),
            ListTile(
              leading: Icon(
                Icons.info_outline,
                color: isDark ? Colors.white : const Color(0xFF1A237E),
              ),
              title: Text(
                'About App',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
              ),
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
      ),
    );
  }

  Future<void> _testDatabaseConnection() async {
    try {
      setState(() => _isLoading = true);
      
      final dataService = DataService();
      final result = await dataService.testDatabaseConnectivity();
      
      if (mounted) {
        if (result['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Database connection successful! Users: ${result['users']}, Inventory: ${result['bloodInventory']}'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Database connection failed: ${result['error']}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
      ),
    );
  }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error testing database: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshData() async {
    try {
      setState(() => _isLoading = true);
      
      // Reload user info
      await _loadUserInfo();
      
      if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data refreshed successfully!'),
                    backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
                  ),
                );
              }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error refreshing data: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
