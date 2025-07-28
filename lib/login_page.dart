import 'package:flutter/material.dart';
import 'services/data_service.dart';
import 'theme/app_theme.dart';
import 'main.dart' show UserSession;
import 'session_manager.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Simple validation first
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both email and password'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final dataService = DataService();
      // Check if user exists
      final user = await dataService.getUserByEmail(
        _emailController.text.trim(),
      );

      if (user != null) {
        // Authenticate user
        final isAuthenticated = await dataService.authenticateUser(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (isAuthenticated) {
          // Set user session
          UserSession.userType = user.userType;
          UserSession.email = user.email;
          UserSession.userName = user.name;
          UserSession.userId = user.id ?? 0;

          // Save session data
          await SessionManager.saveUserSession(
            userId: user.id ?? 0,
            email: user.email,
            userType: user.userType,
            userName: user.name,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Welcome back, ${user.name}!'),
                backgroundColor: AppTheme.successColor,
              ),
            );

            // Navigate based on user type
            switch (user.userType) {
              case 'Admin':
                Navigator.of(context).pushReplacementNamed('/admin');
                break;
              case 'Donor':
                Navigator.of(context).pushReplacementNamed('/donor');
                break;
              case 'Receiver':
                Navigator.of(context).pushReplacementNamed('/receiver');
                break;
              default:
                Navigator.of(context).pushReplacementNamed('/home');
                break;
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid email or password'),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'User not found. Please check your email or sign up.',
              ),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login error: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppTheme.primaryGradientDecoration,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // App Logo/Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.bloodtype,
                    size: 50,
                    color: AppTheme.primaryColor,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.lightTextColor,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Sign in to your account',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTextColor.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    filled: true,
                    fillColor: AppTheme.cardColor,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 16),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: AppTheme.cardColor,
                  ),
                  obscureText: _obscurePassword,
                ),

                const SizedBox(height: 8),

                // Forgot Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/forgot_password'),
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: AppTheme.lightTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: AppTheme.lightTextColor,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.lightTextColor,
                              ),
                            ),
                          )
                        : const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: AppTheme.lightTextColor.withValues(alpha: 0.8),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/signup'),
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: AppTheme.lightTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Back to Home
                TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/home'),
                  child: Text(
                    'Back to Home',
                    style: TextStyle(
                      color: AppTheme.lightTextColor.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
