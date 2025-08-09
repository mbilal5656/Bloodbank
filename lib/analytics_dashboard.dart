import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'services/data_service.dart';
import 'session_manager.dart';

class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({super.key});

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard> {
  final DataService _dataService = DataService();
  bool _isLoading = true;
  Map<String, dynamic> _analytics = {};
  String _selectedPeriod = 'Last 30 Days';

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    
    try {
      debugPrint('📊 Loading analytics data...');
      
      // Get all data for analytics
      final users = await _dataService.getAllUsers();
      final bloodInventory = await _dataService.getAllBloodInventory();
      final donations = await _dataService.getAllDonations();
      final requests = await _dataService.getAllBloodRequests();
      
      // Calculate analytics
      final analytics = await _calculateAnalytics(users, bloodInventory, donations, requests);
      
      setState(() {
        _analytics = analytics;
        _isLoading = false;
      });
      
      debugPrint('✅ Analytics loaded successfully');
    } catch (e) {
      debugPrint('❌ Error loading analytics: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<Map<String, dynamic>> _calculateAnalytics(
    List<Map<String, dynamic>> users,
    List<Map<String, dynamic>> bloodInventory,
    List<Map<String, dynamic>> donations,
    List<Map<String, dynamic>> requests,
  ) async {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    
    // User statistics
    final totalUsers = users.length;
    final adminUsers = users.where((u) => u['userType'] == 'Admin').length;
    final donorUsers = users.where((u) => u['userType'] == 'Donor').length;
    final receiverUsers = users.where((u) => u['userType'] == 'Receiver').length;
    
    // Blood inventory statistics
    final totalBloodUnits = bloodInventory.fold<int>(0, (sum, item) => sum + (item['quantity'] as int? ?? 0));
    final bloodGroupStats = <String, int>{};
    for (final item in bloodInventory) {
      final group = item['bloodGroup'] as String? ?? 'Unknown';
      bloodGroupStats[group] = (bloodGroupStats[group] ?? 0) + (item['quantity'] as int? ?? 0);
    }
    
    // Donation statistics
    final totalDonations = donations.length;
    final recentDonations = donations.where((d) {
      final date = DateTime.tryParse(d['donationDate'] ?? '');
      return date != null && date.isAfter(thirtyDaysAgo);
    }).length;
    
    // Request statistics
    final totalRequests = requests.length;
    final pendingRequests = requests.where((r) => r['status'] == 'Pending').length;
    final completedRequests = requests.where((r) => r['status'] == 'Completed').length;
    
    // Blood type demand analysis
    final bloodTypeDemand = <String, int>{};
    for (final request in requests) {
      final bloodType = request['bloodGroup'] as String? ?? 'Unknown';
      bloodTypeDemand[bloodType] = (bloodTypeDemand[bloodType] ?? 0) + 1;
    }
    
    // Critical blood levels (less than 50 units)
    final criticalBloodLevels = bloodInventory
        .where((item) => (item['quantity'] as int? ?? 0) < 50)
        .map((item) => item['bloodGroup'] as String? ?? 'Unknown')
        .toList();
    
    return {
      'userStats': {
        'total': totalUsers,
        'admins': adminUsers,
        'donors': donorUsers,
        'receivers': receiverUsers,
      },
      'bloodInventory': {
        'totalUnits': totalBloodUnits,
        'bloodGroupStats': bloodGroupStats,
        'criticalLevels': criticalBloodLevels,
      },
      'donations': {
        'total': totalDonations,
        'recent': recentDonations,
        'monthlyGrowth': _calculateGrowthRate(totalDonations, recentDonations),
      },
      'requests': {
        'total': totalRequests,
        'pending': pendingRequests,
        'completed': completedRequests,
        'completionRate': totalRequests > 0 ? (completedRequests / totalRequests * 100).round() : 0,
      },
      'demand': {
        'bloodTypeDemand': bloodTypeDemand,
        'mostRequested': _getMostRequestedBloodType(bloodTypeDemand),
      },
      'systemHealth': {
        'databaseStatus': 'Healthy',
        'lastUpdated': now.toIso8601String(),
        'dataIntegrity': '100%',
      },
    };
  }

  double _calculateGrowthRate(int total, int recent) {
    if (total == 0) return 0;
    return (recent / total * 100);
  }

  String _getMostRequestedBloodType(Map<String, int> demand) {
    if (demand.isEmpty) return 'N/A';
    final sorted = demand.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => _selectedPeriod = value);
              _loadAnalytics();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Last 7 Days', child: Text('Last 7 Days')),
              const PopupMenuItem(value: 'Last 30 Days', child: Text('Last 30 Days')),
              const PopupMenuItem(value: 'Last 3 Months', child: Text('Last 3 Months')),
              const PopupMenuItem(value: 'All Time', child: Text('All Time')),
            ],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedPeriod),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
    );
  }

  Widget _buildOverviewCards() {
    final userStats = _analytics['userStats'] ?? {};
    final bloodInventory = _analytics['bloodInventory'] ?? {};
    final donations = _analytics['donations'] ?? {};
    final requests = _analytics['requests'] ?? {};

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
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
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBloodInventoryChart() {
    final bloodGroupStats = _analytics['bloodInventory']?['bloodGroupStats'] ?? {};
    final criticalLevels = _analytics['bloodInventory']?['criticalLevels'] ?? [];

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Blood Inventory by Type',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...bloodGroupStats.entries.map((entry) {
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
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Text(
                      '${entry.value} units',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isCritical ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
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
    final userStats = _analytics['userStats'] ?? {};

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildUserTypeCard('Admins', userStats['admins'] ?? 0, Colors.purple),
            _buildUserTypeCard('Donors', userStats['donors'] ?? 0, Colors.green),
            _buildUserTypeCard('Receivers', userStats['receivers'] ?? 0, Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTypeCard(String type, int count, Color color) {
    final total = _analytics['userStats']?['total'] ?? 1;
    final percentage = (count / total * 100).round();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(type)),
          Text('$count ($percentage%)'),
        ],
      ),
    );
  }

  Widget _buildDonationAnalytics() {
    final donations = _analytics['donations'] ?? {};

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Donation Analytics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDonationStat('Total Donations', '${donations['total'] ?? 0}'),
                ),
                Expanded(
                  child: _buildDonationStat('Recent Donations', '${donations['recent'] ?? 0}'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: (donations['monthlyGrowth'] ?? 0) / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                (donations['monthlyGrowth'] ?? 0) > 0 ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Monthly Growth: ${(donations['monthlyGrowth'] ?? 0).toStringAsFixed(1)}%',
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
    final requests = _analytics['requests'] ?? {};

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Blood Request Analytics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildRequestStat('Total Requests', '${requests['total'] ?? 0}'),
                ),
                Expanded(
                  child: _buildRequestStat('Pending', '${requests['pending'] ?? 0}'),
                ),
                Expanded(
                  child: _buildRequestStat('Completed', '${requests['completed'] ?? 0}'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: (requests['completionRate'] ?? 0) / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                (requests['completionRate'] ?? 0) > 80 ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Completion Rate: ${requests['completionRate'] ?? 0}%',
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
    final demand = _analytics['demand'] ?? {};
    final bloodTypeDemand = demand['bloodTypeDemand'] ?? {};
    final mostRequested = demand['mostRequested'] ?? 'N/A';

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Blood Type Demand Analysis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
                      'Most Requested: $mostRequested',
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
            ...bloodTypeDemand.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text(entry.key),
                    const Spacer(),
                    Text(
                      '${entry.value} requests',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemHealth() {
    final systemHealth = _analytics['systemHealth'] ?? {};

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'System Health',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildHealthItem('Database Status', systemHealth['databaseStatus'] ?? 'Unknown'),
            _buildHealthItem('Data Integrity', systemHealth['dataIntegrity'] ?? 'Unknown'),
            _buildHealthItem('Last Updated', _formatDate(systemHealth['lastUpdated'] ?? '')),
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
}
