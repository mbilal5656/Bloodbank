import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserType = 'user_type';
  static const String _keyUserName = 'user_name';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keySessionToken = 'session_token';

  // Save user session
  static Future<void> saveUserSession({
    required int userId,
    required String email,
    required String userType,
    required String userName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, userId);
    await prefs.setString(_keyUserEmail, email);
    await prefs.setString(_keyUserType, userType);
    await prefs.setString(_keyUserName, userName);
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keySessionToken, _generateSessionToken());
  }

  // Get user session data
  static Future<Map<String, dynamic>?> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    
    if (!isLoggedIn) return null;

    return {
      'userId': prefs.getInt(_keyUserId),
      'email': prefs.getString(_keyUserEmail),
      'userType': prefs.getString(_keyUserType),
      'userName': prefs.getString(_keyUserName),
      'sessionToken': prefs.getString(_keySessionToken),
    };
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Get current user type
  static Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserType);
  }

  // Get current user ID
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  // Get current user email
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail);
  }

  // Clear user session (logout)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserType);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keySessionToken);
  }

  // Generate a simple session token
  static String _generateSessionToken() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecond;
    return 'token_${timestamp}_$random';
  }

  // Validate session token
  static Future<bool> validateSessionToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keySessionToken);
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    
    return isLoggedIn && token != null && token.isNotEmpty;
  }

  // Save user preferences
  static Future<void> saveUserPreference(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    }
  }

  // Get user preference
  static Future<T?> getUserPreference<T>(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.get(key) as T?;
  }

  // Remove user preference
  static Future<void> removeUserPreference(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
} 