import 'package:flutter/material.dart';
import 'dart:async';
import 'splash_screen.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'profile_page.dart';
import 'forgot_password_page.dart';
import 'contact_page.dart';
import 'db_helper.dart';
import 'session_manager.dart';

void main() {
  runApp(const BloodBankApp());
}

class BloodBankApp extends StatelessWidget {
  const BloodBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blood Bank',
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/profile': (context) => const ProfilePage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/contact': (context) => const ContactPage(),
        '/donor': (context) => const DonorPage(),
        '/receiver': (context) => const ReceiverPage(),
        '/admin': (context) => const AdminPage(),
      },
    );
  }
}

// Donor Eligibility Checker
class DonorEligibility {
  static bool checkEligibility(int age, String bloodType, {bool hasRecentDonation = false}) {
    return age >= 18 && age <= 65 && !hasRecentDonation;
  }
}

// Donor Page
class DonorPage extends StatefulWidget {
  const DonorPage({super.key});
  @override
  State<DonorPage> createState() => _DonorPageState();
}

class _DonorPageState extends State<DonorPage> {
  final _bloodTypeController = TextEditingController();
  final _ageController = TextEditingController();
  bool _hasRecentDonation = false;
  String? _eligibilityResult;

  @override
  void dispose() {
    _bloodTypeController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _checkEligibility() {
    if (_bloodTypeController.text.isEmpty || _ageController.text.isEmpty) {
      setState(() {
        _eligibilityResult = 'Please enter valid age and blood type';
      });
      return;
    }
    int? age = int.tryParse(_ageController.text);
    String bloodType = _bloodTypeController.text.trim();
    if (age == null || bloodType.isEmpty) {
      setState(() {
        _eligibilityResult = 'Please enter valid age and blood type';
      });
      return;
    }
    bool isEligible = DonorEligibility.checkEligibility(age, bloodType, hasRecentDonation: _hasRecentDonation);
    setState(() {
      _eligibilityResult = isEligible ? 'You are eligible to donate!' : 'You are not eligible to donate.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: SessionManager.getUserType(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (snapshot.data != 'Donor') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/login');
          });
          return const SizedBox.shrink();
        }
        
