import 'package:flutter/material.dart';
import 'notification_helper.dart';
import 'main.dart' show UserSession;
import 'utils/secure_code_generator.dart';

class DonorPage extends StatefulWidget {
  const DonorPage({super.key});

  @override
  State<DonorPage> createState() => _DonorPageState();
}

class _DonorPageState extends State<DonorPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _bloodGroupController = TextEditingController();
  final _lastDonationController = TextEditingController();
  final _contactController = TextEditingController();

  List<Map<String, dynamic>> _notifications = [];
  int _unreadNotificationsCount = 0;
  bool _isEligible = false;
  String? _donationCode;
  String _selectedBloodGroup = 'A+';

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _bloodGroupController.dispose();
    _lastDonationController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    try {
      final notifications = await NotificationHelper.getNotificationsForUser(
        UserSession.userId,
      );
      final unreadCount = await NotificationHelper.getUnreadNotificationsCount(
        UserSession.userId,
      );
      setState(() {
        _notifications = notifications;
        _unreadNotificationsCount = unreadCount;
      });
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: _notifications.isEmpty
              ? const Center(child: Text('No notifications available'))
              : ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    final isRead = notification['isRead'] ?? false;
                    final type = notification['type'] ?? 'info';
                    
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getNotificationColor(type),
                        child: Icon(
                          _getNotificationIcon(type),
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        notification['title'] ?? '',
                        style: TextStyle(
                          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(notification['message'] ?? ''),
                      onTap: () {
                        NotificationHelper.showNotificationDialog(
                          context,
                          notification['title'] ?? '',
                          notification['message'] ?? '',
                        );
                        if (!isRead) {
                          NotificationHelper.markNotificationAsRead(
                            notification['id'],
                          );
                          _loadNotifications();
                        }
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type.toLowerCase()) {
      case 'success':
        return Colors.green;
      case 'error':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'info':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'success':
        return Icons.check_circle;
      case 'error':
        return Icons.error;
      case 'warning':
        return Icons.warning;
      case 'info':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  void _checkEligibility() {
    if (!_formKey.currentState!.validate()) return;

    final age = int.tryParse(_ageController.text) ?? 0;
    final lastDonation = _lastDonationController.text;

    // Basic eligibility check
    final isAgeValid = age >= 18 && age <= 65;
    final hasRecentDonation = lastDonation.isNotEmpty;

    setState(() {
      _isEligible = isAgeValid && !hasRecentDonation;
      if (_isEligible) {
        _donationCode = SecureCodeGenerator.generateDonationCode();
      } else {
        _donationCode = null;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEligible
              ? 'You are eligible to donate blood!'
              : 'You are not eligible to donate blood.',
        ),
        backgroundColor: _isEligible ? Colors.green : Colors.red,
      ),
    );
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

    // Here you would typically submit the donation to the backend
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
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: _showNotificationsDialog,
                icon: const Icon(Icons.notifications),
              ),
              if (_unreadNotificationsCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      '$_unreadNotificationsCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
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
                Card(
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
                                value: _selectedBloodGroup,
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
                                  setState(() {
                                    _selectedBloodGroup = value!;
                                  });
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
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _checkEligibility,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF1A237E),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
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
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      child: const Text('Submit Donation'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isEligible && _donationCode != null) ...[
                  const SizedBox(height: 16),
                  Card(
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
                  ),
                ],
                const SizedBox(height: 16),
                Card(
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
                ),
              ],
            ),
          ),
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
