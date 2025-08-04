import 'package:flutter/material.dart';
import 'main.dart' show UserSession, NavigationUtils;
import 'session_manager.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'utils/database_verification.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    debugPrint('Splash screen: Initializing...');

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    debugPrint('Splash screen: Starting animation...');
    _startAnimation();
  }

  void _startAnimation() async {
    if (_isDisposed) return;

    try {
      await _animationController.forward();
      if (_isDisposed) return;
      await _fadeController.forward();
      if (_isDisposed) return;

      // Add a timeout to prevent getting stuck
      _checkUserSessionWithTimeout();
    } catch (e) {
      debugPrint('Error in animation: $e');
      if (!_isDisposed) {
        _checkUserSessionWithTimeout();
      }
    }
  }

  void _checkUserSessionWithTimeout() async {
    if (_isDisposed) return;

    try {
      debugPrint('🔄 Splash screen: Starting session check with timeout...');
      // Set a timeout of 5 seconds (reduced from 8)
      final result = await _checkUserSession().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint(
              '⏰ Splash screen: Session check timed out, navigating to home');
          return 'timeout';
        },
      );

      if (_isDisposed) return;

      if (result == 'timeout' && mounted) {
        debugPrint('🚀 Splash screen: Navigating to home due to timeout');
        if (context.mounted) {
          NavigationUtils.navigateToHome(context);
        }
      }
    } catch (e) {
      debugPrint('❌ Splash screen: Error in session check with timeout: $e');
      if (!_isDisposed && mounted && context.mounted) {
        debugPrint('🚀 Splash screen: Navigating to home due to error');
        NavigationUtils.navigateToHome(context);
      }
    }
  }

  Future<String?> _checkUserSession() async {
    if (_isDisposed) return 'timeout';

    try {
      debugPrint('Splash screen: Checking user session...');

      // Initialize and verify database
      try {
        if (!kIsWeb) {
          debugPrint('🔍 Verifying database connection...');
          final verificationResult = await DatabaseVerification.verifyDatabaseConnection();
          
          if (verificationResult['status'] == 'success') {
            debugPrint('✅ Database verification successful: ${verificationResult['message']}');
          } else {
            debugPrint('⚠️ Database verification failed: ${verificationResult['error']}');
          }
        }
      } catch (e) {
        debugPrint('⚠️ Database initialization failed, continuing anyway: $e');
      }

      final sessionData = await SessionManager.getSessionData();
      debugPrint(
          'Splash screen: Session data received: ${sessionData.isNotEmpty}');

      if (_isDisposed || !mounted) {
        debugPrint('Splash screen: Widget not mounted, returning');
        return 'timeout';
      }

      if (sessionData.isNotEmpty && sessionData['userType'] != null) {
        // User is logged in, navigate to appropriate page
        debugPrint('Splash screen: User is logged in, navigating to user page');
        UserSession.userId = sessionData['userId'] ?? 0;
        UserSession.email = sessionData['email'] ?? '';
        UserSession.userType = sessionData['userType'] ?? '';
        UserSession.userName = sessionData['userName'] ?? '';

        // Reduced delay
        await Future.delayed(const Duration(milliseconds: 300));

        if (!_isDisposed && mounted && context.mounted) {
          NavigationUtils.navigateToUserPage(
              context, UserSession.userType ?? 'admin');
        }
      } else {
        // No session, go to home page
        debugPrint('Splash screen: No session found, navigating to home');
        await Future.delayed(const Duration(milliseconds: 300));

        if (!_isDisposed && mounted && context.mounted) {
          NavigationUtils.navigateToHome(context);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Splash screen: Error checking session: $e');
      // Reduced delay
      await Future.delayed(const Duration(milliseconds: 500));

      if (!_isDisposed && mounted && context.mounted) {
        debugPrint('Splash screen: Navigating to home due to error');
        NavigationUtils.navigateToHome(context);
      }
      return 'timeout';
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _animationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A237E),
              Color(0xFF3949AB),
              Color(0xFF5C6BC0),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo and App Name
              ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.bloodtype,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Text(
                        'Blood Bank',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Text(
                        'Management System',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 80),

              // Loading indicator
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Column(
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),



              const Spacer(),

              // Footer
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    '© 2024 Blood Bank Management System\nVersion 1.0.0',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
