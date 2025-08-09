import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'services/data_service.dart';

class SearchFilterPage extends StatefulWidget {
  const SearchFilterPage({super.key});

  @override
  State<SearchFilterPage> createState() => _SearchFilterPageState();
}

class _SearchFilterPageState extends State<SearchFilterPage> {
  final DataService _dataService = DataService();
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'blood_inventory';
  String _selectedBloodGroup = 'All';
  String _selectedStatus = 'All';
  String _selectedUserType = 'All';

  List<Map<String, dynamic>> _allData = [];
  List<Map<String, dynamic>> _filteredData = [];
  bool _isLoading = true;

  final List<String> _categories = [
    'blood_inventory',
    'donors',
    'receivers',
    'donations',
    'requests',
  ];

  final List<String> _bloodGroups = [
    'All',
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  final List<String> _statuses = [
    'All',
    'Available',
    'Reserved',
    'Used',
    'Expired',
  ];

  final List<String> _userTypes = ['All', 'Admin', 'Donor', 'Receiver'];

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterData);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      debugPrint('🔍 Loading data for search and filter...');

      switch (_selectedCategory) {
        case 'blood_inventory':
          _allData = await _dataService.getAllBloodInventory();
          break;
        case 'donors':
          final users = await _dataService.getAllUsers();
          _allData = users
              .where((user) => user['userType'] == 'Donor')
              .toList();
          break;
        case 'receivers':
          final users = await _dataService.getAllUsers();
          _allData = users
              .where((user) => user['userType'] == 'Receiver')
              .toList();
          break;
        case 'donations':
          _allData = await _dataService.getAllDonations();
          break;
        case 'requests':
          _allData = await _dataService.getAllBloodRequests();
          break;
      }

