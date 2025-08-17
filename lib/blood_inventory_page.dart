import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/data_service.dart';
import 'theme/theme_provider.dart';
import 'theme_manager.dart';
import 'dart:math' as math;
import 'session_manager.dart';
import 'edit_blood_inventory_dialog.dart';
import 'models/blood_inventory_model.dart';

class BloodInventoryPage extends StatefulWidget {
  const BloodInventoryPage({super.key});

  @override
  State<BloodInventoryPage> createState() => _BloodInventoryPageState();
}

class _BloodInventoryPageState extends State<BloodInventoryPage>
    with TickerProviderStateMixin {
  Map<String, int> _bloodInventory = {};
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Chart visibility controls
  bool _showBarChart = true;
  bool _showPieChart = true;
  bool _showTrendChart = true;
  bool _showStatistics = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadBloodInventory();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
        _animationController.forward();
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

  // Check if current user is admin
  Future<bool> _isCurrentUserAdmin() async {
    try {
      final userType = await SessionManager.getUserType();
      return userType == 'Admin';
    } catch (e) {
      return false;
    }
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
        final newInventory = BloodInventoryModel(
          bloodGroup: selectedBloodGroup,
          quantity: 0,
          reservedQuantity: 0,
          status: 'Available',
          expiryDate: DateTime.now().add(const Duration(days: 30)),
          lastUpdated: DateTime.now(),
          notes: null,
        );

        final result = await showDialog<bool>(
          context: context,
          builder: (context) => EditBloodInventoryDialog(
            bloodInventory: newInventory,
            onInventoryUpdated: () {
              _loadBloodInventory();
            },
          ),
        );

        if (result == true) {
          // Refresh the inventory after successful add
          _loadBloodInventory();
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
    final currentTheme = ThemeManager.currentThemeData;
    final bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: currentTheme.surfaceColor,
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
                color: currentTheme.primaryColor,
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
                        color: currentTheme.surfaceColor,
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

  // Show edit dialog for blood inventory
  Future<void> _showEditDialog(String bloodGroup, int currentUnits) async {
    try {
      final dataService = DataService();
      final allInventory = await dataService.getAllBloodInventory();

      // Find the specific blood inventory item
      final inventoryItem = allInventory.firstWhere(
        (item) => item['bloodGroup'] == bloodGroup,
        orElse: () => {
          'id': 0,
          'bloodGroup': bloodGroup,
          'quantity': currentUnits,
          'reservedQuantity': 0,
          'status': 'Available',
          'expiryDate': null,
          'lastUpdated': DateTime.now().toIso8601String(),
          'createdBy': null,
          'notes': null,
        },
      );

      if (inventoryItem['id'] == 0) {
        // Create new inventory item if it doesn't exist
        final newItem = await dataService.addBloodInventory(inventoryItem);
        if (newItem) {
          // Refresh the inventory
          _loadBloodInventory();
        }
        return;
      }

      // Convert to BloodInventoryModel
      final bloodInventoryModel = BloodInventoryModel.fromMap(inventoryItem);

      if (mounted) {
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => EditBloodInventoryDialog(
            bloodInventory: bloodInventoryModel,
            onInventoryUpdated: () {
              _loadBloodInventory();
            },
          ),
        );

        if (result == true) {
          // Refresh the inventory after successful edit
          _loadBloodInventory();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening edit dialog: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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

  // Chart building methods
  Widget _buildBarChart() {
    final currentTheme = context.watch<ThemeProvider>().currentAppTheme;
    final bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    final maxUnits = _bloodInventory.values.isEmpty
        ? 1
        : _bloodInventory.values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: currentTheme.surfaceColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: currentTheme.secondaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Blood Group Distribution (Bar Chart)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: bloodGroups.map((bloodGroup) {
                final units = _bloodInventory[bloodGroup] ?? 0;
                final height = maxUnits > 0 ? (units / maxUnits) * 150.0 : 0.0;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 30,
                      height: height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            _getBloodGroupColor(bloodGroup),
                            _getBloodGroupColor(
                              bloodGroup,
                            ).withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _getBloodGroupColor(
                              bloodGroup,
                            ).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      bloodGroup,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$units',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 10,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    final currentTheme = context.watch<ThemeProvider>().currentAppTheme;
    final bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    final totalUnits = _bloodInventory.values.fold(
      0,
      (sum, units) => sum + units,
    );

    if (totalUnits == 0) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: currentTheme.surfaceColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: currentTheme.secondaryColor.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Text(
              'Blood Group Distribution (Pie Chart)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No data available',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: currentTheme.surfaceColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: currentTheme.secondaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Blood Group Distribution (Pie Chart)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 200,
                      child: CustomPaint(
                        painter: PieChartPainter(
                          bloodInventory: _bloodInventory,
                          bloodGroups: bloodGroups,
                        ),
                      ),
                    ),
                    // Center text showing total
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$totalUnits',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Total Units',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: bloodGroups.map((bloodGroup) {
                    final units = _bloodInventory[bloodGroup] ?? 0;
                    final percentage = totalUnits > 0
                        ? (units / totalUnits * 100)
                        : 0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: _getBloodGroupColor(bloodGroup),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '$bloodGroup: ${percentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart() {
    final currentTheme = context.watch<ThemeProvider>().currentAppTheme;
    final bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

    // Simulate trend data (in a real app, this would come from historical data)
    final trendData = Map<String, List<int>>.fromIterable(
      bloodGroups,
      key: (bloodGroup) => bloodGroup,
      value: (bloodGroup) {
        final currentUnits = _bloodInventory[bloodGroup] ?? 0;
        return [
          (currentUnits * 0.8).round(),
          (currentUnits * 0.9).round(),
          currentUnits,
        ];
      },
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: currentTheme.surfaceColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: currentTheme.secondaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Inventory Trends (Line Chart)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: CustomPaint(
              painter: TrendChartPainter(
                trendData: trendData,
                bloodGroups: bloodGroups,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTrendLegend('Previous', Colors.grey),
              _buildTrendLegend('Recent', Colors.orange),
              _buildTrendLegend('Current', Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _showChartControls() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildChartControls(),
    );
  }

  Widget _buildChartControls() {
    final currentTheme = context.watch<ThemeProvider>().currentAppTheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = (screenHeight * 0.6).clamp(
      400.0,
      screenHeight * 0.8,
    ); // Ensure reasonable bounds
    final minHeight =
        250.0; // Further reduced minimum height for better compatibility

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight, minHeight: minHeight),
      decoration: BoxDecoration(
        color: currentTheme.surfaceColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
                Icon(Icons.bar_chart, color: currentTheme.primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Chart Controls',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: currentTheme.textColor,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: currentTheme.textColor),
                ),
              ],
            ),
          ),

          // Chart toggles
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildChartToggle(
                    'Bar Chart',
                    'Show blood group distribution as bars',
                    _showBarChart,
                    (value) => setState(() => _showBarChart = value),
                  ),
                  const SizedBox(height: 16),
                  _buildChartToggle(
                    'Pie Chart',
                    'Show blood group distribution as pie slices',
                    _showPieChart,
                    (value) => setState(() => _showPieChart = value),
                  ),
                  const SizedBox(height: 16),
                  _buildChartToggle(
                    'Trend Chart',
                    'Show inventory trends over time',
                    _showTrendChart,
                    (value) => setState(() => _showTrendChart = value),
                  ),
                  const SizedBox(height: 16),
                  _buildChartToggle(
                    'Statistics',
                    'Show inventory statistics cards',
                    _showStatistics,
                    (value) => setState(() => _showStatistics = value),
                  ),
                  // Add bottom padding to prevent overflow
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartToggle(
    String title,
    String description,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    final currentTheme = context.watch<ThemeProvider>().currentAppTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: currentTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: currentTheme.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: currentTheme.textColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: currentTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help'),
        content: const Text(
          'This application allows you to manage blood inventory for a blood bank. You can add new blood groups, edit existing ones, and view inventory trends and statistics.',
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
            icon: const Icon(Icons.bar_chart),
            onPressed: () => _showChartControls(),
            tooltip: 'Chart Controls',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBloodInventory,
            tooltip: 'Refresh',
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
      floatingActionButton: FutureBuilder<bool>(
        future: _isCurrentUserAdmin(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data == true) {
            return FloatingActionButton(
              onPressed: _showAddBloodInventoryDialog,
              backgroundColor: currentTheme.primaryColor,
              foregroundColor: Colors.white,
              tooltip: 'Add Blood Inventory',
              child: const Icon(Icons.add),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      body: Container(
        width: double.infinity,
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
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        16.0,
                        16.0,
                        16.0,
                        16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 20),
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: _buildInventoryGrid(),
                          ),
                          if (_showBarChart) ...[
                            const SizedBox(height: 20),
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: _buildBarChart(),
                            ),
                          ],
                          if (_showPieChart) ...[
                            const SizedBox(height: 20),
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: _buildPieChart(),
                            ),
                          ],
                          if (_showTrendChart) ...[
                            const SizedBox(height: 20),
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: _buildTrendChart(),
                            ),
                          ],
                          if (_showStatistics) ...[
                            const SizedBox(height: 20),
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: _buildStatistics(),
                            ),
                          ],
                          // Add bottom padding to prevent overflow
                          const SizedBox(height: 40),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final currentTheme = context.watch<ThemeProvider>().currentAppTheme;
    final totalUnits = _bloodInventory.values.fold(
      0,
      (sum, units) => sum + units,
    );
    final availableGroups = _bloodInventory.values
        .where((units) => units > 0)
        .length;

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
        const SizedBox(height: 24),
        // Summary cards
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              // Stack vertically on small screens
              return Column(
                children: [
                  _buildSummaryCard(
                    'Total Units',
                    '$totalUnits',
                    Icons.inventory,
                    Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryCard(
                    'Available Groups',
                    '$availableGroups/8',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ],
              );
            } else {
              // Row layout on larger screens
              return Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Total Units',
                      '$totalUnits',
                      Icons.inventory,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildSummaryCard(
                      'Available Groups',
                      '$availableGroups/8',
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
        border: Border.all(
          color: currentTheme.secondaryColor.withValues(alpha: 0.3),
        ),
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
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width < 600 ? 1 : 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: MediaQuery.of(context).size.width < 600
                  ? 1.2
                  : 1.0,
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
    final maxUnits = 200; // Set a reasonable maximum for visualization
    final progress = units / maxUnits;

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
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 50, // Reduced from 60 to 50
                  height: 50, // Reduced from 60 to 50
                  child: CircularProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    strokeWidth: 4,
                    backgroundColor: _getBloodGroupColor(
                      bloodGroup,
                    ).withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getBloodGroupColor(bloodGroup),
                    ),
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getBloodGroupColor(
                      bloodGroup,
                    ).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      bloodGroup,
                      style: TextStyle(
                        fontSize: 16, // Reduced from 18 to 16
                        fontWeight: FontWeight.bold,
                        color: _getBloodGroupColor(bloodGroup),
                      ),
                    ),
                  ),
                ),
              ],
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
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 3,
              ), // Reduced padding
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
            const SizedBox(height: 8),
            // Edit button for admins
            FutureBuilder<bool>(
              future: _isCurrentUserAdmin(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data == true) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showEditDialog(bloodGroup, units),
                      icon: Icon(Icons.edit, size: 16),
                      label: Text('Edit', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
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
        border: Border.all(
          color: currentTheme.secondaryColor.withValues(alpha: 0.3),
        ),
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

// Custom Painters for Charts
class PieChartPainter extends CustomPainter {
  final Map<String, int> bloodInventory;
  final List<String> bloodGroups;

  PieChartPainter({required this.bloodInventory, required this.bloodGroups});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 * 0.8;

    final totalUnits = bloodInventory.values.fold(
      0,
      (sum, units) => sum + units,
    );
    if (totalUnits == 0) return;

    double startAngle = -math.pi / 2; // Start from top

    for (int i = 0; i < bloodGroups.length; i++) {
      final bloodGroup = bloodGroups[i];
      final units = bloodInventory[bloodGroup] ?? 0;
      final sweepAngle = (units / totalUnits) * 2 * math.pi;

      if (sweepAngle > 0) {
        final paint = Paint()
          ..color = _getBloodGroupColor(bloodGroup)
          ..style = PaintingStyle.fill;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          true,
          paint,
        );

        startAngle += sweepAngle;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

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
}

class TrendChartPainter extends CustomPainter {
  final Map<String, List<int>> trendData;
  final List<String> bloodGroups;

  TrendChartPainter({required this.trendData, required this.bloodGroups});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final maxValue = trendData.values
        .expand((trend) => trend)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    if (maxValue == 0) return;

    final chartWidth = size.width;
    final chartHeight = size.height;
    final pointSpacing = chartWidth / 2; // 3 data points

    for (int i = 0; i < bloodGroups.length; i++) {
      final bloodGroup = bloodGroups[i];
      final trend = trendData[bloodGroup] ?? [0, 0, 0];
      final color = _getBloodGroupColor(bloodGroup);
      paint.color = color;

      final path = Path();
      bool firstPoint = true;

      for (int j = 0; j < trend.length; j++) {
        final x = j * pointSpacing;
        final y = chartHeight - (trend[j] / maxValue) * chartHeight;

        if (firstPoint) {
          path.moveTo(x, y);
          firstPoint = false;
        } else {
          path.lineTo(x, y);
        }

        // Draw data point
        canvas.drawCircle(Offset(x, y), 3, Paint()..color = color);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

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
}
