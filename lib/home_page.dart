import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Blood Bank'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A237E), Color(0xFF3949AB), Color(0xFF5C6BC0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                // Hero Icon
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Icon(
                    Icons.bloodtype,
                    color: const Color(0xFF1A237E),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Donate Blood, Save Lives',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Join our community to help those in need',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Navigation Buttons
                _HomeButton(
                  icon: Icons.login,
                  label: 'Login',
                  color: const Color(0xFF4CAF50),
                  onTap: () => Navigator.pushNamed(context, '/login'),
                ),
                const SizedBox(height: 10),
                _HomeButton(
                  icon: Icons.person_add,
                  label: 'Sign Up',
                  color: const Color(0xFF2196F3),
                  onTap: () => Navigator.pushNamed(context, '/signup'),
                ),
                const SizedBox(height: 10),
                _HomeButton(
                  icon: Icons.contact_support,
                  label: 'Contact Us',
                  color: const Color(0xFFFF9800),
                  onTap: () => Navigator.pushNamed(context, '/contact'),
                ),
                const SizedBox(height: 16),
                // New Features Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Quick Features',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _FeatureCard(
                            icon: Icons.bloodtype,
                            label: 'Check\nAvailability',
                            onTap: () =>
                                Navigator.pushNamed(context, '/receiver'),
                          ),
                          _FeatureCard(
                            icon: Icons.volunteer_activism,
                            label: 'Donor\nEligibility',
                            onTap: () => Navigator.pushNamed(context, '/donor'),
                          ),
                          _FeatureCard(
                            icon: Icons.notifications,
                            label: 'Get\nAlerts',
                            onTap: () => _showNotificationDialog(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '"The gift of blood is the gift of life."',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white60,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: const Text(
          'Stay updated with blood donation alerts and emergency requests. This feature will be available soon!',
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
}

class _HomeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _HomeButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 18, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? const Color(0xFF1A237E),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 3,
        ),
        onPressed: onTap,
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
