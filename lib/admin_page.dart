import 'package:flutter/material.dart';
import 'services/data_service.dart';
import 'notification_helper.dart';
import 'main.dart' show NavigationUtils;
import 'package:provider/provider.dart';
import 'theme/theme_provider.dart';
import 'theme_manager.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _contactMessages = [];
  Map<String, int> _bloodInventorySummary = {};
  List<Map<String, dynamic>> _bloodInventory =
      []; // Add this line for detailed blood inventory
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
      final bloodInventorySummary = await dataService
          .getBloodInventorySummary();
      final contactMessages = await dataService.getAllContactMessages();
      final bloodInventory = await dataService
          .getAllBloodInventory(); // Add this line

      setState(() {
        _users = users;
        _bloodInventorySummary = bloodInventorySummary;
        _contactMessages = contactMessages;
        _bloodInventory = bloodInventory; // Add this line
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
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

  void _showThemeSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildThemeSelector(),
    );
  }

  Widget _buildThemeSelector() {
    final currentTheme = context.watch<ThemeProvider>().currentAppTheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: currentTheme.surfaceColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Icon(Icons.palette, color: currentTheme.primaryColor),
                const SizedBox(width: 12),
                Text(
                  'Choose Theme',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: currentTheme.textColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: currentTheme.textColor),
                ),
              ],
            ),
          ),

          // Theme grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: ThemeManager.themes.length,
                itemBuilder: (context, index) {
                  final themeKey = ThemeManager.availableThemes[index];
                  final theme = ThemeManager.themes[themeKey]!;
                  final isSelected = ThemeManager.currentTheme == themeKey;

                  return GestureDetector(
                    onTap: () async {
                      await ThemeManager.changeTheme(themeKey);
                      // Refresh the UI to show the new theme
                      setState(() {});
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Theme changed to ${theme.name}'),
                          backgroundColor: theme.primaryColor,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: currentTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? theme.primaryColor
                              : Colors.grey.shade300,
                          width: isSelected ? 3 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Theme preview
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                colors: [
                                  theme.primaryColor,
                                  theme.secondaryColor,
                                  theme.accentColor,
                                ],
                              ),
                            ),
                            child: Icon(
                              Icons.bloodtype,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            theme.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: currentTheme.textColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.primaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Active',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Bottom padding
          const SizedBox(height: 24),
        ],
      ),
    );
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
                'User ${isActive ? 'activated' : 'deactivated'} successfully',
              ),
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
                      value: 'Receiver',
                      child: Text('Receiver'),
                    ),
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
                    _showSnackBar(
                      'Error updating user: ${e.toString()}',
                      isError: true,
                    );
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
        backgroundColor: isDark
            ? const Color(0xFF1E1E1E)
            : const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => Navigator.pushNamed(context, '/analytics'),
            tooltip: 'Analytics Dashboard',
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => Navigator.pushNamed(context, '/qr_scanner'),
            tooltip: 'QR Code Scanner',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/search_filter'),
            tooltip: 'Search & Filter',
          ),
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
            icon: const Icon(Icons.palette),
            onPressed: () => _showThemeSelector(),
            tooltip: 'Change Theme',
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
            heroTag: 'add_blood_fab',
            onPressed: _showAddBloodInventoryDialog,
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            child: const Icon(Icons.bloodtype),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'notification_fab',
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
            heroTag: 'add_user_fab',
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
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          Text(
                            'User Management',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1A237E),
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'Total Users: ${_users.length}',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: isDark
                                      ? Colors.white70
                                      : const Color(0xFF1A237E),
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  if (_showNotificationForm) ...[
                    _buildNotificationForm(),
                    const SizedBox(height: 20),
                  ],
                  _buildBloodInventorySummary(),
                  const SizedBox(height: 20),
                  _buildContactMessagesSection(),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF3C3C3C) : Colors.grey[50],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notificationMessageController,
              decoration: InputDecoration(
                labelText: 'Notification Message',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF3C3C3C) : Colors.grey[50],
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 400) {
                  // For smaller screens, stack vertically
                  return Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedNotificationType,
                        decoration: InputDecoration(
                          labelText: 'Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF3C3C3C)
                              : Colors.grey[50],
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
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedTargetUserType,
                        decoration: InputDecoration(
                          labelText: 'Target',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF3C3C3C)
                              : Colors.grey[50],
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
                    ],
                  );
                } else {
                  // For larger screens, use horizontal layout
                  return Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedNotificationType,
                          decoration: InputDecoration(
                            labelText: 'Type',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: isDark
                                ? const Color(0xFF3C3C3C)
                                : Colors.grey[50],
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
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: isDark
                                ? const Color(0xFF3C3C3C)
                                : Colors.grey[50],
                          ),
                          items: ['all', 'Donor', 'Receiver', 'Admin']
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(
                                    type == 'all' ? 'All Users' : type,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedTargetUserType = value!);
                          },
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 350) {
                  // For smaller screens, stack vertically
                  return Column(
                    children: [
                      ElevatedButton(
                        onPressed: _sendNotification,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Send Notification'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () {
                          setState(() => _showNotificationForm = false);
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ],
                  );
                } else {
                  // For larger screens, use horizontal layout
                  return Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _sendNotification,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Cancel'),
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
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 400) {
                  // For smaller screens, stack vertically
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Blood Inventory Management',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1A237E),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/blood_inventory'),
                        icon: const Icon(Icons.inventory),
                        label: const Text('Full Inventory'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A237E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  // For larger screens, use horizontal layout
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Blood Inventory Management',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1A237E),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/blood_inventory'),
                        icon: const Icon(Icons.inventory),
                        label: const Text('Full Inventory'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A237E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            _buildBloodInventoryList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBloodInventoryList() {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    if (_bloodInventory.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: isDark ? Colors.white70 : Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No blood inventory data available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add blood units to get started',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white54 : Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _bloodInventory
          .map((bloodUnit) => _buildBloodUnitCard(bloodUnit))
          .toList(),
    );
  }

  Widget _buildBloodUnitCard(Map<String, dynamic> bloodUnit) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final status = bloodUnit['status'] ?? 'Available';
    final totalQty = bloodUnit['quantity'] ?? 0;
    final reservedQty = bloodUnit['reservedQuantity'] ?? 0;
    final availableQty = totalQty - reservedQty;

    Color statusColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'available':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'low stock':
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        break;
      case 'out of stock':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      case 'expired':
        statusColor = Colors.red;
        statusIcon = Icons.block;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3C3C3C) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.bloodtype, color: statusColor, size: 22),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                '${bloodUnit['bloodGroup']} Blood Group',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildQuantityInfo('Total', totalQty, Colors.blue),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuantityInfo(
                    'Available',
                    availableQty,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuantityInfo(
                    'Reserved',
                    reservedQty,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (bloodUnit['expiryDate'] != null) ...[
              Text(
                'Expires: ${bloodUnit['expiryDate']}',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
            if (bloodUnit['notes'] != null &&
                bloodUnit['notes'].isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                bloodUnit['notes'],
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey[600],
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: isDark ? Colors.white70 : Colors.grey[600],
          ),
          onSelected: (value) async {
            switch (value) {
              case 'edit':
                showDialog(
                  context: context,
                  builder: (context) => _buildEditBloodUnitDialog(bloodUnit),
                );
                break;
              case 'delete':
                await _deleteBloodUnit(bloodUnit['id']);
                break;
              case 'view':
                _showBloodUnitDetails(bloodUnit);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility, size: 20),
                  SizedBox(width: 8),
                  Text('View Details'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityInfo(String label, int quantity, Color color) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            '$quantity',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBloodUnit(int bloodUnitId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text(
          'Are you sure you want to delete this blood unit? This action cannot be undone.',
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
        final success = await dataService.deleteBloodInventory(bloodUnitId);

        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Blood unit deleted successfully'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          // Refresh the data
          await _loadData();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to delete blood unit'),
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
              content: Text('Error deleting blood unit: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _showBloodUnitDetails(Map<String, dynamic> bloodUnit) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final totalQty = bloodUnit['quantity'] ?? 0;
    final reservedQty = bloodUnit['reservedQuantity'] ?? 0;
    final availableQty = totalQty - reservedQty;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        title: Text(
          '${bloodUnit['bloodGroup']} Blood Unit Details',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow(
                  'Blood Group:',
                  bloodUnit['bloodGroup'] ?? 'Unknown',
                ),
                _buildDetailRow('Total Quantity:', '$totalQty'),
                _buildDetailRow('Available Quantity:', '$availableQty'),
                _buildDetailRow('Reserved Quantity:', '$reservedQty'),
                _buildDetailRow('Status:', bloodUnit['status'] ?? 'Unknown'),
                if (bloodUnit['expiryDate'] != null)
                  _buildDetailRow('Expiry Date:', bloodUnit['expiryDate']),
                if (bloodUnit['notes'] != null &&
                    bloodUnit['notes'].isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Notes:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF3C3C3C) : Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      bloodUnit['notes'],
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => _buildEditBloodUnitDialog(bloodUnit),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            ),
          ),
        ],
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
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF3C3C3C)
                            : Colors.grey[50],
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
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF3C3C3C)
                            : Colors.grey[50],
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
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 400) {
                    // For smaller screens, stack vertically
                    return Column(
                      children: [
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: isDark
                                ? const Color(0xFF3C3C3C)
                                : Colors.grey[50],
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
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _userType,
                          decoration: InputDecoration(
                            labelText: 'User Type',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: isDark
                                ? const Color(0xFF3C3C3C)
                                : Colors.grey[50],
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
                      ],
                    );
                  } else {
                    // For larger screens, use horizontal layout
                    return Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF3C3C3C)
                                  : Colors.grey[50],
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
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF3C3C3C)
                                  : Colors.grey[50],
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
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 400) {
                    // For smaller screens, stack vertically
                    return Column(
                      children: [
                        TextFormField(
                          controller: _bloodGroupController,
                          decoration: InputDecoration(
                            labelText: 'Blood Group',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: isDark
                                ? const Color(0xFF3C3C3C)
                                : Colors.grey[50],
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter blood group';
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
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: isDark
                                ? const Color(0xFF3C3C3C)
                                : Colors.grey[50],
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
                      ],
                    );
                  } else {
                    // For larger screens, use horizontal layout
                    return Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _bloodGroupController,
                            decoration: InputDecoration(
                              labelText: 'Blood Group',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF3C3C3C)
                                  : Colors.grey[50],
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
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF3C3C3C)
                                  : Colors.grey[50],
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
                    );
                  }
                },
              ),
              if (_userType != 'Admin') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contactController,
                  decoration: InputDecoration(
                    labelText: 'Contact Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF3C3C3C)
                        : Colors.grey[50],
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
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
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getUserTypeColor(userType).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _getUserTypeIcon(userType),
            color: _getUserTypeColor(userType),
            size: 22,
          ),
        ),
        title: Text(
          user['name'] ?? 'Unknown User',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              user['email'] ?? 'No email',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getUserTypeColor(userType).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getUserTypeColor(userType).withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Text(
                userType,
                style: TextStyle(
                  color: _getUserTypeColor(userType),
                  fontSize: 11,
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
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: isActive ? Colors.green : Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isActive ? Colors.green : Colors.red).withValues(
                      alpha: 0.5,
                    ),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: isDark ? Colors.white70 : Colors.grey[600],
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
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(Icons.swap_horiz, size: 20),
                      SizedBox(width: 8),
                      Text('Toggle Status'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 20),
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

  Widget _buildEditBloodUnitDialog(
    Map<String, dynamic> bloodUnit, {
    bool isNew = false,
  }) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final quantityController = TextEditingController(
      text: bloodUnit['quantity'].toString(),
    );
    final reservedController = TextEditingController(
      text: bloodUnit['reservedQuantity'].toString(),
    );
    final statusController = TextEditingController(text: bloodUnit['status']);
    final notesController = TextEditingController(
      text: bloodUnit['notes'] ?? '',
    );

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
      title: Text(
        isNew
            ? 'Add Blood Unit - ${bloodUnit['bloodGroup']}'
            : 'Edit Blood Unit - ${bloodUnit['bloodGroup']}',
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: quantityController,
              decoration: InputDecoration(
                labelText: 'Total Quantity',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF3C3C3C) : Colors.grey[50],
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: reservedController,
              decoration: InputDecoration(
                labelText: 'Reserved Quantity',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF3C3C3C) : Colors.grey[50],
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: statusController.text,
              decoration: InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF3C3C3C) : Colors.grey[50],
              ),
              items: ['Available', 'Reserved', 'Expired', 'Out of Stock']
                  .map(
                    (status) =>
                        DropdownMenuItem(value: status, child: Text(status)),
                  )
                  .toList(),
              onChanged: (value) {
                statusController.text = value!;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF3C3C3C) : Colors.grey[50],
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
        ),
        ElevatedButton(
          onPressed: () async {
            // Close dialog immediately to avoid BuildContext issues
            Navigator.pop(context, true);

            try {
              final dataService = DataService();
              bool success;

              if (isNew) {
                // Add new blood inventory
                success = await dataService.addBloodInventory({
                  'bloodGroup': bloodUnit['bloodGroup'],
                  'quantity': int.parse(quantityController.text),
                  'reservedQuantity': int.parse(reservedController.text),
                  'status': statusController.text,
                  'notes': notesController.text,
                  'expiryDate': bloodUnit['expiryDate'],
                  'lastUpdated': DateTime.now().toIso8601String(),
                });
              } else {
                // Update existing blood inventory
                success = await dataService
                    .updateBloodInventory(bloodUnit['id'], {
                      'quantity': int.parse(quantityController.text),
                      'reservedQuantity': int.parse(reservedController.text),
                      'status': statusController.text,
                      'notes': notesController.text,
                      'lastUpdated': DateTime.now().toIso8601String(),
                    });
              }

              if (success) {
                // Schedule snackbar to be shown after the current frame
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isNew
                              ? 'Blood unit added successfully!'
                              : 'Blood unit updated successfully!',
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                });
                // Refresh the data
                await _loadData();
              } else {
                // Schedule snackbar to be shown after the current frame
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isNew
                              ? 'Failed to add blood unit'
                              : 'Failed to update blood unit',
                        ),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                });
              }
            } catch (e) {
              // Schedule snackbar to be shown after the current frame
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error ${isNew ? 'adding' : 'updating'} blood unit: ${e.toString()}',
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: Text(isNew ? 'Add' : 'Save'),
        ),
      ],
    );
  }

  // Show add blood inventory dialog
  Future<void> _showAddBloodInventoryDialog() async {
    try {
      // Show blood group selection first
      final selectedBloodGroup = await showDialog<String>(
        context: context,
        builder: (context) => _buildBloodGroupSelector(),
      );

      if (selectedBloodGroup != null && mounted) {
        // Create a new blood inventory item with selected blood group
        final newInventory = {
          'id': 0,
          'bloodGroup': selectedBloodGroup,
          'quantity': 0,
          'reservedQuantity': 0,
          'status': 'Available',
          'expiryDate': DateTime.now()
              .add(const Duration(days: 30))
              .toIso8601String(),
          'lastUpdated': DateTime.now().toIso8601String(),
          'notes': null,
        };

        final result = await showDialog<bool>(
          context: context,
          builder: (context) =>
              _buildEditBloodUnitDialog(newInventory, isNew: true),
        );

        if (result == true) {
          // Refresh the inventory after successful add
          await _loadData();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening add dialog: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Build blood group selector dialog
  Widget _buildBloodGroupSelector() {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1A237E)
                    : const Color(0xFF1A237E),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.add, color: Colors.white, size: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Select Blood Group',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: Colors.white),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),

            // Blood group grid
            Padding(
              padding: const EdgeInsets.all(24),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                ),
                itemCount: bloodGroups.length,
                itemBuilder: (context, index) {
                  final bloodGroup = bloodGroups[index];
                  return InkWell(
                    onTap: () => Navigator.of(context).pop(bloodGroup),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF3C3C3C)
                            : Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getBloodGroupColor(
                            bloodGroup,
                          ).withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          bloodGroup,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _getBloodGroupColor(bloodGroup),
                          ),
                        ),
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
  }

  Color _getBloodGroupColor(String bloodGroup) {
    switch (bloodGroup) {
      case 'A+':
        return Colors.red[700]!;
      case 'A-':
        return Colors.red[500]!;
      case 'B+':
        return Colors.orange[700]!;
      case 'B-':
        return Colors.orange[500]!;
      case 'AB+':
        return Colors.purple[700]!;
      case 'AB-':
        return Colors.purple[500]!;
      case 'O+':
        return Colors.red[900]!;
      case 'O-':
        return Colors.red[300]!;
      default:
        return Colors.grey;
    }
  }

  Widget _buildContactMessagesSection() {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    if (_contactMessages.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: isDark ? Colors.white70 : Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No contact messages received yet.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Users will be able to contact you through the contact page.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white54 : Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Messages',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: isDark ? Colors.white : const Color(0xFF1A237E),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._contactMessages
            .map((message) => _buildContactMessageCard(message))
            .toList(),
      ],
    );
  }

  Widget _buildContactMessageCard(Map<String, dynamic> message) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final senderName = message['name'] ?? 'Anonymous User';
    final senderEmail = message['email'] ?? 'No email';
    final subject = message['subject'] ?? 'No Subject';
    final messageBody = message['message'] ?? 'No message content';
    final timestamp = message['timestamp'] ?? DateTime.now().toIso8601String();
    final isRead = message['isRead'] ?? false;
    final hasResponse =
        message['adminResponse'] != null && message['adminResponse'].isNotEmpty;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isRead
                ? (hasResponse ? Colors.green : Colors.blue)
                : Colors.orange,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isRead
                                  ? Icons.mark_email_read
                                  : Icons.mark_email_unread,
                              color: isRead ? Colors.green : Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                senderName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          senderEmail,
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                    onSelected: (value) async {
                      switch (value) {
                        case 'mark_read':
                          await _markMessageAsRead(message['id']);
                          break;
                        case 'respond':
                          _showResponseDialog(message);
                          break;
                        case 'delete':
                          await _deleteContactMessage(message['id']);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      if (!isRead)
                        const PopupMenuItem(
                          value: 'mark_read',
                          child: Row(
                            children: [
                              Icon(Icons.mark_email_read, size: 20),
                              SizedBox(width: 8),
                              Text('Mark as Read'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'respond',
                        child: Row(
                          children: [
                            Icon(Icons.reply, size: 20),
                            SizedBox(width: 8),
                            Text('Respond'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black87).withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  subject,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                messageBody,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Received: ${DateTime.parse(timestamp).toLocal().toString().split('.')[0]}',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  if (hasResponse)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Responded',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              if (hasResponse) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Response:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message['adminResponse'],
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _markMessageAsRead(int messageId) async {
    try {
      final dataService = DataService();
      final success = await dataService.updateContactMessage(messageId, {
        'isRead': 1,
      });
      if (success) {
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Message marked as read.'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to mark message as read.'),
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
            content: Text('Error marking message as read: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showResponseDialog(Map<String, dynamic> message) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final responseController = TextEditingController(
      text: message['adminResponse'],
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        title: Text('Respond to ${message['name']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: responseController,
                decoration: InputDecoration(
                  labelText: 'Your Response',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF3C3C3C) : Colors.grey[50],
                ),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              final response = responseController.text.trim();
              if (response.isNotEmpty) {
                try {
                  final dataService = DataService();
                  final success = await dataService.updateContactMessage(
                    message['id'],
                    {'adminResponse': response},
                  );
                  if (success) {
                    await _loadData();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Response sent successfully!'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to send response.'),
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
                        content: Text(
                          'Error sending response: ${e.toString()}',
                        ),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Response cannot be empty.'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send Response'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteContactMessage(int messageId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text(
          'Are you sure you want to delete this contact message? This action cannot be undone.',
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
        final success = await dataService.deleteContactMessage(messageId);
        if (success) {
          await _loadData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Contact message deleted successfully.'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to delete contact message.'),
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
              content: Text('Error deleting contact message: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}
