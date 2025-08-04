import 'package:flutter/material.dart';
import 'notification_helper.dart';
import 'main.dart' show UserSession, NavigationUtils;
import 'utils/secure_code_generator.dart';

class ReceiverPage extends StatefulWidget {
  const ReceiverPage({super.key});

  @override
  State<ReceiverPage> createState() => _ReceiverPageState();
}

class _ReceiverPageState extends State<ReceiverPage> {
  final _formKey = GlobalKey<FormState>();
  final _patientNameController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _contactController = TextEditingController();
  final _verificationCodeController = TextEditingController();

  List<Map<String, dynamic>> _notifications = [];
  int _unreadNotificationsCount = 0;
  bool _isAvailable = false;
  bool _isLoading = false;
  String? _requestCode;
  String _selectedBloodGroup = 'A+';
  String _selectedUrgency = 'Normal';

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
    _patientNameController.dispose();
    _hospitalController.dispose();
    _contactController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    try {
      final notifications = await NotificationHelper.getNotificationsForUser(
        UserSession.userId ?? 0,
      );
      final unreadCount = await NotificationHelper.getUnreadNotificationsCount(
        UserSession.userId ?? 0,
      );
      setState(() {
        _notifications = notifications;
        _unreadNotificationsCount = unreadCount;
      });
    } catch (e) {
      // Error handling
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
                          fontWeight:
                              isRead ? FontWeight.normal : FontWeight.bold,
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

    setState(() => _isLoading = true);

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isLoading = false);
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
          _buildNotificationButton(),
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
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildRequestForm(),
                  const SizedBox(height: 24),
                  _buildBloodInventoryCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationButton() {
    return Stack(
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
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                '$_unreadNotificationsCount',
                style: const TextStyle(color: Colors.white, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Icon(Icons.bloodtype, size: 80, color: Colors.white),
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
      ],
    );
  }

  Widget _buildRequestForm() {
    return Column(
      children: [
        _buildFormField(
          controller: _patientNameController,
          label: 'Patient Name',
          icon: Icons.person,
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
        _buildBloodGroupDropdown(),
        const SizedBox(height: 16),
        _buildFormField(
          controller: _contactController,
          label: 'Contact Number',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter contact number';
            }
            final cleanNumber = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
            if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(cleanNumber)) {
              return 'Please enter a valid contact number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildFormField(
          controller: _hospitalController,
          label: 'Hospital/Clinic Name',
          icon: Icons.local_hospital,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter hospital name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildUrgencyDropdown(),
        const SizedBox(height: 24),
        if (_requestCode != null) ...[
          _buildAvailabilityStatus(),
          const SizedBox(height: 16),
          _buildVerificationCodeField(),
          const SizedBox(height: 16),
        ],
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.2),
        labelStyle: const TextStyle(color: Colors.white70),
      ),
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildBloodGroupDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedBloodGroup,
      decoration: InputDecoration(
        labelText: 'Required Blood Group',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.bloodtype, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.2),
        labelStyle: const TextStyle(color: Colors.white70),
      ),
      dropdownColor: const Color(0xFF1A237E),
      style: const TextStyle(color: Colors.white),
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
    );
  }

  Widget _buildUrgencyDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedUrgency,
      decoration: InputDecoration(
        labelText: 'Urgency Level',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.priority_high, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.2),
        labelStyle: const TextStyle(color: Colors.white70),
      ),
      dropdownColor: const Color(0xFF1A237E),
      style: const TextStyle(color: Colors.white),
      items: const [
        DropdownMenuItem(value: 'Normal', child: Text('Normal')),
        DropdownMenuItem(value: 'Urgent', child: Text('Urgent')),
        DropdownMenuItem(value: 'Emergency', child: Text('Emergency')),
      ],
      onChanged: (value) {
        setState(() => _selectedUrgency = value!);
      },
    );
  }

  Widget _buildAvailabilityStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 32),
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
    );
  }

  Widget _buildVerificationCodeField() {
    return TextFormField(
      controller: _verificationCodeController,
      decoration: InputDecoration(
        labelText: 'Enter Verification Code',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.security, color: Colors.white70),
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
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
      ],
    );
  }

  Widget _buildBloodInventoryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
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
            (entry) => _buildInventoryItem(entry.key, entry.value),
          ),
        ],
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
