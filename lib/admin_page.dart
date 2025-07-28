import 'package:flutter/material.dart';
import 'services/data_service.dart';
import 'models/user_model.dart';
import 'session_manager.dart';
import 'notification_helper.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<Map<String, dynamic>> _users = [];
  Map<String, int> _bloodInventorySummary = {};
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _bloodGroupController = TextEditingController();
  final _ageController = TextEditingController();
  final _contactController = TextEditingController();
  String _userType = 'Donor';
  bool _showAddUserForm = false;

  // Notification form controllers
  final _notificationTitleController = TextEditingController();
  final _notificationMessageController = TextEditingController();
  String _selectedNotificationType = 'info';
  String _selectedTargetUserType = 'all';
  bool _showNotificationForm = false;

  @override
  void initState() {
    super.initState();
    debugPrint('AdminPage: initState called');
    _loadUsers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bloodGroupController.dispose();
    _ageController.dispose();
    _contactController.dispose();
    _notificationTitleController.dispose();
    _notificationMessageController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    try {
      debugPrint('AdminPage: Starting to load users...');
      final dataService = DataService();
      debugPrint('AdminPage: DataService instance created');

      debugPrint('AdminPage: Getting all users...');
      final users = await dataService.getAllUsers();
      debugPrint('AdminPage: Retrieved ${users.length} users');

      debugPrint('AdminPage: Getting blood inventory summary...');
      final bloodInventorySummary = await dataService
          .getBloodInventorySummary();
      debugPrint('AdminPage: Blood inventory summary: $bloodInventorySummary');

      setState(() {
        _users = users.map((user) => user.toMap()).toList();
        _bloodInventorySummary = bloodInventorySummary;
        _isLoading = false;
      });
      debugPrint('AdminPage: Users loaded successfully, UI updated');
    } catch (e) {
      debugPrint('AdminPage: Error loading users: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading users: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendNotification() async {
    if (_notificationTitleController.text.isEmpty ||
        _notificationMessageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all notification fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final success = await NotificationHelper.addNotification(
        title: _notificationTitleController.text.trim(),
        message: _notificationMessageController.text.trim(),
        type: _selectedNotificationType,
        userId: null, // Send to all users
      );

      if (success) {
        _notificationTitleController.clear();
        _notificationMessageController.clear();
        _selectedNotificationType = 'info';
        _selectedTargetUserType = 'all';

        setState(() {
          _showNotificationForm = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notification sent successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to send notification'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending notification: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteUser(int userId) async {
    try {
      final dataService = DataService();
      await dataService.deleteUser(userId);
      await _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting user: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addUser() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final dataService = DataService();
      // Check if email already exists
      final existingUser = await dataService.getUserByEmail(
        _emailController.text.trim(),
      );

      if (existingUser != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email already registered'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Create new user
      final newUser = UserModel(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        userType: _userType,
        bloodGroup: _bloodGroupController.text.trim(),
        age: int.tryParse(_ageController.text) ?? 0,
        contactNumber: _userType == 'Admin'
            ? 'N/A'
            : _contactController.text.trim(),
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      await dataService.createUser(newUser);

      // Clear form
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _bloodGroupController.clear();
      _ageController.clear();
      _contactController.clear();
      _userType = 'Donor';

      setState(() {
        _showAddUserForm = false;
      });

      await _loadUsers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$_userType added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding user: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _resetUserPassword(int userId, String userEmail) async {
    final newPassword = 'Reset123!'; // Default reset password

    try {
      final dataService = DataService();
      await dataService.updateUser(userId, {'password': newPassword});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Password reset for $userEmail. New password: $newPassword',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error resetting password: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    if (!mounted) return;

    _nameController.text = user['name'] ?? '';
    _emailController.text = user['email'] ?? '';
    _bloodGroupController.text = user['bloodGroup'] ?? '';
    _ageController.text = user['age']?.toString() ?? '';
    _contactController.text = user['contactNumber'] ?? '';
    _userType = user['userType'] ?? 'Donor';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Edit ${user['name']}'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _bloodGroupController,
                  decoration: const InputDecoration(labelText: 'Blood Group'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter blood group';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter age';
                    }
                    return null;
                  },
                ),
                if (user['userType'] != 'Admin')
                  TextFormField(
                    controller: _contactController,
                    decoration: const InputDecoration(
                      labelText: 'Contact Number',
                    ),
                    validator: (value) {
                      if (user['userType'] != 'Admin' &&
                          (value == null || value.isEmpty)) {
                        return 'Please enter contact number';
                      }
                      return null;
                    },
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(dialogContext);
                try {
                  final dataService = DataService();
                  await dataService.updateUser(user['id'], {
                    'name': _nameController.text.trim(),
                    'email': _emailController.text.trim(),
                    'bloodGroup': _bloodGroupController.text.trim(),
                    'age': int.tryParse(_ageController.text) ?? 0,
                    'contactNumber': user['userType'] == 'Admin'
                        ? 'N/A'
                        : _contactController.text.trim(),
                  });

                  navigator.pop();
                  await _loadUsers();

                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('User updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('Error updating user: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('AdminPage: build method called');

    // Access control: only Admin can access
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      debugPrint('AdminPage: Checking user access...');
      final navigator = Navigator.of(context);
      final userType = await SessionManager.getUserType();
      debugPrint('AdminPage: Current user type: $userType');
      if (userType != 'Admin' && mounted) {
        debugPrint('AdminPage: Access denied, redirecting to login');
        navigator.pushReplacementNamed('/login');
      } else {
        debugPrint('AdminPage: Access granted for admin user');
      }
    });

    return Scaffold(
      backgroundColor: Colors.indigo[50],
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory),
            onPressed: () {
              Navigator.pushNamed(context, '/blood_inventory');
            },
            tooltip: 'Blood Inventory',
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
            onPressed: () async {
              final navigator = Navigator.of(context);
              await SessionManager.clearSession();
              if (mounted) {
                navigator.pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _showNotificationForm = !_showNotificationForm;
                if (!_showNotificationForm) {
                  _notificationTitleController.clear();
                  _notificationMessageController.clear();
                  _selectedNotificationType = 'info';
                  _selectedTargetUserType = 'all';
                }
              });
            },
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            tooltip: 'Send Notification',
            child: Icon(
              _showNotificationForm ? Icons.close : Icons.notifications,
            ),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _showAddUserForm = !_showAddUserForm;
              });
            },
            backgroundColor: const Color(0xFF1A237E),
            foregroundColor: Colors.white,
            tooltip: 'Add User',
            child: Icon(_showAddUserForm ? Icons.close : Icons.add),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'User Management',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: const Color(0xFF1A237E),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'Total Users: ${_users.length}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF1A237E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Notification Form
                  if (_showNotificationForm) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Send Notification',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: const Color(0xFF1A237E),
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _notificationTitleController,
                              decoration: const InputDecoration(
                                labelText: 'Notification Title',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _notificationMessageController,
                              decoration: const InputDecoration(
                                labelText: 'Notification Message',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedNotificationType,
                                    decoration: const InputDecoration(
                                      labelText: 'Type',
                                      border: OutlineInputBorder(),
                                    ),
                                    items:
                                        ['info', 'success', 'warning', 'urgent']
                                            .map(
                                              (type) => DropdownMenuItem(
                                                value: type,
                                                child: Text(type.toUpperCase()),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedNotificationType = value!;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedTargetUserType,
                                    decoration: const InputDecoration(
                                      labelText: 'Target',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: ['all', 'Donor', 'Receiver', 'Admin']
                                        .map(
                                          (type) => DropdownMenuItem(
                                            value: type,
                                            child: Text(
                                              type == 'all'
                                                  ? 'All Users'
                                                  : type,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedTargetUserType = value!;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _sendNotification,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Send Notification'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        _showNotificationForm = false;
                                      });
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Blood Inventory Summary
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Blood Inventory Summary',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: const Color(0xFF1A237E),
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/blood_inventory',
                                  );
                                },
                                icon: const Icon(Icons.inventory),
                                label: const Text('Manage Inventory'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1A237E),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_bloodInventorySummary.isNotEmpty)
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: _bloodInventorySummary.entries.map((
                                entry,
                              ) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: entry.value > 0
                                        ? Colors.green.withValues(alpha: 0.1)
                                        : Colors.red.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: entry.value > 0
                                          ? Colors.green
                                          : Colors.red,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        entry.key,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${entry.value}',
                                        style: TextStyle(
                                          color: entry.value > 0
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            )
                          else
                            const Text(
                              'No blood inventory data available',
                              style: TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Add User Form
                  if (_showAddUserForm) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Add New User',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: const Color(0xFF1A237E),
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _nameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Full Name',
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a name';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _emailController,
                                      decoration: const InputDecoration(
                                        labelText: 'Email',
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter an email';
                                        }
                                        if (!RegExp(
                                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                        ).hasMatch(value)) {
                                          return 'Please enter a valid email';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _passwordController,
                                      decoration: const InputDecoration(
                                        labelText: 'Password',
                                        border: OutlineInputBorder(),
                                      ),
                                      obscureText: true,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a password';
                                        }
                                        if (value.length < 6) {
                                          return 'Password must be at least 6 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _userType,
                                      decoration: const InputDecoration(
                                        labelText: 'User Type',
                                        border: OutlineInputBorder(),
                                      ),
                                      items: ['Donor', 'Receiver', 'Admin']
                                          .map(
                                            (type) => DropdownMenuItem(
                                              value: type,
                                              child: Text(type),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _userType = value!;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _bloodGroupController,
                                      decoration: const InputDecoration(
                                        labelText: 'Blood Group',
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter blood group';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _ageController,
                                      decoration: const InputDecoration(
                                        labelText: 'Age',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter age';
                                        }
                                        final age = int.tryParse(value);
                                        if (age == null ||
                                            age < 1 ||
                                            age > 120) {
                                          return 'Please enter a valid age';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              if (_userType != 'Admin') ...[
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _contactController,
                                  decoration: const InputDecoration(
                                    labelText: 'Contact Number',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.phone,
                                  validator: (value) {
                                    if (_userType != 'Admin' &&
                                        (value == null || value.isEmpty)) {
                                      return 'Please enter contact number';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _addUser,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF1A237E,
                                        ),
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Add User'),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          _showAddUserForm = false;
                                        });
                                        _nameController.clear();
                                        _emailController.clear();
                                        _passwordController.clear();
                                        _bloodGroupController.clear();
                                        _ageController.clear();
                                        _contactController.clear();
                                        _userType = 'Donor';
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Users List
                  ..._users.map(
                    (user) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: user['userType'] == 'Admin'
                              ? Colors.blue
                              : user['userType'] == 'Donor'
                              ? Colors.red
                              : Colors.green,
                          child: Icon(
                            user['userType'] == 'Donor'
                                ? Icons.volunteer_activism
                                : user['userType'] == 'Receiver'
                                ? Icons.person
                                : Icons.admin_panel_settings,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          '${user['name']} (${user['userType']})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditUserDialog(user),
                              tooltip: 'Edit User',
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.lock_reset,
                                color: Colors.orange,
                              ),
                              onPressed: () =>
                                  _resetUserPassword(user['id'], user['email']),
                              tooltip: 'Reset Password',
                            ),
                            if (user['userType'] != 'Admin')
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteUser(user['id']),
                                tooltip: 'Delete User',
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 32,
                  ), // Bottom padding for better scrolling
                ],
              ),
            ),
    );
  }
}
