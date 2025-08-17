import 'package:flutter/material.dart';
import 'services/data_service.dart';

class QRCodeScanner extends StatefulWidget {
  const QRCodeScanner({super.key});

  @override
  State<QRCodeScanner> createState() => _QRCodeScannerState();
}

class _QRCodeScannerState extends State<QRCodeScanner> {
  final DataService _dataService = DataService();
  bool _isScanning = false;
  Map<String, dynamic>? _scannedItem;
  String _scanMode = 'blood_bag'; // 'blood_bag' or 'donor'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => _scanMode = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'blood_bag',
                child: Text('Blood Bag Scanner'),
              ),
              const PopupMenuItem(
                value: 'donor',
                child: Text('Donor ID Scanner'),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_scanMode == 'blood_bag' ? 'Blood Bag' : 'Donor ID'),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Scanner Mode Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: _scanMode == 'blood_bag' ? Colors.red[50] : Colors.blue[50],
            child: Row(
              children: [
                Icon(
                  _scanMode == 'blood_bag' ? Icons.bloodtype : Icons.person,
                  color: _scanMode == 'blood_bag'
                      ? Colors.red[700]
                      : Colors.blue[700],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _scanMode == 'blood_bag'
                        ? 'Scan blood bag QR code to track inventory'
                        : 'Scan donor QR code for quick identification',
                    style: TextStyle(
                      color: _scanMode == 'blood_bag'
                          ? Colors.red[700]
                          : Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scanner Area
          Expanded(child: _buildScannerArea()),

          // Results Area
          if (_scannedItem != null) _buildResultsArea(),
        ],
      ),
    );
  }

  Widget _buildScannerArea() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Mock Scanner View (in real app, use camera plugin)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.qr_code_scanner,
                  size: 80,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 16),
                Text(
                  'QR Code Scanner',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Position QR code within the frame',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.qr_code,
                      size: 60,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scan Button
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _isScanning ? null : _simulateScan,
                icon: _isScanning
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.qr_code_scanner),
                label: Text(_isScanning ? 'Scanning...' : 'Scan QR Code'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsArea() {
    if (_scannedItem == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[700]),
              const SizedBox(width: 8),
              Text(
                'Scan Successful!',
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildScannedItemDetails(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _clearResults,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.grey[700],
                  ),
                  child: const Text('Clear'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _viewDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('View Details'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScannedItemDetails() {
    if (_scannedItem == null) return const SizedBox.shrink();

    if (_scanMode == 'blood_bag') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Blood Group', _scannedItem!['bloodGroup'] ?? 'N/A'),
          _buildDetailRow(
            'Quantity',
            '${_scannedItem!['quantity'] ?? 0} units',
          ),
          _buildDetailRow('Status', _scannedItem!['status'] ?? 'N/A'),
          _buildDetailRow(
            'Last Updated',
            _formatDate(_scannedItem!['lastUpdated'] ?? ''),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Name', _scannedItem!['name'] ?? 'N/A'),
          _buildDetailRow('Blood Group', _scannedItem!['bloodGroup'] ?? 'N/A'),
          _buildDetailRow('User Type', _scannedItem!['userType'] ?? 'N/A'),
          _buildDetailRow('Contact', _scannedItem!['contactNumber'] ?? 'N/A'),
        ],
      );
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _simulateScan() async {
    if (_isScanning) return; // Prevent multiple simultaneous scans
    
    setState(() => _isScanning = true);

    try {
      // Simulate scanning delay
      await Future.delayed(const Duration(seconds: 2));

      if (_scanMode == 'blood_bag') {
        await _simulateBloodBagScan();
      } else {
        await _simulateDonorScan();
      }
    } catch (e) {
      debugPrint('Scan error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scan failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  Future<void> _simulateBloodBagScan() async {
    try {
      // Simulate scanning a blood bag QR code
      final bloodInventory = await _dataService.getAllBloodInventory();

      if (bloodInventory.isNotEmpty) {
        // Use the first blood inventory item as scanned data
        final scannedItem = bloodInventory.first;
        
        // Validate the scanned item has required fields
        if (scannedItem['bloodGroup'] != null && scannedItem['quantity'] != null) {
          setState(() {
            _scannedItem = scannedItem;
          });

          debugPrint('✅ Blood bag scanned: ${scannedItem['bloodGroup']}');
        } else {
          throw Exception('Invalid blood bag data format');
        }
      } else {
        throw Exception('No blood inventory found');
      }
    } catch (e) {
      debugPrint('Blood bag scan error: $e');
      rethrow;
    }
  }

  Future<void> _simulateDonorScan() async {
    try {
      // Simulate scanning a donor QR code
      final users = await _dataService.getAllUsers();
      final donors = users.where((user) => user['userType'] == 'Donor').toList();

      if (donors.isNotEmpty) {
        // Use the first donor as scanned data
        final scannedItem = donors.first;
        
        // Validate the scanned item has required fields
        if (scannedItem['name'] != null && scannedItem['bloodGroup'] != null) {
          setState(() {
            _scannedItem = scannedItem;
          });

          debugPrint('✅ Donor scanned: ${scannedItem['name']}');
        } else {
          throw Exception('Invalid donor data format');
        }
      } else {
        throw Exception('No donors found');
      }
    } catch (e) {
      debugPrint('Donor scan error: $e');
      rethrow;
    }
  }

  void _clearResults() {
    setState(() {
      _scannedItem = null;
    });
  }

  void _viewDetails() {
    if (_scannedItem == null) return;

    try {
      if (_scanMode == 'blood_bag') {
        // Navigate to blood inventory details
        Navigator.pushNamed(context, '/blood_inventory');
      } else {
        // Navigate to user profile
        Navigator.pushNamed(context, '/profile');
      }
    } catch (e) {
      debugPrint('Navigation error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Unable to navigate to details'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }
}
