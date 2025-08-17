import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class PerformanceConfig {
  static const bool enablePerformanceOverlay = false;
  static const bool enableSemanticsDebugger = false;
  static const bool enableRepaintBoundaries = true;
  static const bool enableCheckMode = false;

  /// Configure performance optimizations for the app
  static void configurePerformance() {
    // Disable debug features in release mode
    if (!kDebugMode) {
      debugPrintRebuildDirtyWidgets = false;
      debugPrint = (String? message, {int? wrapWidth}) {};
    }

    // Optimize image cache for faster loading
    PaintingBinding.instance.imageCache.maximumSize = 50; // Reduced from 100
    PaintingBinding.instance.imageCache.maximumSizeBytes =
        25 << 20; // Reduced to 25 MB

    // Optimize widget rebuilding
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Additional post-frame optimizations
    });
  }

  /// Configure system UI overlays for better performance
  static void configureSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  /// Get optimized MaterialApp configuration
  static Map<String, dynamic> getOptimizedAppConfig() {
    return {
      'debugShowCheckedModeBanner': false,
      'showPerformanceOverlay': enablePerformanceOverlay,
      'showSemanticsDebugger': enableSemanticsDebugger,
      'checkerboardRasterCacheImages': false,
      'checkerboardOffscreenLayers': false,
    };
  }

  /// Configure splash screen specific optimizations
  static void configureSplashScreenOptimizations() {
    // Optimize for faster splash screen rendering
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Force immediate frame rendering
      WidgetsBinding.instance.scheduleFrameCallback((_) {
        // Additional frame optimizations
      });
    });
  }
}
