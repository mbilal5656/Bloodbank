import 'package:flutter/material.dart';
import 'services/data_service.dart';
import 'notification_helper.dart';
import 'main.dart' show NavigationUtils;
import 'package:provider/provider.dart';
import 'theme/theme_provider.dart';

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
  final _scaffoldKey = GlobalKey<ScaffoldState>();
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
    _loadData();
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

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);

      final dataService = DataService();
      final users = await dataService.getAllUsers();
      final bloodInventorySummary =
          await dataService.getBloodInventorySummary();

      setState(() {
        _users = users;
        _bloodInventorySummary = bloodInventorySummary;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      final success = await NotificationHelper.addNotification(
        title: _notificationTitleController.text.trim(),
        message: _notificationMessageController.text.trim(),
        type: _selectedNotificationType,
        userId: null,
      );

      if (success) {
        _notificationTitleController.clear();
        _notificationMessageController.clear();
        _selectedNotificationType = 'info';
        _selectedTargetUserType = 'all';

        setState(() => _showNotificationForm = false);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notification sent successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to send notification'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
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
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deleteUser(int userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text(
          'Are you sure you want to delete this user? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final dataService = DataService();
        final success = await dataService.deleteUser(userId);
        if (success) {
          await _loadData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('User deleted successfully'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to delete user'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _toggleUserStatus(int userId, bool isActive) async {
    try {
      final dataService = DataService();
      final success = await dataService.updateUser(userId, {
        'isActive': isActive ? 1 : 0,
      });
      if (success) {
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'User ${isActive ? 'activated' : 'deactivated'} successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update user status'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _addUser() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final dataService = DataService();
      final existingUser = await dataService.getUserByEmail(
        _emailController.text.trim(),
      );

      if (existingUser != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email already registered'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      final newUser = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'userType': _userType,
        'bloodGroup': _bloodGroupController.text.trim(),
        'age': int.tryParse(_ageController.text) ?? 0,
        'contactNumber': _contactController.text.trim(),
        'address': '',
      };

      await dataService.insertUser(newUser);

      // Clear form
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _bloodGroupController.clear();
      _ageController.clear();
      _contactController.clear();
      _userType = 'Donor';

      setState(() => _showAddUserForm = false);
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$_userType added successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding user: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
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
                      if (value == null || value.isEmpty) {
                        return 'Please enter contact number';
                      }
                      return null;
                    },
                  ),
                DropdownButtonFormField<String>(
                  value: _userType,
                  decoration: const InputDecoration(labelText: 'User Type'),
                  items: const [
                    DropdownMenuItem(value: 'Donor', child: Text('Donor')),
                    DropdownMenuItem(
                        value: 'Receiver', child: Text('Receiver')),
                    DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _userType = value!;
                    });
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
                // Close dialog immediately to avoid BuildContext issues
                Navigator.pop(dialogContext);
                
                try {
                  final dataService = DataService();

                  await dataService.updateUser(user['id'], {
                    'name': _nameController.text,
                    'email': _emailController.text,
                    'bloodGroup': _bloodGroupController.text,
                    'age': int.tryParse(_ageController.text) ?? 0,
                    'contactNumber': _contactController.text,
                    'userType': _userType,
                  });

                  await _loadData();

                  // Schedule snackbar to be shown after the current frame
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _showSnackBar('User updated successfully');
                  });
                } catch (e) {
                  // Schedule snackbar to be shown after the current frame
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _showSnackBar('Error updating user: ${e.toString()}', isError: true);
                  });
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Color _getUserTypeColor(String userType) {
    switch (userType.toLowerCase()) {
      case 'admin':
        return Colors.blue;
      case 'donor':
        return Colors.red;
      case 'receiver':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Helper method to safely show snackbar after async operations
  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted && _scaffoldKey.currentContext != null) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }



  IconData _getUserTypeIcon(String userType) {
    switch (userType.toLowerCase()) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'donor':
        return Icons.volunteer_activism;
      case 'receiver':
        return Icons.person;
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory),
            onPressed: () => Navigator.pushNamed(context, '/blood_inventory'),
            tooltip: 'Blood Inventory',
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () =>
                Navigator.pushNamed(context, '/notification_management'),
            tooltip: 'Notifications',
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
            icon: const Icon(Icons.logout),
            onPressed: () async => await NavigationUtils.logout(context),
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
            child: Icon(
              _showNotificationForm ? Icons.close : Icons.notifications,
            ),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              setState(() => _showAddUserForm = !_showAddUserForm);
            },
            backgroundColor: const Color(0xFF1A237E),
            foregroundColor: Colors.white,
            child: Icon(_showAddUserForm ? Icons.close : Icons.add),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: isDark ? Colors.white : const Color(0xFF1A237E),
              ),
            )
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
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: isDark ? Colors.white : const Color(0xFF1A237E),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'Total Users: ${_users.length}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: isDark ? Colors.white70 : const Color(0xFF1A237E),
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (_showNotificationForm) ...[
                    _buildNotificationForm(),
                    const SizedBox(height: 20),
                  ],

                  _buildBloodInventorySummary(),

                  const SizedBox(height: 20),

                  if (_showAddUserForm) ...[
                    _buildAddUserForm(),
                    const SizedBox(height: 20),
                  ],

                  ..._users.map((user) => _buildUserCard(user)),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildNotificationForm() {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Send Notification',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: isDark ? Colors.white : const Color(0xFF1A237E),
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notificationTitleController,
              decoration: InputDecoration(
                labelText: 'Notification Title',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: isDark ? const Color(0xFF3C3C3C) : Colors.grey[50],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notificationMessageController,
              decoration: InputDecoration(
                labelText: 'Notification Message',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: isDark ? const Color(0xFF3C3C3C) : Colors.grey[50],
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedNotificationType,
                    decoration: InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF3C3C3C) : Colors.grey[50],
                    ),
                    items: ['info', 'success', 'warning', 'urgent']
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.toUpperCase()),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedNotificationType = value!);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedTargetUserType,
                    decoration: InputDecoration(
                      labelText: 'Target',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF3C3C3C) : Colors.grey[50],
                    ),
                    items: ['all', 'Donor', 'Receiver', 'Admin']
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(type == 'all' ? 'All Users' : type),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedTargetUserType = value!);
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Send Notification'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => _showNotificationForm = false);
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBloodInventorySummary() {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
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
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: isDark ? Colors.white : const Color(0xFF1A237E),
                        fontWeight: FontWeight.bold,
                      ),
                ),
                ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/blood_inventory'),
                  icon: const Icon(Icons.inventory),
                  label: const Text('Manage Inventory'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_bloodInventorySummary.isNotEmpty)
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: _bloodInventorySummary.entries.map((entry) {
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
                        color: entry.value > 0 ? Colors.green : Colors.red,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          entry.key,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${entry.value}',
                          style: TextStyle(
                            color: entry.value > 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              )
            else
              Text(
                'No blood inventory data available',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddUserForm() {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add New User',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: isDark ? Colors.white : const Color(0xFF1A237E),
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF3C3C3C) : Colors.grey[50],
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
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF3C3C3C) : Colors.grey[50],
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
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF3C3C3C) : Colors.grey[50],
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
                      decoration: InputDecoration(
                        labelText: 'User Type',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF3C3C3C) : Colors.grey[50],
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
                        setState(() => _userType = value!);
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
                      decoration: InputDecoration(
                        labelText: 'Blood Group',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF3C3C3C) : Colors.grey[50],
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
                      decoration: InputDecoration(
                        labelText: 'Age',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF3C3C3C) : Colors.grey[50],
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter age';
                        }
                        final age = int.tryParse(value);
                        if (age == null || age < 1 || age > 120) {
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
                  decoration: InputDecoration(
                    labelText: 'Contact Number',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF3C3C3C) : Colors.grey[50],
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
                        backgroundColor: const Color(0xFF1A237E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Add User'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() => _showAddUserForm = false);
                        _nameController.clear();
                        _emailController.clear();
                        _passwordController.clear();
                        _bloodGroupController.clear();
                        _ageController.clear();
                        _contactController.clear();
                        _userType = 'Donor';
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final userType = user['userType'] ?? 'Unknown';
    final isActive = user['isActive'] == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.red.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getUserTypeColor(userType).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getUserTypeIcon(userType),
            color: _getUserTypeColor(userType),
            size: 24,
          ),
        ),
        title: Text(
          user['name'] ?? 'Unknown User',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user['email'] ?? 'No email',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getUserTypeColor(userType).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getUserTypeColor(userType),
                  width: 1,
                ),
              ),
              child: Text(
                userType,
                style: TextStyle(
                  color: _getUserTypeColor(userType),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isActive ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert, 
                color: isDark ? Colors.white70 : Colors.grey[600]
              ),
              onSelected: (value) async {
                switch (value) {
                  case 'edit':
                    _showEditUserDialog(user);
                    break;
                  case 'delete':
                    await _deleteUser(user['id']);
                    break;
                  case 'toggle':
                    await _toggleUserStatus(user['id'], !isActive);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(Icons.swap_horiz),
                      SizedBox(width: 8),
                      Text('Toggle Status'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
