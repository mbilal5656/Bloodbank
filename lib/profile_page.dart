import 'package:flutter/material.dart';
import 'main.dart' show UserSession, NavigationUtils;
import 'services/data_service.dart';
import 'session_manager.dart';


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
      debugPrint('👤 Profile page: Loading user data...');
      final dataService = DataService();
      final user = await dataService.getUserById(UserSession.userId ?? 0);

      if (user != null) {
        debugPrint('✅ User data loaded: ${user['name']}');
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
        debugPrint('❌ User data not found');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading user data: $e');
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
    UserSession.userName = '';
    UserSession.userId = 0;

    if (mounted) {
      NavigationUtils.navigateToHome(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editProfile,
            tooltip: 'Edit Profile',
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
                  child: CircularProgressIndicator(color: Colors.white))
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
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
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
            color: _getUserTypeColor(_userData['userType'] ?? '')
                .withOpacity(0.2),
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
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _buildInfoRow('Email', _userData['email'] ?? 'N/A', Icons.email),
          _buildInfoRow('Blood Group', _userData['bloodGroup'] ?? 'N/A',
              Icons.bloodtype),
          _buildInfoRow('Age', '${_userData['age'] ?? 'N/A'} years',
              Icons.calendar_today),
          _buildInfoRow(
              'Contact', _userData['contactNumber'] ?? 'N/A', Icons.phone),
          _buildInfoRow('Member Since', _formatDate(_userData['createdAt']),
              Icons.person_add),
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
              color: Colors.white.withOpacity(0.2),
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
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
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
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.withOpacity(0.2)
                : Colors.white.withOpacity(0.2),
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
            color: isDestructive
                ? Colors.red.withOpacity(0.7)
                : Colors.white70,
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
