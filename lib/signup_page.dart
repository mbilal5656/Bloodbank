import 'package:flutter/material.dart';
import 'db_helper.dart';

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

    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _bloodGroupController.text.isEmpty ||
        _ageController.text.isEmpty ||
        (_userType != 'Admin' && _contactController.text.isEmpty)) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      // Check if email already exists
      final existingUser = await DatabaseHelper().getUserByEmail(
        _emailController.text.trim(),
      );

      if (!mounted) return;

      if (existingUser != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email already registered')),
        );
        return;
      }

      // Create new user
      await DatabaseHelper().insertUser({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'userType': _userType,
        'bloodGroup': _bloodGroupController.text.trim(),
        'age': int.tryParse(_ageController.text) ?? 0,
        'contactNumber': _userType == 'Admin'
            ? ''
            : _contactController.text.trim(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Account created successfully! Welcome, ${_nameController.text}!',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signup failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
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
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.person, color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.2),
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
                TextFormField(
                  controller: _bloodGroupController,
                  decoration: InputDecoration(
                    labelText: 'Blood Group (e.g., A+)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(
                      Icons.bloodtype,
                      color: Colors.white70,
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.2),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your blood group';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ageController,
                  decoration: InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.cake, color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.2),
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.person_outline, color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.2),
                  ),
                  items: ['Donor', 'Receiver', 'Admin']
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.phone, color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.2),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (_userType != 'Admin' &&
                          (value == null || value.isEmpty)) {
                        return 'Please enter your contact number';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _signup,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Color(0xFF1A237E),
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: const Text(
                    'Already have an account? Login',
                    style: TextStyle(color: Colors.white70),
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
