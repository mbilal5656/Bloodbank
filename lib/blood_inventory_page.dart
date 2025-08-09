import 'package:flutter/material.dart';
import 'services/data_service.dart';


class BloodInventoryPage extends StatefulWidget {
  const BloodInventoryPage({super.key});

  @override
  State<BloodInventoryPage> createState() => _BloodInventoryPageState();
}

class _BloodInventoryPageState extends State<BloodInventoryPage> {
  Map<String, int> _bloodInventory = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBloodInventory();
  }

  Future<void> _loadBloodInventory() async {
    try {
      final dataService = DataService();
      final inventory = await dataService.getBloodInventorySummary();

      if (inventory.isNotEmpty) {
        setState(() {
          _bloodInventory = inventory;
          _isLoading = false;
        });
      } else {
        setState(() {
          _bloodInventory = {};
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _bloodInventory = {};
        _isLoading = false;
      });
    }
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

  String _getAvailabilityStatus(int units) {
    if (units == 0) return 'Out of Stock';
    if (units < 5) return 'Low Stock';
    return 'Available';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Available':
        return Colors.green;
      case 'Low Stock':
        return Colors.orange;
      case 'Out of Stock':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBloodInventory,
            tooltip: 'Refresh',
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
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildInventoryGrid(),
                      const SizedBox(height: 32),
                      _buildStatistics(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.bloodtype,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Blood Inventory',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Current blood stock levels and availability',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryGrid() {
    final bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Blood Group Availability',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: bloodGroups.length,
            itemBuilder: (context, index) {
              final bloodGroup = bloodGroups[index];
              final units = _bloodInventory[bloodGroup] ?? 0;
              final status = _getAvailabilityStatus(units);

              return _buildBloodGroupCard(
                bloodGroup: bloodGroup,
                units: units,
                status: status,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBloodGroupCard({
    required String bloodGroup,
    required int units,
    required String status,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBloodGroupColor(bloodGroup).withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _getBloodGroupColor(bloodGroup).withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  bloodGroup,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _getBloodGroupColor(bloodGroup),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$units Units',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getStatusColor(status),
                  width: 1,
                ),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: _getStatusColor(status),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    final totalUnits =
        _bloodInventory.values.fold(0, (sum, units) => sum + units);
    final availableGroups =
        _bloodInventory.values.where((units) => units > 0).length;
    final lowStockGroups =
        _bloodInventory.values.where((units) => units > 0 && units < 5).length;
    final outOfStockGroups =
        _bloodInventory.values.where((units) => units == 0).length;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Inventory Statistics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildStatCard(
            icon: Icons.inventory,
            title: 'Total Units',
            value: '$totalUnits',
            color: Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            icon: Icons.check_circle,
            title: 'Available Groups',
            value: '$availableGroups/8',
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            icon: Icons.warning,
            title: 'Low Stock Groups',
            value: '$lowStockGroups',
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            icon: Icons.cancel,
            title: 'Out of Stock',
            value: '$outOfStockGroups',
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
