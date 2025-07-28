import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

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
        foregroundColor: AppTheme.lightTextColor,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppTheme.primaryGradientDecoration,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Hero Icon
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Icon(
                    Icons.bloodtype,
                    color: AppTheme.primaryColor,
                    size: 50,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Donate Blood, Save Lives',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.lightTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  'Join our community to help those in need',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTextColor.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Navigation Buttons
                _HomeButton(
                  icon: Icons.login,
                  label: 'Login',
                  color: AppTheme.successColor,
                  onTap: () => Navigator.pushNamed(context, '/login'),
                ),

                const SizedBox(height: 12),

                _HomeButton(
                  icon: Icons.person_add,
                  label: 'Sign Up',
                  color: AppTheme.infoColor,
                  onTap: () => Navigator.pushNamed(context, '/signup'),
                ),

                const SizedBox(height: 12),

                _HomeButton(
                  icon: Icons.contact_support,
                  label: 'Contact Us',
                  color: AppTheme.warningColor,
                  onTap: () => Navigator.pushNamed(context, '/contact'),
                ),

                const SizedBox(height: 24),

                // Quick Features Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AppTheme.glassDecoration,
                  child: Column(
                    children: [
                      Text(
                        'Quick Features',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.lightTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

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

                const SizedBox(height: 20),

                Text(
                  '"The gift of blood is the gift of life."',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTextColor.withValues(alpha: 0.6),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),
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
      height: 50,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 20, color: AppTheme.lightTextColor),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.lightTextColor,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppTheme.primaryColor,
          foregroundColor: AppTheme.lightTextColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
        width: 80,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.cardColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.cardColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.lightTextColor, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.lightTextColor,
                fontSize: 10,
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
