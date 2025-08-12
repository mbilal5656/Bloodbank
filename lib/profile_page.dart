import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main.dart' show UserSession, NavigationUtils;
import 'services/data_service.dart';
import 'session_manager.dart';
import 'theme/theme_provider.dart';
import 'theme_manager.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();
  final _bloodGroupController = TextEditingController();

  Map<String, dynamic> _userData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final dataService = DataService();
      final user = await dataService.getUserById(UserSession.userId ?? 0);

      if (user != null) {
        setState(() {
          _userData = user;
          _nameController.text = user['name'] ?? '';
          _emailController.text = user['email'] ?? '';
          _ageController.text = (user['age'] ?? '').toString();
          _contactController.text = user['contactNumber'] ?? '';
          _addressController.text = user['address'] ?? '';
          _bloodGroupController.text = user['bloodGroup'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _editProfile() {
    // TODO: Implement edit profile functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit profile functionality coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _logout() async {
    await SessionManager.clearSession();
    UserSession.userType = '';
    UserSession.email = '';
    UserSession.email = '';
    UserSession.userName = '';
    UserSession.userId = 0;

    if (mounted) {
      NavigationUtils.navigateToHome(context);
    }
  }

  void _showThemeSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildThemeSelector(),
    );
  }

  Widget _buildThemeSelector() {
    final currentTheme = context.watch<ThemeProvider>().currentAppTheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: currentTheme.surfaceColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Icon(Icons.palette, color: currentTheme.primaryColor),
                const SizedBox(width: 12),
                Text(
                  'Choose Theme',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: currentTheme.textColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: currentTheme.textColor),
                ),
              ],
            ),
          ),

          // Theme grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: ThemeManager.themes.length,
                itemBuilder: (context, index) {
                  final themeKey = ThemeManager.availableThemes[index];
                  final theme = ThemeManager.themes[themeKey]!;
                  final isSelected = ThemeManager.currentTheme == themeKey;

                  return GestureDetector(
                    onTap: () async {
                      await ThemeManager.changeTheme(themeKey);
                      // Notify the theme provider to update
                      context.read<ThemeProvider>().notifyListeners();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Theme changed to ${theme.name}'),
                          backgroundColor: theme.primaryColor,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: currentTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? theme.primaryColor
                              : Colors.grey.shade300,
                          width: isSelected ? 3 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Theme preview
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                colors: [
                                  theme.primaryColor,
                                  theme.secondaryColor,
                                  theme.accentColor,
                                ],
                              ),
                            ),
                            child: Icon(
                              Icons.bloodtype,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            theme.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: currentTheme.textColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.primaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Active',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Bottom padding
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: () => _showThemeSelector(),
            tooltip: 'Change Theme',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => NavigationUtils.navigateToSettings(context),
            tooltip: 'Settings',
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
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      _buildProfileHeader(),
                      const SizedBox(height: 32),
                      _buildProfileInfo(),
                      const SizedBox(height: 32),
                      _buildActions(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
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
          child: Icon(
            _getUserTypeIcon(_userData['userType'] ?? ''),
            size: 60,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          _userData['name'] ?? 'Unknown User',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _getUserTypeColor(
              _userData['userType'] ?? '',
            ).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _getUserTypeColor(_userData['userType'] ?? ''),
              width: 1,
            ),
          ),
          child: Text(
            _userData['userType'] ?? 'Unknown',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _getUserTypeColor(_userData['userType'] ?? ''),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          _buildInfoRow('Email', _userData['email'] ?? 'N/A', Icons.email),
          _buildInfoRow(
            'Blood Group',
            _userData['bloodGroup'] ?? 'N/A',
            Icons.bloodtype,
          ),
          _buildInfoRow(
            'Age',
            '${_userData['age'] ?? 'N/A'} years',
            Icons.calendar_today,
          ),
          _buildInfoRow(
            'Contact',
            _userData['contactNumber'] ?? 'N/A',
            Icons.phone,
          ),
          _buildInfoRow(
            'Member Since',
            _formatDate(_userData['createdAt']),
            Icons.person_add,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        _buildActionCard(
          icon: Icons.settings,
          title: 'Settings',
          subtitle: 'Manage your account settings',
          onTap: () => NavigationUtils.navigateToSettings(context),
        ),
        const SizedBox(height: 16),
        _buildActionCard(
          icon: Icons.security,
          title: 'Change Password',
          subtitle: 'Update your password',
          onTap: () {
            // TODO: Implement change password functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Change password functionality coming soon!'),
                backgroundColor: Colors.blue,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        _buildActionCard(
          icon: Icons.help_outline,
          title: 'Help & Support',
          subtitle: 'Get help and contact support',
          onTap: () => NavigationUtils.navigateToContact(context),
        ),
        const SizedBox(height: 16),
        _buildActionCard(
          icon: Icons.logout,
          title: 'Logout',
          subtitle: 'Sign out of your account',
          onTap: _logout,
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDestructive ? Colors.red.withValues(alpha: 0.7) : Colors.white70,
            fontSize: 12,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: isDestructive ? Colors.red : Colors.white70,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  IconData _getUserTypeIcon(String userType) {
    switch (userType.toLowerCase()) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'donor':
        return Icons.volunteer_activism;
      case 'receiver':
        return Icons.person;
      default:
        return Icons.person;
    }
  }

  Color _getUserTypeColor(String userType) {
    switch (userType.toLowerCase()) {
      case 'admin':
        return Colors.blue;
      case 'donor':
        return Colors.red;
      case 'receiver':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }
}
