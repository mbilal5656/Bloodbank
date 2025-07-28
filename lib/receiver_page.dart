import 'package:flutter/material.dart';
import 'utils/secure_code_generator.dart';
import 'notification_helper.dart';
import 'session_manager.dart';
import 'theme/app_theme.dart';

class ReceiverPage extends StatefulWidget {
  const ReceiverPage({super.key});

  @override
  State<ReceiverPage> createState() => _ReceiverPageState();
}

class _ReceiverPageState extends State<ReceiverPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bloodGroupController = TextEditingController();
  final _contactController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _urgencyController = TextEditingController();
  final _verificationCodeController = TextEditingController();

  String _selectedBloodGroup = 'A+';
  String _selectedUrgency = 'Normal';
  String? _requestCode;
  bool _isAvailable = false;
  bool _isLoading = false;
  List<Map<String, dynamic>> _notifications = [];
  int _unreadNotificationsCount = 0;

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];
  final List<String> _urgencyLevels = ['Normal', 'Urgent', 'Emergency'];

  // Simulated blood inventory
  final Map<String, int> _bloodInventory = {
    'A+': 15,
    'A-': 8,
    'B+': 12,
    'B-': 5,
    'AB+': 6,
    'AB-': 3,
    'O+': 20,
    'O-': 10,
  };

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bloodGroupController.dispose();
    _contactController.dispose();
    _hospitalController.dispose();
    _urgencyController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    try {
      final userType = await SessionManager.getUserType();
      if (userType != null) {
        final notifications =
            await NotificationHelper.getNotificationsByUserType(userType);
        final unreadCount =
            await NotificationHelper.getUnreadNotificationsCount(userType);
        setState(() {
          _notifications = notifications;
          _unreadNotificationsCount = unreadCount;
        });
      }
    } catch (e) {
      // Handle error silently
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
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            NotificationHelper.getNotificationColor(
                              notification['type'],
                            ),
                        child: Icon(
                          NotificationHelper.getNotificationIcon(
                            notification['type'],
                          ),
                          color: AppTheme.lightTextColor,
                        ),
                      ),
                      title: Text(
                        notification['title'],
                        style: TextStyle(
                          fontWeight: notification['read']
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(notification['message']),
                      onTap: () {
                        NotificationHelper.showNotificationDialog(
                          context,
                          notification,
                        );
                        if (!notification['read']) {
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

  void _checkAvailability() {
    if (!_formKey.currentState!.validate()) return;

    final availableUnits = _bloodInventory[_selectedBloodGroup] ?? 0;
    final isUrgent =
        _selectedUrgency == 'Urgent' || _selectedUrgency == 'Emergency';

    setState(() {
      _isAvailable = availableUnits > 0;
      if (_isAvailable) {
        _requestCode = SecureCodeGenerator.generateVerificationCode();
      } else {
        _requestCode = null;
      }
    });

    // Show urgency-specific message
    String message = _isAvailable
        ? 'Blood is available! $availableUnits units in stock.'
        : 'Blood is currently not available. We will notify you when it becomes available.';

    if (isUrgent && _isAvailable) {
      message += ' (Priority processing for urgent request)';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _isAvailable ? Colors.green : Colors.orange,
      ),
    );
  }

  void _submitRequest() {
    if (!_isAvailable || _requestCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please check availability first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_verificationCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the verification code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });

      _showRequestSubmittedDialog();
    });
  }

  void _showRequestSubmittedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Submitted!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your blood request has been submitted successfully.'),
            const SizedBox(height: 16),
            Text('Request Code: $_requestCode'),
            const SizedBox(height: 8),
            Text('Verification Code: ${_verificationCodeController.text}'),
            const SizedBox(height: 8),
            const Text(
              'Please save these codes. You will need them to track your request.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receiver Dashboard'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.lightTextColor,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () => _showNotificationsDialog(),
                tooltip: 'Notifications',
              ),
              if (_unreadNotificationsCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_unreadNotificationsCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final navigator = Navigator.of(context);
              await SessionManager.clearSession();
              if (mounted) {
                navigator.pushReplacementNamed('/login');
              }
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppTheme.primaryGradientDecoration,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header
                  Icon(Icons.bloodtype, size: 80, color: Colors.white),
                  const SizedBox(height: 20),
                  Text(
                    'Blood Request Form',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Request blood for medical needs',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Form Fields
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Patient Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Colors.white70,
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.2),
                      labelStyle: const TextStyle(color: Colors.white70),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter patient name';
                      }
                      if (value.length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _selectedBloodGroup,
                    decoration: InputDecoration(
                      labelText: 'Required Blood Group',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(
                        Icons.bloodtype,
                        color: Colors.white70,
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.2),
                      labelStyle: const TextStyle(color: Colors.white70),
                    ),
                    dropdownColor: const Color(0xFF1A237E),
                    style: const TextStyle(color: Colors.white),
                    items: _bloodGroups
                        .map(
                          (group) => DropdownMenuItem(
                            value: group,
                            child: Text(group),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBloodGroup = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _contactController,
                    decoration: InputDecoration(
                      labelText: 'Contact Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(
                        Icons.phone,
                        color: Colors.white70,
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.2),
                      labelStyle: const TextStyle(color: Colors.white70),
                    ),
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter contact number';
                      }
                      final cleanNumber = value.replaceAll(
                        RegExp(r'[\s\-\(\)]'),
                        '',
                      );
                      if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(cleanNumber)) {
                        return 'Please enter a valid contact number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _hospitalController,
                    decoration: InputDecoration(
                      labelText: 'Hospital/Clinic Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(
                        Icons.local_hospital,
                        color: Colors.white70,
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.2),
                      labelStyle: const TextStyle(color: Colors.white70),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter hospital name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _selectedUrgency,
                    decoration: InputDecoration(
                      labelText: 'Urgency Level',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(
                        Icons.priority_high,
                        color: Colors.white70,
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.2),
                      labelStyle: const TextStyle(color: Colors.white70),
                    ),
                    dropdownColor: const Color(0xFF1A237E),
                    style: const TextStyle(color: Colors.white),
                    items: _urgencyLevels
                        .map(
                          (level) => DropdownMenuItem(
                            value: level,
                            child: Text(level),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedUrgency = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // Availability Status
                  if (_requestCode != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Blood Available',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Request Code: $_requestCode',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _verificationCodeController,
                      decoration: InputDecoration(
                        labelText: 'Enter Verification Code',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(
                          Icons.security,
                          color: Colors.white70,
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.2),
                        labelStyle: const TextStyle(color: Colors.white70),
                        hintText: 'Enter 8-digit verification code',
                        hintStyle: const TextStyle(color: Colors.white54),
                      ),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.text,
                      maxLength: 8,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter verification code';
                        }
                        if (value.length < 8) {
                          return 'Verification code must be 8 characters';
                        }
                        if (!SecureCodeGenerator.isValidSecureCode(value)) {
                          return 'Invalid verification code format';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Buttons
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _checkAvailability,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Check Availability',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_isAvailable) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                                'Submit Request',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Blood Inventory Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Blood Inventory:',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._bloodInventory.entries.map(
                          (entry) =>
                              _buildInventoryItem(entry.key, entry.value),
                        ),
                      ],
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

  Widget _buildInventoryItem(String bloodType, int units) {
    final isLow = units < 5;
    final isCritical = units < 2;

    Color statusColor = Colors.green;
    if (isCritical) {
      statusColor = Colors.red;
    } else if (isLow) {
      statusColor = Colors.orange;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$bloodType:',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$units units',
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Icon(
            isCritical
                ? Icons.warning
                : (isLow ? Icons.info : Icons.check_circle),
            color: statusColor,
            size: 16,
          ),
        ],
      ),
    );
  }
}
