import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'session_manager.dart';
import 'main.dart' show UserSession;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _userType = 'Donor'; // Default user type
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!mounted) return;

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Authenticate user using database helper
      final isAuthenticated = await DatabaseHelper().authenticateUser(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (!isAuthenticated) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid credentials')));
        return;
      }

      // Get user data
      final user = await DatabaseHelper().getUserByEmail(
        _emailController.text.trim(),
      );
      if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not found')));
        return;
      }

      // Check if user type matches
      if (user['userType'] != _userType) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid user type for this account')),
        );
        return;
      }

             // Save user session
       await SessionManager.saveUserSession(
         userId: user['id'],
         email: user['email'],
         userType: user['userType'],
         userName: user['name'],
       );

       // Set UserSession for backward compatibility
       UserSession.userType = user['userType'];
       UserSession.email = user['email'];

       // Determine route based on user type
      String route;
      switch (_userType) {
        case 'Donor':
          route = '/donor';
          break;
        case 'Receiver':
          route = '/receiver';
          break;
        case 'Admin':
          route = '/admin';
          break;
        default:
          route = '/login';
      }

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, route);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome back, ${user['name']}!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
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
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // App Logo/Icon
                Icon(Icons.bloodtype, size: 80, color: Colors.white),
                const SizedBox(height: 20),
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to your account',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 32),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.email, color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.2),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.2),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // User Type Dropdown
                DropdownButtonFormField<String>(
                  value: _userType,
                  decoration: InputDecoration(
                    labelText: 'User Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: Colors.white70,
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.2),
                  ),
                  items: ['Donor', 'Receiver', 'Admin']
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(
                            type,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _userType = value!;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1A237E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
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
                const SizedBox(height: 16),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account? ',
                      style: TextStyle(color: Colors.white70),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/signup'),
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Forgot Password Link
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/forgot-password'),
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Contact Us Link
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/contact'),
                  child: Text(
                    'Contact Us',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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
