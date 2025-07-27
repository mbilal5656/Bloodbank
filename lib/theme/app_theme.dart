import 'package:flutter/material.dart';

class AppTheme {
  // Modern Color Palette - Ocean Blue Theme
  static const Color primaryColor = Color(0xFF2196F3); // Blue
  static const Color secondaryColor = Color(0xFF03A9F4); // Light Blue
  static const Color accentColor = Color(0xFF00BCD4); // Cyan
  static const Color surfaceColor = Color(0xFFE3F2FD); // Light Blue Background
  static const Color backgroundColor = Color(0xFFF5F5F5); // Light Gray
  static const Color errorColor = Color(0xFFF44336); // Red
  static const Color successColor = Color(0xFF4CAF50); // Green
  static const Color warningColor = Color(0xFFFF9800); // Orange
  static const Color infoColor = Color(0xFF2196F3); // Blue

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF2196F3), // Blue
    Color(0xFF03A9F4), // Light Blue
    Color(0xFF00BCD4), // Cyan
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFF1976D2), // Dark Blue
    Color(0xFF2196F3), // Blue
    Color(0xFF42A5F5), // Light Blue
  ];

  static const List<Color> accentGradient = [
    Color(0xFF00BCD4), // Cyan
    Color(0xFF26C6DA), // Light Cyan
    Color(0xFF4DD0E1), // Very Light Cyan
  ];

  // Text Colors
  static const Color primaryTextColor = Color(0xFF212121); // Dark Gray
  static const Color secondaryTextColor = Color(0xFF757575); // Medium Gray
  static const Color lightTextColor = Color(0xFFFFFFFF); // White
  static const Color darkTextColor = Color(0xFF000000); // Black

  // Card and Container Colors
  static const Color cardColor = Color(0xFFFFFFFF); // White
  static const Color containerColor = Color(0xFFF8F9FA); // Very Light Gray
  static const Color borderColor = Color(0xFFE0E0E0); // Light Gray

  // Status Colors
  static const Color availableColor = Color(0xFF4CAF50); // Green
  static const Color lowStockColor = Color(0xFFFF9800); // Orange
  static const Color criticalColor = Color(0xFFF44336); // Red
  static const Color pendingColor = Color(0xFFFFC107); // Amber

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: lightTextColor,
        onSecondary: lightTextColor,
        onSurface: primaryTextColor,
        onError: lightTextColor,
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: lightTextColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: lightTextColor,
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: lightTextColor,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: const TextStyle(color: secondaryTextColor),
        hintStyle: const TextStyle(color: secondaryTextColor),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),

      // Text Theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: primaryTextColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: primaryTextColor,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: primaryTextColor,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: primaryTextColor,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: primaryTextColor,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: primaryTextColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: primaryTextColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: primaryTextColor,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: secondaryTextColor,
        ),
      ),
    );
  }

  // Gradient Decorations
  static BoxDecoration get primaryGradientDecoration {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: primaryGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  static BoxDecoration get secondaryGradientDecoration {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: secondaryGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  static BoxDecoration get accentGradientDecoration {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: accentGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  // Glass Effect Decoration
  static BoxDecoration get glassDecoration {
    return BoxDecoration(
      color: cardColor.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: cardColor.withValues(alpha: 0.2),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Status Colors Helper
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
      case 'success':
        return availableColor;
      case 'low':
      case 'warning':
        return lowStockColor;
      case 'critical':
      case 'error':
        return criticalColor;
      case 'pending':
        return pendingColor;
      default:
        return secondaryTextColor;
    }
  }

  // Blood Type Colors
  static Color getBloodTypeColor(String bloodType) {
    switch (bloodType.toUpperCase()) {
      case 'A+':
        return const Color(0xFFE91E63); // Pink
      case 'A-':
        return const Color(0xFF9C27B0); // Purple
      case 'B+':
        return const Color(0xFF2196F3); // Blue
      case 'B-':
        return const Color(0xFF03A9F4); // Light Blue
      case 'AB+':
        return const Color(0xFF4CAF50); // Green
      case 'AB-':
        return const Color(0xFF8BC34A); // Light Green
      case 'O+':
        return const Color(0xFFFF5722); // Deep Orange
      case 'O-':
        return const Color(0xFFFF9800); // Orange
      default:
        return secondaryTextColor;
    }
  }
} 