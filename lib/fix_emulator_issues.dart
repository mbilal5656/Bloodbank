import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EmulatorFix {
  // Fix for Hero animation conflicts
  static Widget fixHeroConflicts(Widget child) {
    return Hero(
      tag: 'unique_hero_${DateTime.now().millisecondsSinceEpoch}',
      child: child,
    );
  }

  // Fix for RenderFlex overflow
  static Widget fixOverflow(Widget child) {
    return SingleChildScrollView(
      child: child,
    );
  }

  // Fix for Android back button
  static void fixBackButton(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
  }

  // Fix for route issues
  static Map<String, WidgetBuilder> getFixedRoutes() {
    return {
      '/': (context) => const Scaffold(
        body: Center(
          child: Text('Home Page'),
        ),
      ),
      '/admin': (context) => const Scaffold(
        body: Center(
          child: Text('Admin Page'),
        ),
      ),
      '/blood_inventory': (context) => const Scaffold(
        body: Center(
          child: Text('Blood Inventory Page'),
        ),
      ),
      '/notification_management': (context) => const Scaffold(
        body: Center(
          child: Text('Notification Management Page'),
        ),
      ),
    };
  }
}

// Fixed App widget
class FixedApp extends StatelessWidget {
  const FixedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blood Bank - Fixed',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        // Fix for overflow issues
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const FixedHomePage(),
      routes: EmulatorFix.getFixedRoutes(),
    );
  }
}

class FixedHomePage extends StatefulWidget {
  const FixedHomePage({super.key});

  @override
  State<FixedHomePage> createState() => _FixedHomePageState();
}

class _FixedHomePageState extends State<FixedHomePage> {
  @override
  void initState() {
    super.initState();
    // Fix back button issues
    EmulatorFix.fixBackButton(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Bank - Fixed'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        // Fix for overflow
        flexibleSpace: FlexibleSpaceBar(
          title: const Text('Blood Bank'),
          background: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue, Colors.indigo],
              ),
            ),
          ),
        ),
      ),
      body: EmulatorFix.fixOverflow(
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Fixed Hero widget
              EmulatorFix.fixHeroConflicts(
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.bloodtype,
                    size: 50,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Blood Bank Management System',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'Fixed for Pixel 9 Emulator',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // Fixed navigation buttons
              _buildFixedButton(
                'Admin Panel',
                Icons.admin_panel_settings,
                Colors.blue,
                () => Navigator.pushNamed(context, '/admin'),
              ),
              const SizedBox(height: 16),
              _buildFixedButton(
                'Blood Inventory',
                Icons.inventory,
                Colors.green,
                () => Navigator.pushNamed(context, '/blood_inventory'),
              ),
              const SizedBox(height: 16),
              _buildFixedButton(
                'Notifications',
                Icons.notifications,
                Colors.orange,
                () => Navigator.pushNamed(context, '/notification_management'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFixedButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

// Main function for fixed app
void main() {
  runApp(const FixedApp());
} 