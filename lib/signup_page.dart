import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'theme/app_theme.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _bloodGroupController = TextEditingController();
  final _ageController = TextEditingController();
  final _contactController = TextEditingController();
  String _userType = 'Donor';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bloodGroupController.dispose();
    _ageController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!mounted) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if email already exists
      final existingUser = await DatabaseHelper().getUserByEmail(
        _emailController.text.trim(),
      );

      if (!mounted) return;

      if (existingUser != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Email already registered'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }

      // Create new user
      final success = await DatabaseHelper().insertUser({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'userType': _userType,
        'bloodGroup': _bloodGroupController.text.trim(),
        'age': int.tryParse(_ageController.text) ?? 0,
        'contactNumber': _userType == 'Admin'
            ? 'N/A'
            : _contactController.text.trim(),
      });

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Account created successfully! Welcome, ${_nameController.text}!',
            ),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create account. Please try again.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signup failed: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
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
        decoration: AppTheme.primaryGradientDecoration,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Form(
              key: _formKey,
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
                      Icons.person_add,
                      size: 50,
                      color: AppTheme.primaryColor,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Create Account',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.lightTextColor,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Join our blood bank community',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTextColor.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: const Icon(Icons.person),
                      filled: true,
                      fillColor: AppTheme.cardColor,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      filled: true,
                      fillColor: AppTheme.cardColor,
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
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      filled: true,
                      fillColor: AppTheme.cardColor,
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
                  TextFormField(
                    controller: _bloodGroupController,
                    decoration: InputDecoration(
                      labelText: 'Blood Group (e.g., A+)',
                      prefixIcon: const Icon(Icons.bloodtype),
                      filled: true,
                      fillColor: AppTheme.cardColor,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your blood group';
                      }
                      final validBloodGroups = [
                        'A+',
                        'A-',
                        'B+',
                        'B-',
                        'AB+',
                        'AB-',
                        'O+',
                        'O-',
                      ];
                      if (!validBloodGroups.contains(value.toUpperCase())) {
                        return 'Please enter a valid blood group (A+, A-, B+, B-, AB+, AB-, O+, O-)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _ageController,
                    decoration: InputDecoration(
                      labelText: 'Age',
                      prefixIcon: const Icon(Icons.cake),
                      filled: true,
                      fillColor: AppTheme.cardColor,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your age';
                      }
                      int? age = int.tryParse(value);
                      if (age == null || age < 18 || age > 65) {
                        return 'Age must be between 18 and 65';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _userType,
                    decoration: InputDecoration(
                      labelText: 'User Type',
                      prefixIcon: const Icon(Icons.person_outline),
                      filled: true,
                      fillColor: AppTheme.cardColor,
                    ),
                    items: ['Donor', 'Receiver']
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _userType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_userType != 'Admin')
                    TextFormField(
                      controller: _contactController,
                      decoration: InputDecoration(
                        labelText: 'Contact Number',
                        prefixIcon: const Icon(Icons.phone),
                        filled: true,
                        fillColor: AppTheme.cardColor,
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (_userType != 'Admin' &&
                            (value == null || value.isEmpty)) {
                          return 'Please enter your contact number';
                        }
                        if (value != null && value.isNotEmpty) {
                          // Remove spaces and special characters for validation
                          final cleanNumber = value.replaceAll(
                            RegExp(r'[\s\-\(\)]'),
                            '',
                          );
                          if (!RegExp(
                            r'^\+?[0-9]{10,15}$',
                          ).hasMatch(cleanNumber)) {
                            return 'Please enter a valid contact number (10-15 digits)';
                          }
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signup,
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
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: Text(
                      'Already have an account? Login',
                      style: TextStyle(
                        color: AppTheme.lightTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
