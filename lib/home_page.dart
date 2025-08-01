import 'package:flutter/material.dart';
import 'main.dart' show UserSession, NavigationUtils;
import 'session_manager.dart';
import 'services/data_service.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoggedIn = false;
  String _userType = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      debugPrint('🏠 Home page: Checking login status...');
      final sessionData = await SessionManager.getSessionData();
      final dataService = DataService();

      if (sessionData.isNotEmpty && sessionData['userType'] != null) {
        debugPrint('✅ User is logged in: ${sessionData['userType']}');

        // Get user data from database
        final user = await dataService.getUserById(sessionData['userId'] ?? 0);
        if (user != null) {
          debugPrint('✅ User data retrieved: ${user['name']}');
          setState(() {
            _isLoggedIn = true;
            _userType = sessionData['userType'] ?? '';
            _isLoading = false;
          });
        } else {
          debugPrint('❌ User data not found in database');
          setState(() {
            _isLoggedIn = false;
            _isLoading = false;
          });
        }
      } else {
        debugPrint('❌ No active session found');
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error checking login status: $e');
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Bank Management System'),
        actions: [
          if (_isLoggedIn) ...[
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () => NavigationUtils.navigateToProfile(context),
              tooltip: 'Profile',
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => NavigationUtils.navigateToSettings(context),
              tooltip: 'Settings',
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async => await NavigationUtils.logout(context),
              tooltip: 'Logout',
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.login),
              onPressed: () => NavigationUtils.navigateToLogin(context),
              tooltip: 'Login',
            ),
          ],
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header Section
                _buildHeader(),
                const SizedBox(height: 40),

                // Loading indicator
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else ...[
                  // Welcome Message
                  if (_isLoggedIn) _buildWelcomeMessage(),
                  if (!_isLoggedIn) _buildGuestMessage(),

                  const SizedBox(height: 40),

                  // Main Action Cards
                  if (_isLoggedIn)
                    _buildUserDashboard()
                  else
                    _buildGuestActions(),

                  const SizedBox(height: 40),

                  // Features Section
                  _buildFeaturesSection(),
                ],

                const SizedBox(height: 40),



                // Contact Section
                _buildContactSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
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
          child: const Icon(
            Icons.bloodtype,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Blood Bank',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        const Text(
          'Management System',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeMessage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.person,
            size: 40,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          Text(
            'Welcome back, ${UserSession.userName?.isNotEmpty == true ? UserSession.userName : UserSession.userType ?? 'User'}!',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'You are logged in as $_userType',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestMessage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.people,
            size: 40,
            color: Colors.white,
          ),
          SizedBox(height: 12),
          Text(
            'Welcome to Blood Bank Management System',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Please login or signup to access the system',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUserDashboard() {
    return Column(
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _buildActionCard(
              icon: Icons.admin_panel_settings,
              title: 'Admin Panel',
              subtitle: 'Manage users and inventory',
              color: Colors.blue,
              onTap: () => NavigationUtils.navigateToUserPage(context, 'Admin'),
              show: _userType == 'Admin',
            ),
            _buildActionCard(
              icon: Icons.volunteer_activism,
              title: 'Donor Portal',
              subtitle: 'Donate blood',
              color: Colors.red,
              onTap: () => NavigationUtils.navigateToUserPage(context, 'Donor'),
              show: _userType == 'Donor',
            ),
            _buildActionCard(
              icon: Icons.person,
              title: 'Receiver Portal',
              subtitle: 'Request blood',
              color: Colors.green,
              onTap: () =>
                  NavigationUtils.navigateToUserPage(context, 'Receiver'),
              show: _userType == 'Receiver',
            ),
            _buildActionCard(
              icon: Icons.inventory,
              title: 'Blood Inventory',
              subtitle: 'View blood stock',
              color: Colors.orange,
              onTap: () => NavigationUtils.navigateToBloodInventory(context),
              show: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGuestActions() {
    return Column(
      children: [
        Text(
          'Get Started',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => NavigationUtils.navigateToLogin(context),
                icon: const Icon(Icons.login),
                label: const Text('Login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1A237E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/signup'),
                icon: const Icon(Icons.person_add),
                label: const Text('Sign Up'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required bool show,
  }) {
    if (!show) return const SizedBox.shrink();

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.2),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: color.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Column(
      children: [
        Text(
          'Features',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 20),
        _buildFeatureItem(
          icon: Icons.security,
          title: 'Secure Authentication',
          description: 'Safe and secure user authentication system',
        ),
        _buildFeatureItem(
          icon: Icons.inventory_2,
          title: 'Blood Inventory Management',
          description: 'Track and manage blood stock efficiently',
        ),
        _buildFeatureItem(
          icon: Icons.notifications,
          title: 'Real-time Notifications',
          description: 'Stay updated with important alerts',
        ),
        _buildFeatureItem(
          icon: Icons.analytics,
          title: 'Analytics & Reports',
          description: 'Comprehensive reporting and analytics',
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.contact_support,
            size: 40,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          const Text(
            'Need Help?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Contact our support team for assistance',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => NavigationUtils.navigateToContact(context),
            icon: const Icon(Icons.contact_mail),
            label: const Text('Contact Us'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1A237E),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
