import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'theme/app_theme.dart';

class BloodInventoryPage extends StatefulWidget {
  const BloodInventoryPage({super.key});

  @override
  State<BloodInventoryPage> createState() => _BloodInventoryPageState();
}

class _BloodInventoryPageState extends State<BloodInventoryPage> {
  List<Map<String, dynamic>> _inventory = [];
  List<Map<String, dynamic>> _filteredInventory = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _bloodGroupController = TextEditingController();
  final _quantityController = TextEditingController();
  bool _showAddForm = false;
  Map<String, dynamic>? _editingItem;

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bloodGroupController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _loadInventory() async {
    try {
      final inventory = await DatabaseHelper().getAllBloodInventory();
      setState(() {
        _inventory = inventory;
        _filteredInventory = inventory;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading inventory: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _filterInventory(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredInventory = _inventory;
      } else {
        _filteredInventory = _inventory.where((item) {
          final bloodGroup = item['bloodGroup'].toString().toLowerCase();
          final status = item['status'].toString().toLowerCase();
          final queryLower = query.toLowerCase();

          return bloodGroup.contains(queryLower) ||
              status.contains(queryLower) ||
              item['quantity'].toString().contains(queryLower);
        }).toList();
      }
    });
  }

  Future<void> _addInventory() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final success = await DatabaseHelper().addBloodInventory({
        'bloodGroup': _bloodGroupController.text.trim(),
        'quantity': int.tryParse(_quantityController.text) ?? 0,
      });

      if (success) {
        _clearForm();
        await _loadInventory();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Blood group ${_bloodGroupController.text} added successfully!',
              ),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Blood group already exists'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding inventory: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _updateInventory() async {
    if (!_formKey.currentState!.validate() || _editingItem == null) return;

    try {
      final success = await DatabaseHelper()
          .updateBloodInventory(_editingItem!['id'], {
            'quantity': int.tryParse(_quantityController.text) ?? 0,
            'status': (int.tryParse(_quantityController.text) ?? 0) > 0
                ? 'Available'
                : 'Out of Stock',
          });

      if (success) {
        _clearForm();
        await _loadInventory();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Blood group ${_editingItem!['bloodGroup']} updated successfully!',
              ),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error updating inventory'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating inventory: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _deleteInventory(int inventoryId, String bloodGroup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          'Are you sure you want to delete blood group $bloodGroup?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await DatabaseHelper().deleteBloodInventory(
          inventoryId,
        );
        if (success) {
          await _loadInventory();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Blood group $bloodGroup deleted successfully!'),
                backgroundColor: AppTheme.successColor,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error deleting inventory'),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting inventory: ${e.toString()}'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  void _editInventory(Map<String, dynamic> item) {
    setState(() {
      _editingItem = item;
      _bloodGroupController.text = item['bloodGroup'];
      _quantityController.text = item['quantity'].toString();
      _showAddForm = true;
    });
  }

  void _clearForm() {
    setState(() {
      _editingItem = null;
      _bloodGroupController.clear();
      _quantityController.clear();
      _showAddForm = false;
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return AppTheme.successColor;
      case 'out of stock':
        return AppTheme.errorColor;
      case 'low':
        return AppTheme.warningColor;
      default:
        return AppTheme.secondaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Inventory Management'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.lightTextColor,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppTheme.primaryGradientDecoration,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterInventory,
                    decoration: InputDecoration(
                      hintText: 'Search blood groups, status, or quantity...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: AppTheme.cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Add Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _showAddForm = !_showAddForm;
                              if (!_showAddForm) _clearForm();
                            });
                          },
                          icon: Icon(_showAddForm ? Icons.close : Icons.add),
                          label: Text(
                            _showAddForm ? 'Cancel' : 'Add Blood Group',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.secondaryColor,
                            foregroundColor: AppTheme.lightTextColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Add/Edit Form
                if (_showAddForm)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _editingItem == null
                                ? 'Add New Blood Group'
                                : 'Edit Blood Group',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _bloodGroupController,
                            enabled: _editingItem == null,
                            decoration: const InputDecoration(
                              labelText: 'Blood Group',
                              prefixIcon: Icon(Icons.bloodtype),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter blood group';
                              }
                              if (!RegExp(
                                r'^[ABO][+-]$',
                              ).hasMatch(value.toUpperCase())) {
                                return 'Please enter a valid blood group (A+, A-, B+, B-, AB+, AB-, O+, O-)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _quantityController,
                            decoration: const InputDecoration(
                              labelText: 'Quantity',
                              prefixIcon: Icon(Icons.inventory),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter quantity';
                              }
                              final quantity = int.tryParse(value);
                              if (quantity == null || quantity < 0) {
                                return 'Please enter a valid positive number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _editingItem == null
                                      ? _addInventory
                                      : _updateInventory,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: AppTheme.lightTextColor,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  child: Text(
                                    _editingItem == null ? 'Add' : 'Update',
                                  ),
                                ),
                              ),
                              if (_editingItem != null) ...[
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _clearForm,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.warningColor,
                                      foregroundColor: AppTheme.lightTextColor,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                    child: const Text('Cancel'),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Inventory List
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_filteredInventory.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: AppTheme.lightTextColor.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty
                                ? 'No blood inventory found'
                                : 'No results found for "${_searchController.text}"',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppTheme.lightTextColor.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ..._filteredInventory.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 4.0,
                      ),
                      child: Card(
                        elevation: 4,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryColor,
                            child: Text(
                              item['bloodGroup'],
                              style: const TextStyle(
                                color: AppTheme.lightTextColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            'Blood Group ${item['bloodGroup']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Quantity: ${item['quantity']} units'),
                              Text(
                                'Status: ${item['status']}',
                                style: TextStyle(
                                  color: _getStatusColor(item['status']),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Last Updated: ${DateTime.parse(item['lastUpdated']).toString().substring(0, 16)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              switch (value) {
                                case 'edit':
                                  _editInventory(item);
                                  break;
                                case 'delete':
                                  _deleteInventory(
                                    item['id'],
                                    item['bloodGroup'],
                                  );
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
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
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

                const SizedBox(
                  height: 32,
                ), // Bottom padding for better scrolling
              ],
            ),
          ),
        ),
      ),
    );
  }
}
