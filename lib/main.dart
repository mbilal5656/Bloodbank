import 'package:flutter/material.dart';
import 'dart:async';
import 'splash_screen.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'db_helper.dart';
import 'session_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.initializeDatabase();
  runApp(const BloodBankApp());
}

class BloodBankApp extends StatelessWidget {
  const BloodBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blood Bank',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        primaryColor: const Color(0xFF1A237E),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A237E),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A237E),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/donor': (context) => const DonorPage(),
        '/receiver': (context) => const ReceiverPage(),
        '/admin': (context) => const AdminPage(),
      },
    );
  }
}

// Simple user session (for backward compatibility)
class UserSession {
  static String? userType;
  static String? email;
}

// Simulated Blood Inventory
class BloodInventory {
  static const Map<String, int> bloodStock = {
    'A+': 10,
    'A-': 5,
    'B+': 8,
    'B-': 3,
    'AB+': 4,
    'AB-': 2,
    'O+': 12,
    'O-': 6,
  };

  static bool checkBloodAvailability(String bloodType) {
    return bloodStock.containsKey(bloodType) && bloodStock[bloodType]! > 0;
  }
}

// Donor Eligibility Checker
class DonorEligibility {
  static bool checkEligibility(
    int age,
    String bloodType, {
    bool hasRecentDonation = false,
  }) {
    return age >= 18 &&
        age <= 65 &&
        !hasRecentDonation &&
        BloodInventory.bloodStock.containsKey(bloodType);
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
    bool isEligible = DonorEligibility.checkEligibility(
      age,
      bloodType,
      hasRecentDonation: _hasRecentDonation,
    );
    setState(() {
      _eligibilityResult = isEligible
          ? 'You are eligible to donate!'
          : 'You are not eligible to donate.';
    });
  }

  @override
  Widget build(BuildContext context) {
    // Access control: only Donor can access
    if (UserSession.userType != 'Donor') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const SizedBox.shrink();
    }
    return Scaffold(
      backgroundColor: Colors.indigo[50],
      appBar: AppBar(
        title: const Text('Donor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final navigator = Navigator.of(context);
              await SessionManager.clearSession();
              if (!mounted) return;
              navigator.pushReplacementNamed('/login');
            },
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
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF1A237E),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _bloodTypeController,
              decoration: InputDecoration(
                labelText: 'Blood Type (e.g., A+)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.bloodtype),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ageController,
              decoration: InputDecoration(
                labelText: 'Age',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.cake),
                filled: true,
                fillColor: Colors.white,
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
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _checkEligibility,
                child: const Text(
                  'Check Eligibility',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            if (_eligibilityResult != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _eligibilityResult!.contains('eligible')
                      ? Colors.green[50]
                      : Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _eligibilityResult!.contains('eligible')
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                child: Text(
                  _eligibilityResult!,
                  style: TextStyle(
                    color: _eligibilityResult!.contains('eligible')
                        ? Colors.green[800]
                        : Colors.red[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
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

  void _checkBloodAvailability() {
    if (_bloodTypeController.text.isEmpty) {
      setState(() {
        _availabilityResult = 'Please enter a blood type';
      });
      return;
    }
    String bloodType = _bloodTypeController.text.trim();
    bool isAvailable = BloodInventory.checkBloodAvailability(bloodType);
    setState(() {
      _availabilityResult = isAvailable
          ? '$bloodType is available! Units: ${BloodInventory.bloodStock[bloodType]}'
          : '$bloodType is not available.';
    });
  }

  @override
  Widget build(BuildContext context) {
    // Access control: only Receiver can access
    if (UserSession.userType != 'Receiver') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const SizedBox.shrink();
    }
    return Scaffold(
      backgroundColor: Colors.indigo[50],
      appBar: AppBar(
        title: const Text('Receiver Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final navigator = Navigator.of(context);
              await SessionManager.clearSession();
              if (!mounted) return;
              navigator.pushReplacementNamed('/login');
            },
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
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF1A237E),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _bloodTypeController,
              decoration: InputDecoration(
                labelText: 'Blood Type (e.g., A+)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.bloodtype),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _checkBloodAvailability,
                child: const Text(
                  'Check Availability',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            if (_availabilityResult != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _availabilityResult!.contains('available')
                      ? Colors.green[50]
                      : Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _availabilityResult!.contains('available')
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                child: Text(
                  _availabilityResult!,
                  style: TextStyle(
                    color: _availabilityResult!.contains('available')
                        ? Colors.green[800]
                        : Colors.red[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
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
  final Map<String, int> _bloodStock = Map<String, int>.from(
    BloodInventory.bloodStock,
  );
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await DatabaseHelper().getAllUsers();
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  Future<void> _editStock(String bloodType) async {
    if (!mounted) return;

    final controller = TextEditingController(
      text: _bloodStock[bloodType]?.toString() ?? '0',
    );
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
      setState(() {
        _bloodStock[bloodType] = newValue;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Updated $bloodType stock to $newValue'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _deleteStock(String bloodType) {
    setState(() {
      _bloodStock.remove(bloodType);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted $bloodType from inventory'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _deleteUser(int userId) async {
    if (!mounted) return;

    final success = await DatabaseHelper().deleteUser(userId);

    if (!mounted) return;

    if (!mounted) return;

    if (success) {
      await _loadUsers();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete user'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (UserSession.userType != 'Admin') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const SizedBox.shrink();
    }
    return Scaffold(
      backgroundColor: Colors.indigo[50],
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final navigator = Navigator.of(context);
              await SessionManager.clearSession();
              if (!mounted) return;
              navigator.pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Blood Inventory Status',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF1A237E),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: _bloodStock.entries.map((entry) {
                        return Card(
                          child: ListTile(
                            leading: const Icon(
                              Icons.bloodtype,
                              color: Colors.red,
                            ),
                            title: Text(entry.key),
                            subtitle: Text('Units Available: ${entry.value}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () => _editStock(entry.key),
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _deleteStock(entry.key),
                                  tooltip: 'Delete',
                                ),
                                entry.value > 0
                                    ? const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      )
                                    : const Icon(
                                        Icons.error,
                                        color: Colors.red,
                                      ),
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
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF1A237E),
                      fontWeight: FontWeight.bold,
                    ),
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
                              color: user['userType'] == 'Admin'
                                  ? Colors.blue
                                  : Colors.black,
                            ),
                            title: Text(
                              '${user['name']} (${user['userType']})',
                            ),
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
                            trailing: user['userType'] != 'Admin'
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _deleteUser(user['id']),
                                    tooltip: 'Delete User',
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