      _filterData();
      setState(() => _isLoading = false);
      debugPrint('✅ Data loaded: ${_allData.length} items');
    } catch (e) {
      debugPrint('❌ Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterData() {
    final searchTerm = _searchController.text.toLowerCase();

    _filteredData = _allData.where((item) {
      // Text search
      bool matchesSearch = false;
      if (searchTerm.isEmpty) {
        matchesSearch = true;
      } else {
        // Search in relevant fields based on category
        switch (_selectedCategory) {
          case 'blood_inventory':
            matchesSearch =
                (item['bloodGroup']?.toString().toLowerCase().contains(
                      searchTerm,
                    ) ??
                    false) ||
                (item['status']?.toString().toLowerCase().contains(
                      searchTerm,
                    ) ??
                    false) ||
                (item['notes']?.toString().toLowerCase().contains(searchTerm) ??
                    false);
            break;
          case 'donors':
          case 'receivers':
            matchesSearch =
                (item['name']?.toString().toLowerCase().contains(searchTerm) ??
                    false) ||
                (item['email']?.toString().toLowerCase().contains(searchTerm) ??
                    false) ||
                (item['bloodGroup']?.toString().toLowerCase().contains(
                      searchTerm,
                    ) ??
                    false) ||
                (item['contactNumber']?.toString().toLowerCase().contains(
                      searchTerm,
                    ) ??
                    false);
            break;
          case 'donations':
            matchesSearch =
                (item['donorName']?.toString().toLowerCase().contains(
                      searchTerm,
                    ) ??
                    false) ||
                (item['bloodGroup']?.toString().toLowerCase().contains(
                      searchTerm,
                    ) ??
                    false) ||
                (item['donationDate']?.toString().toLowerCase().contains(
                      searchTerm,
                    ) ??
                    false);
            break;
          case 'requests':
            matchesSearch =
                (item['requesterName']?.toString().toLowerCase().contains(
                      searchTerm,
                    ) ??
                    false) ||
                (item['bloodGroup']?.toString().toLowerCase().contains(
                      searchTerm,
                    ) ??
                    false) ||
                (item['status']?.toString().toLowerCase().contains(
                      searchTerm,
                    ) ??
                    false);
            break;
        }
      }

      // Blood group filter
      bool matchesBloodGroup =
          _selectedBloodGroup == 'All' ||
          (item['bloodGroup']?.toString() == _selectedBloodGroup);

      // Status filter
      bool matchesStatus =
          _selectedStatus == 'All' ||
          (item['status']?.toString() == _selectedStatus);

      // User type filter
      bool matchesUserType =
          _selectedUserType == 'All' ||
          (item['userType']?.toString() == _selectedUserType);

      return matchesSearch &&
          matchesBloodGroup &&
          matchesStatus &&
          matchesUserType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search & Filter'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
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
            value: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: _categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(_getCategoryDisplayName(category)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedCategory = value!);
              _loadData();
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
                        _filterData();
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
                  _bloodGroups,
                  (value) {
                    setState(() => _selectedBloodGroup = value!);
                    _filterData();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterDropdown(
                  'Status',
                  _selectedStatus,
                  _statuses,
                  (value) {
                    setState(() => _selectedStatus = value!);
                    _filterData();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterDropdown(
                  'User Type',
                  _selectedUserType,
                  _userTypes,
                  (value) {
                    setState(() => _selectedUserType = value!);
                    _filterData();
                  },
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
                  'Found ${_filteredData.length} results',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (_filteredData.isNotEmpty)
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
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: options.map((option) {
        return DropdownMenuItem(value: option, child: Text(option));
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildResultsList() {
    if (_filteredData.isEmpty) {
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
      itemCount: _filteredData.length,
      itemBuilder: (context, index) {
        final item = _filteredData[index];
        return _buildResultCard(item, index);
      },
    );
  }

  Widget _buildResultCard(Map<String, dynamic> item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: _buildCategoryIcon(),
        title: _buildItemTitle(item),
        subtitle: _buildItemSubtitle(item),
        trailing: _buildItemTrailing(item),
        onTap: () => _showItemDetails(item),
      ),
    );
  }

  Widget _buildCategoryIcon() {
    IconData iconData;
    Color iconColor;

    switch (_selectedCategory) {
      case 'blood_inventory':
        iconData = Icons.bloodtype;
        iconColor = Colors.red;
        break;
      case 'donors':
        iconData = Icons.person_add;
        iconColor = Colors.green;
        break;
      case 'receivers':
        iconData = Icons.person;
        iconColor = Colors.blue;
        break;
      case 'donations':
        iconData = Icons.favorite;
        iconColor = Colors.pink;
        break;
      case 'requests':
        iconData = Icons.medical_services;
        iconColor = Colors.orange;
        break;
      default:
        iconData = Icons.info;
        iconColor = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: iconColor.withOpacity(0.1),
      child: Icon(iconData, color: iconColor),
    );
  }

  Widget _buildItemTitle(Map<String, dynamic> item) {
    switch (_selectedCategory) {
      case 'blood_inventory':
        return Text(
          '${item['bloodGroup']} - ${item['quantity']} units',
          style: const TextStyle(fontWeight: FontWeight.bold),
        );
      case 'donors':
      case 'receivers':
        return Text(
          item['name'] ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.bold),
        );
      case 'donations':
        return Text(
          '${item['donorName'] ?? 'Unknown'} - ${item['bloodGroup']}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        );
      case 'requests':
        return Text(
          '${item['requesterName'] ?? 'Unknown'} - ${item['bloodGroup']}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        );
      default:
        return const Text('Unknown Item');
    }
  }

  Widget _buildItemSubtitle(Map<String, dynamic> item) {
    switch (_selectedCategory) {
      case 'blood_inventory':
        return Text('Status: ${item['status'] ?? 'Unknown'}');
      case 'donors':
      case 'receivers':
        return Text('${item['email']} • ${item['bloodGroup']}');
      case 'donations':
        return Text('Date: ${_formatDate(item['donationDate'])}');
      case 'requests':
        return Text(
          'Status: ${item['status']} • Date: ${_formatDate(item['requestDate'])}',
        );
      default:
        return const Text('');
    }
  }

  Widget _buildItemTrailing(Map<String, dynamic> item) {
    switch (_selectedCategory) {
      case 'blood_inventory':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(item['status']).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            item['status'] ?? 'Unknown',
            style: TextStyle(
              color: _getStatusColor(item['status']),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      case 'donors':
      case 'receivers':
        return Text(
          item['bloodGroup'] ?? 'N/A',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        );
      case 'donations':
        return Icon(Icons.favorite, color: Colors.pink[400]);
      case 'requests':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(item['status']).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            item['status'] ?? 'Unknown',
            style: TextStyle(
              color: _getStatusColor(item['status']),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      default:
        return const Icon(Icons.arrow_forward_ios, size: 16);
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'available':
      case 'completed':
        return Colors.green;
      case 'reserved':
      case 'pending':
        return Colors.orange;
      case 'used':
      case 'cancelled':
        return Colors.red;
      case 'expired':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  void _showItemDetails(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${_getCategoryDisplayName(_selectedCategory)} Details'),
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

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'blood_inventory':
        return 'Blood Inventory';
      case 'donors':
        return 'Donors';
      case 'receivers':
        return 'Receivers';
      case 'donations':
        return 'Donations';
      case 'requests':
        return 'Blood Requests';
      default:
        return category;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid Date';
    }
  }
}
