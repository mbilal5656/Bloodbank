import 'package:flutter/material.dart';

import 'main.dart' show UserSession, NavigationUtils;
import 'services/data_service.dart';

class DonorPage extends StatefulWidget {
  const DonorPage({super.key});

  @override
  State<DonorPage> createState() => _DonorPageState();
}

class _DonorPageState extends State<DonorPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _lastDonationController = TextEditingController();
  final _contactController = TextEditingController();

  bool _isEligible = false;
  String? _donationCode;
  String _selectedBloodGroup = 'A+';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _lastDonationController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _checkEligibility() async {
    try {
      debugPrint('🔍 Checking donor eligibility...');
      final dataService = DataService();

      // Get user data
      final user = await dataService.getUserById(UserSession.userId ?? 0);
      if (user != null) {
        debugPrint('✅ User data retrieved: ${user['name']}');

        // Check age requirement
        final age = user['age'] ?? 0;
        final isAgeEligible = age >= 18 && age <= 65;

        // Check last donation (if any)
        final donations = await dataService.getDonationsByDonor(
          UserSession.userId ?? 0,
        );
        final lastDonation = donations.isNotEmpty ? donations.last : null;

        final isEligible =
            isAgeEligible &&
            (lastDonation == null ||
                DateTime.now()
                        .difference(
                          DateTime.parse(lastDonation['donationDate']),
                        )
                        .inDays >=
                    56);

        debugPrint(
          '📊 Eligibility check: Age=$isAgeEligible, Last donation=${lastDonation != null}',
        );

        setState(() {
          _isEligible = isEligible;
        });
      } else {
        debugPrint('❌ User data not found');
        setState(() {
          _isEligible = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error checking eligibility: $e');
      setState(() {
        _isEligible = false;
      });
    }
  }

  void _submitDonation() {
    if (_donationCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please check eligibility first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Donation submitted with code: $_donationCode'),
        backgroundColor: Colors.green,
      ),
    );

    // Clear form
    _formKey.currentState!.reset();
    setState(() {
      _isEligible = false;
      _donationCode = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donor Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => NavigationUtils.navigateToHome(context),
            tooltip: 'Home',
          ),
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
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, '/notification_management');
            },
            tooltip: 'Notifications',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async => await NavigationUtils.logout(context),
            tooltip: 'Logout',
          ),
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEligibilityForm(),
                if (_isEligible && _donationCode != null) ...[
                  const SizedBox(height: 16),
                  _buildDonationCodeCard(),
                ],
                const SizedBox(height: 16),
                _buildGuidelinesCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEligibilityForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Blood Donation Eligibility',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF1A237E),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
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
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your age';
                      }
                      final age = int.tryParse(value);
                      if (age == null || age < 18 || age > 65) {
                        return 'Age must be between 18 and 65';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedBloodGroup,
                    decoration: const InputDecoration(
                      labelText: 'Blood Group',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.bloodtype),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'A+', child: Text('A+')),
                      DropdownMenuItem(value: 'A-', child: Text('A-')),
                      DropdownMenuItem(value: 'B+', child: Text('B+')),
                      DropdownMenuItem(value: 'B-', child: Text('B-')),
                      DropdownMenuItem(value: 'AB+', child: Text('AB+')),
                      DropdownMenuItem(value: 'AB-', child: Text('AB-')),
                      DropdownMenuItem(value: 'O+', child: Text('O+')),
                      DropdownMenuItem(value: 'O-', child: Text('O-')),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedBloodGroup = value!);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select blood group';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lastDonationController,
                    decoration: const InputDecoration(
                      labelText: 'Last Donation Date (if any)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.date_range),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contactController,
                    decoration: const InputDecoration(
                      labelText: 'Contact Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter contact number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 400) {
                        // For smaller screens, stack vertically
                        return Column(
                          children: [
                            ElevatedButton(
                              onPressed: _checkEligibility,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A237E),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: const Text('Check Eligibility'),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _isEligible ? _submitDonation : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: const Text('Submit Donation'),
                            ),
                          ],
                        );
                      } else {
                        // For larger screens, use horizontal layout
                        return Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _checkEligibility,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1A237E),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text('Check Eligibility'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isEligible ? _submitDonation : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text('Submit Donation'),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationCodeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Donation Code',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                border: Border.all(color: Colors.green),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.qr_code, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    _donationCode!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please present this code at the donation center.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidelinesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Donation Guidelines',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFF1A237E),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildGuideline(
              Icons.check_circle,
              'Must be 18-65 years old',
              Colors.green,
            ),
            _buildGuideline(
              Icons.check_circle,
              'No recent donations (3 months)',
              Colors.green,
            ),
            _buildGuideline(
              Icons.check_circle,
              'Good health condition',
              Colors.green,
            ),
            _buildGuideline(
              Icons.check_circle,
              'Valid ID required',
              Colors.green,
            ),
            _buildGuideline(
              Icons.check_circle,
              'Fasting not required',
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideline(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
