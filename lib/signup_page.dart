import 'package:flutter/material.dart';
import 'services/data_service.dart';
import 'models/user_model.dart';
import 'theme/app_theme.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _bloodGroupController = TextEditingController();
  final _ageController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  String _userType = 'Donor';
  String _selectedBloodGroup = 'A+';
  String _gender = 'Male';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _bloodGroupController.dispose();
    _ageController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _medicalHistoryController.dispose();
    super.dispose();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppTheme.lightTextColor,
        ),
      ),
    );
  }

  Future<void> _signup() async {
    debugPrint('Signup button pressed');
    debugPrint('Name: ${_nameController.text}');
    debugPrint('Email: ${_emailController.text}');
    debugPrint('Password: ${_passwordController.text}');
    debugPrint('User Type: $_userType');
    debugPrint('Blood Group: ${_bloodGroupController.text}');
    debugPrint('Age: ${_ageController.text}');
    debugPrint('Contact: ${_contactController.text}');

    if (!mounted) return;

    // Simple validation first
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _ageController.text.isEmpty ||
        (_userType != 'Admin' && _contactController.text.isEmpty)) {
      debugPrint('Validation failed: Missing required fields');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill all required fields'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // Password confirmation validation
    if (_passwordController.text != _confirmPasswordController.text) {
      debugPrint('Validation failed: Passwords do not match');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Passwords do not match'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // Age validation
    final age = int.tryParse(_ageController.text);
    if (age == null || age < 18 || age > 65) {
      debugPrint('Validation failed: Invalid age');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Age must be between 18 and 65'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    debugPrint('Validation passed, starting signup process');

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('Creating DataService instance');
      final dataService = DataService();
      debugPrint('Checking if email already exists...');
      // Check if email already exists
      final existingUser = await dataService.getUserByEmail(
        _emailController.text.trim(),
      );

      if (!mounted) return;

      if (existingUser != null) {
        debugPrint('Email already registered: ${_emailController.text.trim()}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Email already registered'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }

      debugPrint('Email is available, creating new user...');

      // Create new user
      debugPrint('Creating UserModel instance...');
      final now = DateTime.now().toIso8601String();
      final newUser = UserModel(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        userType: _userType,
        bloodGroup: _selectedBloodGroup,
        age: int.tryParse(_ageController.text) ?? 0,
        contactNumber: _userType == 'Admin'
            ? 'N/A'
            : _contactController.text.trim(),
        createdAt: now,
        updatedAt: now,
      );

      debugPrint('UserModel created: ${newUser.name} (${newUser.email})');
      debugPrint('Calling dataService.createUser...');

      final success = await dataService.createUser(newUser);

      debugPrint('User creation result: $success');

      if (!mounted) return;

      if (success) {
        debugPrint('User created successfully, showing success message');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Account created successfully! Welcome, ${_nameController.text}!',
            ),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        debugPrint('User creation failed, showing error message');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create account. Please try again.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      debugPrint('Signup error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signup failed: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      debugPrint('Signup process completed, setting loading to false');
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

                // Personal Information Section
                _buildSectionTitle('Personal Information'),
                
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name *',
                    prefixIcon: const Icon(Icons.person),
                    filled: true,
                    fillColor: AppTheme.cardColor,
                  ),
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email Address *',
                    prefixIcon: const Icon(Icons.email),
                    filled: true,
                    fillColor: AppTheme.cardColor,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                
                // Gender Selection
                DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: InputDecoration(
                    labelText: 'Gender *',
                    prefixIcon: const Icon(Icons.person_outline),
                    filled: true,
                    fillColor: AppTheme.cardColor,
                  ),
                  items: ['Male', 'Female', 'Other']
                      .map((gender) => DropdownMenuItem(
                            value: gender,
                            child: Text(gender),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _gender = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _ageController,
                  decoration: InputDecoration(
                    labelText: 'Age * (18-65)',
                    prefixIcon: const Icon(Icons.cake),
                    filled: true,
                    fillColor: AppTheme.cardColor,
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                
                // Blood Information Section
                _buildSectionTitle('Blood Information'),
                
                DropdownButtonFormField<String>(
                  value: _selectedBloodGroup,
                  decoration: InputDecoration(
                    labelText: 'Blood Group *',
                    prefixIcon: const Icon(Icons.bloodtype),
                    filled: true,
                    fillColor: AppTheme.cardColor,
                  ),
                  items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                      .map((group) => DropdownMenuItem(
                            value: group,
                            child: Text(group),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBloodGroup = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Account Information Section
                _buildSectionTitle('Account Information'),
                
                DropdownButtonFormField<String>(
                  value: _userType,
                  decoration: InputDecoration(
                    labelText: 'User Type *',
                    prefixIcon: const Icon(Icons.person_outline),
                    filled: true,
                    fillColor: AppTheme.cardColor,
                  ),
                  items: ['Donor', 'Receiver']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _userType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password *',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
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
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password *',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: AppTheme.cardColor,
                  ),
                  obscureText: _obscureConfirmPassword,
                ),
                const SizedBox(height: 16),
                
                // Contact Information Section
                _buildSectionTitle('Contact Information'),
                
                TextFormField(
                  controller: _contactController,
                  decoration: InputDecoration(
                    labelText: 'Contact Number *',
                    prefixIcon: const Icon(Icons.phone),
                    filled: true,
                    fillColor: AppTheme.cardColor,
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    prefixIcon: const Icon(Icons.location_on),
                    filled: true,
                    fillColor: AppTheme.cardColor,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _emergencyContactController,
                  decoration: InputDecoration(
                    labelText: 'Emergency Contact',
                    prefixIcon: const Icon(Icons.emergency),
                    filled: true,
                    fillColor: AppTheme.cardColor,
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                
                // Medical Information Section
                _buildSectionTitle('Medical Information'),
                
                TextFormField(
                  controller: _medicalHistoryController,
                  decoration: InputDecoration(
                    labelText: 'Medical History (Optional)',
                    prefixIcon: const Icon(Icons.medical_services),
                    filled: true,
                    fillColor: AppTheme.cardColor,
                  ),
                  maxLines: 3,
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
    );
  }
}
