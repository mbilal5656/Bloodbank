import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/data_service.dart';
import 'theme/theme_provider.dart';
import 'theme_manager.dart';

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
                      // Notify the theme provider to update
                      context.read<ThemeProvider>().notifyListeners();
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
                                vertical: 4),
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

  @override
  Widget build(BuildContext context) {
    final currentTheme = context.watch<ThemeProvider>().currentAppTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Inventory'),
        backgroundColor: currentTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBloodInventory,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: () => _showThemeSelector(),
            tooltip: 'Change Theme',
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              currentTheme.primaryColor,
              currentTheme.primaryColor.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: currentTheme.secondaryColor,
                  ),
                )
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
    final currentTheme = context.watch<ThemeProvider>().currentAppTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: currentTheme.secondaryColor.withValues(alpha: 0.3),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(
            Icons.bloodtype,
            size: 40,
            color: currentTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Blood Inventory',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Current blood stock levels and availability',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryGrid() {
    final currentTheme = context.watch<ThemeProvider>().currentAppTheme;
    final bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: currentTheme.surfaceColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: currentTheme.secondaryColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
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
              childAspectRatio: 1.0, // Reduced from 1.2 to give more height
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
    final currentTheme = context.watch<ThemeProvider>().currentAppTheme;

    return Container(
      decoration: BoxDecoration(
        color: currentTheme.surfaceColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBloodGroupColor(bloodGroup).withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12), // Reduced from 16 to 12
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50, // Reduced from 60 to 50
              height: 50, // Reduced from 60 to 50
              decoration: BoxDecoration(
                color: _getBloodGroupColor(bloodGroup).withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  bloodGroup,
                  style: TextStyle(
                    fontSize: 18, // Reduced from 20 to 18
                    fontWeight: FontWeight.bold,
                    color: _getBloodGroupColor(bloodGroup),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8), // Reduced from 12 to 8
            Text(
              '$units Units',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16, // Reduced from 18 to 16
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6), // Reduced from 8 to 6
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), // Reduced padding
              decoration: BoxDecoration(
                color: _getStatusColor(status).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8), // Reduced from 12 to 8
                border: Border.all(color: _getStatusColor(status), width: 1),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: _getStatusColor(status),
                  fontSize: 11, // Reduced from 12 to 11
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
    final currentTheme = context.watch<ThemeProvider>().currentAppTheme;
    final totalUnits = _bloodInventory.values.fold(
      0,
      (sum, units) => sum + units,
    );
    final availableGroups = _bloodInventory.values
        .where((units) => units > 0)
        .length;
    final lowStockGroups = _bloodInventory.values
        .where((units) => units > 0 && units < 5)
        .length;
    final outOfStockGroups = _bloodInventory.values
        .where((units) => units == 0)
        .length;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: currentTheme.surfaceColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: currentTheme.secondaryColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
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
    final currentTheme = context.watch<ThemeProvider>().currentAppTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: currentTheme.surfaceColor.withValues(alpha: 0.05),
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
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
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