        return Scaffold(
          backgroundColor: Colors.red[50],
          appBar: AppBar(
            title: const Text('Donor Dashboard'),
            actions: [
              IconButton(
                icon: const Icon(Icons.contact_support),
                onPressed: () => Navigator.pushNamed(context, '/contact'),
                tooltip: 'Contact Us',
              ),
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () => Navigator.pushNamed(context, '/profile'),
                tooltip: 'Profile',
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Check Donation Eligibility',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _bloodTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Blood Type (e.g., A+)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.bloodtype),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.cake),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Donated in the last 3 months'),
                  value: _hasRecentDonation,
                  onChanged: (value) {
                    setState(() {
                      _hasRecentDonation = value!;
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _checkEligibility,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Check Eligibility'),
                ),
                if (_eligibilityResult != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    _eligibilityResult!,
                    style: TextStyle(
                      color: _eligibilityResult!.contains('eligible') ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// Receiver Page
class ReceiverPage extends StatefulWidget {
  const ReceiverPage({super.key});
  @override
  State<ReceiverPage> createState() => _ReceiverPageState();
}

class _ReceiverPageState extends State<ReceiverPage> {
  final _bloodTypeController = TextEditingController();
  String? _availabilityResult;

  @override
  void dispose() {
    _bloodTypeController.dispose();
    super.dispose();
  }

  Future<void> _checkBloodAvailability() async {
    if (_bloodTypeController.text.isEmpty) {
      setState(() {
        _availabilityResult = 'Please enter a blood type';
      });
      return;
    }
    String bloodType = _bloodTypeController.text.trim();
    bool isAvailable = await DatabaseHelper().checkBloodAvailability(bloodType);
    int units = await DatabaseHelper().getBloodUnits(bloodType);
    setState(() {
      _availabilityResult = isAvailable
          ? '$bloodType is available! Units: $units'
          : '$bloodType is not available.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: SessionManager.getUserType(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (snapshot.data != 'Receiver') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/login');
          });
          return const SizedBox.shrink();
        }
        
        return Scaffold(
          backgroundColor: Colors.red[50],
          appBar: AppBar(
            title: const Text('Receiver Dashboard'),
            actions: [
              IconButton(
                icon: const Icon(Icons.contact_support),
                onPressed: () => Navigator.pushNamed(context, '/contact'),
                tooltip: 'Contact Us',
              ),
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () => Navigator.pushNamed(context, '/profile'),
                tooltip: 'Profile',
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Check Blood Availability',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _bloodTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Blood Type (e.g., A+)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.bloodtype),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _checkBloodAvailability,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Check Availability'),
                ),
                if (_availabilityResult != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    _availabilityResult!,
                    style: TextStyle(
                      color: _availabilityResult!.contains('available') ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// Admin Page
class AdminPage extends StatefulWidget {
  const AdminPage({super.key});
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<Map<String, dynamic>> _bloodInventory = [];
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final bloodInventory = await DatabaseHelper().getAllBloodInventory();
    final users = await DatabaseHelper().getAllUsers();
    
    if (mounted) {
      setState(() {
        _bloodInventory = bloodInventory;
        _users = users;
        _isLoading = false;
      });
    }
  }

  Future<void> _editStock(String bloodType) async {
    if (!mounted) return;
    
    final currentInventory = _bloodInventory.firstWhere(
      (item) => item['bloodType'] == bloodType,
      orElse: () => {'units': 0},
    );
    
    final controller = TextEditingController(text: currentInventory['units']?.toString() ?? '0');
    int? newValue = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $bloodType Stock'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Units'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              int? val = int.tryParse(controller.text);
              Navigator.pop(context, val);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    
    if (!mounted) return;
    
    if (newValue != null) {
      await DatabaseHelper().updateBloodInventory(bloodType, newValue);
      await _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Updated $bloodType stock to $newValue'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _deleteStock(String bloodType) async {
    await DatabaseHelper().deleteBloodInventory(bloodType);
    await _loadData();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted $bloodType from inventory')),
      );
    }
  }

  Future<void> _deleteUser(int userId) async {
    await DatabaseHelper().deleteUser(userId);
    await _loadData();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User deleted'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: SessionManager.getUserType(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (snapshot.data != 'Admin') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/login');
          });
          return const SizedBox.shrink();
        }
        
        if (_isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        return Scaffold(
          backgroundColor: Colors.red[50],
          appBar: AppBar(
            title: const Text('Admin Dashboard'),
            actions: [
              IconButton(
                icon: const Icon(Icons.contact_support),
                onPressed: () => Navigator.pushNamed(context, '/contact'),
                tooltip: 'Contact Us',
              ),
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () => Navigator.pushNamed(context, '/profile'),
                tooltip: 'Profile',
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Blood Inventory Status',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: _bloodInventory.map((entry) {
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.bloodtype, color: Colors.red),
                          title: Text(entry['bloodType']),
                          subtitle: Text('Units Available: ${entry['units']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editStock(entry['bloodType']),
                                tooltip: 'Edit',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteStock(entry['bloodType']),
                                tooltip: 'Delete',
                              ),
                              entry['units'] > 0
                                  ? const Icon(Icons.check_circle, color: Colors.green)
                                  : const Icon(Icons.error, color: Colors.red),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Registered Users',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      return Card(
                        child: ListTile(
                          leading: Icon(
                            user['userType'] == 'Donor'
                                ? Icons.volunteer_activism
                                : user['userType'] == 'Receiver'
                                    ? Icons.person
                                    : Icons.admin_panel_settings,
                            color: user['userType'] == 'Admin' ? Colors.blue : Colors.black,
                          ),
                          title: Text('${user['name']} (${user['userType']})'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Email: ${user['email']}'),
                              Text('Blood Group: ${user['bloodGroup']}'),
                              Text('Age: ${user['age']}'),
                              if (user['userType'] != 'Admin')
                                Text('Contact: ${user['contactNumber']}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteUser(user['id']),
                            tooltip: 'Delete User',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}