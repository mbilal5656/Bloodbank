import 'package:flutter/material.dart';

import 'services/data_service.dart';
import 'theme_manager.dart';

class SearchFilterPage extends StatefulWidget {
  const SearchFilterPage({super.key});

  @override
  State<SearchFilterPage> createState() => _SearchFilterPageState();
}

class _SearchFilterPageState extends State<SearchFilterPage> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _allData = [];
  bool _isLoading = false;
  String _selectedCategory = 'all';
  String _selectedBloodGroup = 'all';
  String _selectedStatus = 'all';
  RangeValues _ageRange = const RangeValues(18, 65);
  RangeValues _quantityRange = const RangeValues(0, 200);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final dataService = DataService();
      final bloodInventory = await dataService.getAllBloodInventory();
      final donations = await dataService.getAllDonations();
      final requests = await dataService.getAllBloodRequests();

      _allData = [
        ...bloodInventory.map(
          (item) => {
            ...item,
            'category': 'blood_inventory',
            'displayName': '${item['bloodGroup']} Blood',
            'description': 'Quantity: ${item['quantity']} units',
          },
        ),
        ...donations.map(
          (item) => {
            ...item,
            'category': 'donations',
            'displayName': 'Donation by ${item['donorName'] ?? 'Unknown'}',
            'description': 'Blood Group: ${item['bloodGroup']}',
          },
        ),
        ...requests.map(
          (item) => {
            ...item,
            'category': 'blood_requests',
            'displayName': 'Request by ${item['requesterName'] ?? 'Unknown'}',
            'description': 'Blood Group: ${item['bloodGroup']}',
          },
        ),
      ];

      _searchResults = List.from(_allData);
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _performSearch() {
    final query = _searchController.text.toLowerCase();
    List<Map<String, dynamic>> filteredData = _allData;

    // Apply category filter
    if (_selectedCategory != 'all') {
      filteredData = filteredData
          .where((item) => item['category'] == _selectedCategory)
          .toList();
    }

    // Apply blood group filter
    if (_selectedBloodGroup != 'all') {
      filteredData = filteredData
          .where((item) => item['bloodGroup'] == _selectedBloodGroup)
          .toList();
    }

    // Apply status filter
    if (_selectedStatus != 'all') {
      filteredData = filteredData
          .where((item) => item['status'] == _selectedStatus)
          .toList();
    }

    // Apply age range filter (for donations and requests)
    filteredData = filteredData.where((item) {
      if (item['age'] != null) {
        final age = item['age'] as int;
        return age >= _ageRange.start && age <= _ageRange.end;
      }
      return true;
    }).toList();

    // Apply quantity range filter (for blood inventory)
    filteredData = filteredData.where((item) {
      if (item['quantity'] != null) {
        final quantity = item['quantity'] as int;
        return quantity >= _quantityRange.start &&
            quantity <= _quantityRange.end;
      }
      return true;
    }).toList();

    // Apply text search
    if (query.isNotEmpty) {
      filteredData = filteredData.where((item) {
        return item['displayName'].toLowerCase().contains(query) ||
            item['description'].toLowerCase().contains(query) ||
            (item['bloodGroup']?.toString().toLowerCase().contains(query) ??
                false) ||
            (item['donorName']?.toString().toLowerCase().contains(query) ??
                false) ||
            (item['requesterName']?.toString().toLowerCase().contains(query) ??
                false);
      }).toList();
    }

    setState(() {
      _searchResults = filteredData;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ThemeManager.currentThemeData;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search & Filter'),
        backgroundColor: currentTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showHelpDialog();
            },
            tooltip: 'Help',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Controls
          _buildSearchAndFilterControls(),

          // Results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildResultsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          // Category Selector
          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All Categories')),
              DropdownMenuItem(
                value: 'blood_inventory',
                child: Text('Blood Inventory'),
              ),
              DropdownMenuItem(value: 'donations', child: Text('Donations')),
              DropdownMenuItem(
                value: 'blood_requests',
                child: Text('Blood Requests'),
              ),
            ],
            onChanged: (newValue) {
              setState(() => _selectedCategory = newValue!);
              _performSearch();
            },
          ),

          const SizedBox(height: 16),

          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _performSearch();
                      },
                    )
                  : null,
              border: const OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          // Filters Row
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  'Blood Group',
                  _selectedBloodGroup,
                  const [
                    'all',
                    'A+',
                    'A-',
                    'B+',
                    'B-',
                    'AB+',
                    'AB-',
                    'O+',
                    'O-',
                  ],
                  (newValue) {
                    setState(() => _selectedBloodGroup = newValue!);
                    _performSearch();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterDropdown(
                  'Status',
                  _selectedStatus,
                  const ['all', 'Available', 'Reserved', 'Used', 'Expired'],
                  (newValue) {
                    setState(() => _selectedStatus = newValue!);
                    _performSearch();
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Range Filters
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Age Range: ${_ageRange.start.toInt()}-${_ageRange.end.toInt()}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    RangeSlider(
                      values: _ageRange,
                      min: 18,
                      max: 65,
                      divisions: 47,
                      labels: RangeLabels(
                        _ageRange.start.toInt().toString(),
                        _ageRange.end.toInt().toString(),
                      ),
                      onChanged: (RangeValues values) {
                        setState(() {
                          _ageRange = values;
                        });
                        _performSearch();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quantity Range: ${_quantityRange.start.toInt()}-${_quantityRange.end.toInt()}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    RangeSlider(
                      values: _quantityRange,
                      min: 0,
                      max: 200,
                      divisions: 40,
                      labels: RangeLabels(
                        _quantityRange.start.toInt().toString(),
                        _quantityRange.end.toInt().toString(),
                      ),
                      onChanged: (RangeValues values) {
                        setState(() {
                          _quantityRange = values;
                        });
                        _performSearch();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Results Summary
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Found ${_searchResults.length} results',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (_searchResults.isNotEmpty)
                  TextButton(
                    onPressed: _exportResults,
                    child: const Text('Export'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String value,
    List<String> options,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: options.map((option) {
        String displayText = option == 'all' ? 'All' : option;
        return DropdownMenuItem(value: option, child: Text(displayText));
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildResultsList() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search criteria or filters',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        return _buildResultCard(item, index);
      },
    );
  }

  Widget _buildResultCard(Map<String, dynamic> item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: _buildCategoryIcon(item),
        title: _buildItemTitle(item),
        subtitle: _buildItemSubtitle(item),
        trailing: _buildItemTrailing(item),
        onTap: () => _showItemDetails(item),
      ),
    );
  }

  Widget _buildCategoryIcon(Map<String, dynamic> item) {
    IconData iconData;
    Color iconColor;

    switch (item['category']) {
      case 'blood_inventory':
        iconData = Icons.bloodtype;
        iconColor = Colors.red;
        break;
      case 'donations':
        iconData = Icons.favorite;
        iconColor = Colors.pink;
        break;
      case 'blood_requests':
        iconData = Icons.medical_services;
        iconColor = Colors.orange;
        break;
      default:
        iconData = Icons.info;
        iconColor = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: iconColor.withValues(alpha: 0.1),
      child: Icon(iconData, color: iconColor),
    );
  }

  Widget _buildItemTitle(Map<String, dynamic> item) {
    return Text(
      item['displayName'] ?? 'Unknown Item',
      style: const TextStyle(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildItemSubtitle(Map<String, dynamic> item) {
    return Text(item['description'] ?? 'No description available');
  }

  Widget _buildItemTrailing(Map<String, dynamic> item) {
    return Text(
      item['bloodGroup'] ?? 'N/A',
      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
    );
  }

  void _showItemDetails(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${item['displayName']} Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: item.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        '${entry.key}:',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(child: Text(entry.value?.toString() ?? 'N/A')),
                  ],
                ),
              );
            }).toList(),
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

  void _exportResults() {
    // In a real app, this would export to CSV or PDF
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export feature coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help'),
        content: const Text(
          'This page allows you to search and filter blood inventory, donations, and blood requests. Use the filters on the left to narrow down your search. You can search by category, blood group, status, age, and quantity. The search bar at the top will search across all available fields.',
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
}
