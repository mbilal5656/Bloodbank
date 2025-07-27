import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _userIdKey = 'user_id';
  static const String _emailKey = 'user_email';
  static const String _userTypeKey = 'user_type';
  static const String _userNameKey = 'user_name';
  static const String _isLoggedInKey = 'is_logged_in';

  // Save user session
  static Future<void> saveUserSession({
    required int userId,
    required String email,
    required String userType,
    required String userName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_userTypeKey, userType);
    await prefs.setString(_userNameKey, userName);
    await prefs.setBool(_isLoggedInKey, true);
  }

  // Get current user ID
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  // Get current user email
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  // Get current user type
  static Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userTypeKey);
  }

  // Get current user name
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Clear user session (logout)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_userTypeKey);
    await prefs.remove(_userNameKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  // Get all session data
  static Future<Map<String, dynamic>> getSessionData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getInt(_userIdKey),
      'email': prefs.getString(_emailKey),
      'userType': prefs.getString(_userTypeKey),
      'userName': prefs.getString(_userNameKey),
      'isLoggedIn': prefs.getBool(_isLoggedInKey) ?? false,
    };
  }

  // Update user name
  static Future<void> updateUserName(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, newName);
  }

  // Update user type
  static Future<void> updateUserType(String newType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userTypeKey, newType);
  }

  // Get user session data
  static Future<Map<String, dynamic>?> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

    if (!isLoggedIn) return null;

    return {
      'userId': prefs.getInt(_userIdKey),
      'email': prefs.getString(_emailKey),
      'userType': prefs.getString(_userTypeKey),
      'userName': prefs.getString(_userNameKey),
      'isLoggedIn': isLoggedIn,
    };
  }
}
