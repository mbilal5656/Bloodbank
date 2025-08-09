import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager {
  static const String _themeKey = 'selected_theme';
  
  // Available themes
  static const Map<String, AppTheme> themes = {
    'blood_red': AppTheme(
      name: 'Blood Red',
      primaryColor: Color(0xFFD32F2F),
      secondaryColor: Color(0xFFFFCDD2),
      accentColor: Color(0xFFFF5722),
      backgroundColor: Color(0xFFFAFAFA),
      surfaceColor: Colors.white,
      textColor: Color(0xFF212121),
      iconColor: Color(0xFFD32F2F),
    ),
    'ocean_blue': AppTheme(
      name: 'Ocean Blue',
      primaryColor: Color(0xFF1976D2),
      secondaryColor: Color(0xFFE3F2FD),
      accentColor: Color(0xFF2196F3),
      backgroundColor: Color(0xFFF5F5F5),
      surfaceColor: Colors.white,
      textColor: Color(0xFF212121),
      iconColor: Color(0xFF1976D2),
    ),
    'forest_green': AppTheme(
      name: 'Forest Green',
      primaryColor: Color(0xFF388E3C),
      secondaryColor: Color(0xFFE8F5E8),
      accentColor: Color(0xFF4CAF50),
      backgroundColor: Color(0xFFFAFAFA),
      surfaceColor: Colors.white,
      textColor: Color(0xFF212121),
      iconColor: Color(0xFF388E3C),
    ),
    'royal_purple': AppTheme(
      name: 'Royal Purple',
      primaryColor: Color(0xFF7B1FA2),
      secondaryColor: Color(0xFFF3E5F5),
      accentColor: Color(0xFF9C27B0),
      backgroundColor: Color(0xFFFAFAFA),
      surfaceColor: Colors.white,
      textColor: Color(0xFF212121),
      iconColor: Color(0xFF7B1FA2),
    ),
    'sunset_orange': AppTheme(
      name: 'Sunset Orange',
      primaryColor: Color(0xFFFF5722),
      secondaryColor: Color(0xFFFFEBEE),
      accentColor: Color(0xFFFF9800),
      backgroundColor: Color(0xFFFAFAFA),
      surfaceColor: Colors.white,
      textColor: Color(0xFF212121),
      iconColor: Color(0xFFFF5722),
    ),
    'midnight_black': AppTheme(
      name: 'Midnight Black',
      primaryColor: Color(0xFF424242),
      secondaryColor: Color(0xFFEEEEEE),
      accentColor: Color(0xFF757575),
      backgroundColor: Color(0xFFF5F5F5),
      surfaceColor: Colors.white,
      textColor: Color(0xFF212121),
      iconColor: Color(0xFF424242),
    ),
  };

  static String _currentTheme = 'blood_red';

  // Get current theme
  static String get currentTheme => _currentTheme;

  // Get current theme data
  static AppTheme get currentThemeData => themes[_currentTheme] ?? themes['blood_red']!;

  // Initialize theme from preferences
  static Future<void> initializeTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themeKey);
      if (savedTheme != null && themes.containsKey(savedTheme)) {
        _currentTheme = savedTheme;
      }
    } catch (e) {
      debugPrint('Error loading theme: $e');
    }
  }

  // Change theme
  static Future<void> changeTheme(String themeName) async {
    if (themes.containsKey(themeName)) {
      _currentTheme = themeName;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_themeKey, themeName);
      } catch (e) {
        debugPrint('Error saving theme: $e');
      }
    }
  }

  // Get theme data by name
  static AppTheme? getThemeByName(String themeName) {
    return themes[themeName];
  }

  // Get all available themes
  static List<String> get availableThemes => themes.keys.toList();

  // Create MaterialApp theme data
  static ThemeData getThemeData() {
    final theme = currentThemeData;
    
    return ThemeData(
      primarySwatch: _createMaterialColor(theme.primaryColor),
      primaryColor: theme.primaryColor,
      colorScheme: ColorScheme.light(
        primary: theme.primaryColor,
        secondary: theme.secondaryColor,
        surface: theme.surfaceColor,
        background: theme.backgroundColor,
        onPrimary: Colors.white,
        onSecondary: theme.textColor,
        onSurface: theme.textColor,
        onBackground: theme.textColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: theme.surfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.primaryColor, width: 2),
        ),
      ),
      iconTheme: IconThemeData(
        color: theme.iconColor,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: theme.textColor),
        bodyMedium: TextStyle(color: theme.textColor),
        titleLarge: TextStyle(color: theme.textColor, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: theme.textColor, fontWeight: FontWeight.w600),
      ),
    );
  }

  // Create MaterialColor from Color
  static MaterialColor _createMaterialColor(Color color) {
    final strengths = <double>[.05];
    final swatch = <int, Color>{};
    final r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (final strength in strengths) {
      final ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}

class AppTheme {
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color textColor;
  final Color iconColor;

  const AppTheme({
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.textColor,
    required this.iconColor,
  });
}
