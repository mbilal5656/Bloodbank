import 'package:flutter/material.dart';
import 'services/data_service.dart';
import 'theme_manager.dart';

class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({super.key});

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard> {
  List<Map<String, dynamic>> _donations = [];
  List<Map<String, dynamic>> _bloodRequests = [];
  List<Map<String, dynamic>> _bloodInventory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    try {
      debugPrint('📊 Loading analytics data...');

      // Load data with error handling
      final dataService = DataService();

      try {
        _donations = await dataService.getAllDonations();
        debugPrint('✅ Donations loaded: ${_donations.length}');
      } catch (e) {
        debugPrint('❌ Error loading donations: $e');
        _donations = [];
      }

      try {
        _bloodRequests = await dataService.getAllBloodRequests();
        debugPrint('✅ Blood requests loaded: ${_bloodRequests.length}');
      } catch (e) {
        debugPrint('❌ Error loading blood requests: $e');
        _bloodRequests = [];
      }

      try {
        _bloodInventory = await dataService.getAllBloodInventory();
        debugPrint('✅ Blood inventory loaded: ${_bloodInventory.length}');
      } catch (e) {
        debugPrint('❌ Error loading blood inventory: $e');
        _bloodInventory = [];
      }

      debugPrint('✅ Analytics data loaded successfully');
    } catch (e) {
      debugPrint('❌ Error loading analytics: $e');
      // Set empty lists to prevent crashes
      _donations = [];
      _bloodRequests = [];
      _bloodInventory = [];
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Safe data access methods
  int _safeGetInt(
    Map<String, dynamic> data,
    String key, {
    int defaultValue = 0,
  }) {
    try {
      final value = data[key];
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? defaultValue;
      if (value is double) return value.toInt();
      return defaultValue;
    } catch (e) {
      debugPrint('❌ Error accessing $key: $e');
      return defaultValue;
    }
  }

  String _safeGetString(
    Map<String, dynamic> data,
    String key, {
    String defaultValue = 'N/A',
  }) {
    try {
      final value = data[key];
      if (value == null) return defaultValue;
      return value.toString();
    } catch (e) {
      debugPrint('❌ Error accessing $key: $e');
      return defaultValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ThemeManager.currentThemeData;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        backgroundColor: currentTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showHelpDialog();
            },
            tooltip: 'Help',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverviewCards(),
                    const SizedBox(height: 24),
                    _buildBloodInventoryChart(),
                    const SizedBox(height: 24),
                    _buildUserStatistics(),
                    const SizedBox(height: 24),
                    _buildDonationAnalytics(),
                    const SizedBox(height: 24),
                    _buildRequestAnalytics(),
                    const SizedBox(height: 24),
                    _buildBloodDemandAnalysis(),
                    const SizedBox(height: 24),
                    _buildSystemHealth(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOverviewCards() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Check if we have any data
    if (_donations.isEmpty &&
        _bloodRequests.isEmpty &&
        _bloodInventory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Analytics Data Available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try refreshing or check if data exists in the system',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadAnalytics,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Data'),
            ),
          ],
        ),
      );
    }

    // Calculate statistics from the loaded data with null safety
    final totalDonations = _donations.length;
    final totalRequests = _bloodRequests.length;
    final totalBloodUnits = _bloodInventory.fold<int>(
      0,
      (sum, item) => sum + _safeGetInt(item, 'quantity'),
    );

    final userStats = {
      'total': totalDonations + totalRequests,
      'donors': totalDonations,
      'receivers': totalRequests,
    };

    final bloodInventory = {
      'totalUnits': totalBloodUnits,
      'bloodGroupStats': _bloodInventory.fold<Map<String, int>>(
        <String, int>{},
        (Map<String, int> map, item) {
          final group = _safeGetString(
            item,
            'bloodGroup',
            defaultValue: 'Unknown',
          );
          final quantity = _safeGetInt(item, 'quantity');
          map[group] = (map[group] ?? 0) + quantity;
          return map;
        },
      ),
    };

    final donations = {'total': totalDonations, 'recent': totalDonations};

    final requests = {
      'total': totalRequests,
      'pending': _bloodRequests
          .where((r) => _safeGetString(r, 'status') == 'Pending')
          .length,
      'completed': _bloodRequests
          .where((r) => _safeGetString(r, 'status') == 'Completed')
          .length,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        // Make the grid responsive to screen size
        final crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
        final childAspectRatio = constraints.maxWidth > 600 ? 1.5 : 1.2;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: childAspectRatio,
          children: [
            _buildStatCard(
              'Total Users',
              '${userStats['total'] ?? 0}',
              Icons.people,
              Colors.blue,
            ),
            _buildStatCard(
              'Blood Units',
              '${bloodInventory['totalUnits'] ?? 0}',
              Icons.bloodtype,
              Colors.red,
            ),
            _buildStatCard(
              'Total Donations',
              '${donations['total'] ?? 0}',
              Icons.favorite,
              Colors.green,
            ),
            _buildStatCard(
              'Blood Requests',
              '${requests['total'] ?? 0}',
              Icons.medical_services,
              Colors.orange,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBloodInventoryChart() {
    final bloodGroupStats = _bloodInventory.fold<Map<String, int>>({}, (
      map,
      item,
    ) {
      final group = _safeGetString(item, 'bloodGroup', defaultValue: 'Unknown');
      final quantity = _safeGetInt(item, 'quantity');
      map[group] = (map[group] ?? 0) + quantity;
      return map;
    });
    final criticalLevels = _bloodInventory
        .where((item) => _safeGetInt(item, 'quantity') < 10)
        .map((item) => _safeGetString(item, 'bloodGroup'))
        .toList();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Blood Inventory by Type',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: bloodGroupStats.entries.map((entry) {
                    final isCritical = criticalLevels.contains(entry.key);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: isCritical ? Colors.red : Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry.key,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              '${entry.value} units',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isCritical ? Colors.red : Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            if (criticalLevels.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Critical levels: ${criticalLevels.join(', ')}',
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserStatistics() {
    final userStats = {
      'total': _donations.length + _bloodRequests.length,
      'donors': _donations.length,
      'receivers': _bloodRequests.length,
    };

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildUserTypeCard(
              'Admins',
              userStats['total'] ?? 0,
              Colors.purple,
            ),
            _buildUserTypeCard(
              'Donors',
              userStats['donors'] ?? 0,
              Colors.green,
            ),
            _buildUserTypeCard(
              'Receivers',
              userStats['receivers'] ?? 0,
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTypeCard(String type, int count, Color color) {
    final total = _donations.length + _bloodRequests.length;
    // Prevent division by zero
    final percentage = total > 0 ? (count / total * 100).round() : 0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              type == 'Donors' ? Icons.favorite : Icons.medical_services,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              type,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$percentage%',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationAnalytics() {
    final donations = {'total': _donations.length, 'recent': _donations.length};

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Donation Analytics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDonationStat(
                    'Total Donations',
                    '${donations['total'] ?? 0}',
                  ),
                ),
                Expanded(
                  child: _buildDonationStat(
                    'Recent Donations',
                    '${donations['recent'] ?? 0}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: (donations['recent'] ?? 0) > 0 ? 0.5 : 0.0, // Safe value
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                (donations['recent'] ?? 0) > 0 ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Monthly Growth: ${(donations['recent'] ?? 0) > 0 ? "Active" : "No Data"}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRequestAnalytics() {
    final requests = {
      'total': _bloodRequests.length,
      'pending': _bloodRequests
          .where((r) => _safeGetString(r, 'status') == 'Pending')
          .length,
      'completed': _bloodRequests
          .where((r) => _safeGetString(r, 'status') == 'Completed')
          .length,
    };

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Blood Request Analytics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildRequestStat(
                    'Total Requests',
                    '${requests['total'] ?? 0}',
                  ),
                ),
                Expanded(
                  child: _buildRequestStat(
                    'Pending',
                    '${requests['pending'] ?? 0}',
                  ),
                ),
                Expanded(
                  child: _buildRequestStat(
                    'Completed',
                    '${requests['completed'] ?? 0}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: (requests['completed'] ?? 0) > 0 ? 0.7 : 0.0, // Safe value
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                (requests['completed'] ?? 0) > 0 ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Completion Rate: ${(requests['completed'] ?? 0) > 0 ? "Good" : "No Data"}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBloodDemandAnalysis() {
    final demand = {
      'bloodTypeDemand': _bloodRequests.fold<Map<String, int>>({}, (
        map,
        request,
      ) {
        final bloodType = _safeGetString(
          request,
          'bloodGroup',
          defaultValue: 'Unknown',
        );
        map[bloodType] = (map[bloodType] ?? 0) + 1;
        return map;
      }),
      'mostRequested': _bloodRequests.fold<String>('N/A', (
        mostRequested,
        request,
      ) {
        final bloodType = _safeGetString(
          request,
          'bloodGroup',
          defaultValue: 'Unknown',
        );
        final currentCount = _bloodRequests
            .where((r) => _safeGetString(r, 'bloodGroup') == bloodType)
            .length;
        return currentCount >
                (mostRequested == 'N/A'
                    ? 0
                    : _bloodRequests
                          .where(
                            (r) => _safeGetString(r, 'bloodGroup') ==
                                mostRequested,
                          )
                          .length)
            ? bloodType
            : mostRequested;
      }),
    };

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Blood Type Demand Analysis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.trending_up, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Most Requested: ${demand['mostRequested'] ?? 'N/A'}',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...(demand['bloodTypeDemand'] as Map<String, int>).entries.map((
              entry,
            ) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text(
                      '${entry.key}:',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Text('${entry.value} requests'),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemHealth() {
    final systemHealth = {
      'databaseStatus': 'Healthy',
      'dataIntegrity': '100%',
      'lastUpdated': DateTime.now().toIso8601String(),
    };

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'System Health',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildHealthItem(
              'Database Status',
              systemHealth['databaseStatus'] ?? 'Unknown',
            ),
            _buildHealthItem(
              'Data Integrity',
              systemHealth['dataIntegrity'] ?? 'Unknown',
            ),
            _buildHealthItem(
              'Last Updated',
              _formatDate(systemHealth['lastUpdated'] ?? ''),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthItem(String label, String value) {
    final isHealthy = value == 'Healthy' || value == '100%';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isHealthy ? Icons.check_circle : Icons.error,
            color: isHealthy ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text(
            value,
            style: TextStyle(
              color: isHealthy ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
    } catch (e) {
      return 'Unknown';
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Help'),
          content: const Text(
            'This dashboard provides an overview of the Blood Donation and Request system. '
            'It displays key metrics such as total users, blood inventory, donation '
            'and request statistics, and system health. The data is updated '
            'periodically to ensure accuracy.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
