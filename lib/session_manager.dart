import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:math';
import 'package:flutter/foundation.dart';

class SessionManager {
  static const String _userIdKey = 'user_id';
  static const String _emailKey = 'user_email';
  static const String _userTypeKey = 'user_type';
  static const String _userNameKey = 'user_name';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _sessionTokenKey = 'session_token';
  static const String _loginTimeKey = 'login_time';
  static const String _lastActivityKey = 'last_activity';
  static const String _deviceInfoKey = 'device_info';
  static const String _rememberMeKey = 'remember_me';
  static const String _autoLogoutKey = 'auto_logout';
  static const String _sessionTimeoutKey = 'session_timeout';

  // Session timeout duration (default: 30 minutes)
  static const Duration _defaultSessionTimeout = Duration(minutes: 30);

  // Save user session
  static Future<void> saveUserSession({
    required int userId,
    required String email,
    required String userType,
    required String userName,
    String? deviceInfo,
    bool rememberMe = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionToken = _generateSessionToken();
      final loginTime = DateTime.now().toIso8601String();

      await prefs.setInt(_userIdKey, userId);
      await prefs.setString(_emailKey, email);
      await prefs.setString(_userTypeKey, userType);
      await prefs.setString(_userNameKey, userName);
      await prefs.setString(_sessionTokenKey, sessionToken);
      await prefs.setString(_loginTimeKey, loginTime);
      await prefs.setString(_lastActivityKey, loginTime);
      await prefs.setString(_deviceInfoKey, deviceInfo ?? 'Unknown Device');
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setBool(_rememberMeKey, rememberMe);

      debugPrint('User session saved: $email (ID: $userId)');
      debugPrint('Session token: $sessionToken');
    } catch (e) {
      debugPrint('Error saving user session: $e');
      rethrow;
    }
  }

  // Generate secure session token
  static String _generateSessionToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // Get current user ID
  static Future<int?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_userIdKey);
    } catch (e) {
      debugPrint('Error getting user ID: $e');
      return null;
    }
  }

  // Get current user email
  static Future<String?> getUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_emailKey);
    } catch (e) {
      debugPrint('Error getting user email: $e');
      return null;
    }
  }

  // Get current user type
  static Future<String?> getUserType() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userTypeKey);
    } catch (e) {
      debugPrint('Error getting user type: $e');
      return null;
    }
  }

  // Get current user name
  static Future<String?> getUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userNameKey);
    } catch (e) {
      debugPrint('Error getting user name: $e');
      return null;
    }
  }

  // Get session token
  static Future<String?> getSessionToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_sessionTokenKey);
    } catch (e) {
      debugPrint('Error getting session token: $e');
      return null;
    }
  }

  // Get login time
  static Future<DateTime?> getLoginTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final loginTimeStr = prefs.getString(_loginTimeKey);
      if (loginTimeStr != null) {
        return DateTime.parse(loginTimeStr);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting login time: $e');
      return null;
    }
  }

  // Get last activity time
  static Future<DateTime?> getLastActivity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastActivityStr = prefs.getString(_lastActivityKey);
      if (lastActivityStr != null) {
        return DateTime.parse(lastActivityStr);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting last activity: $e');
      return null;
    }
  }

  // Get device info
  static Future<String?> getDeviceInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_deviceInfoKey);
    } catch (e) {
      debugPrint('Error getting device info: $e');
      return null;
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

      if (isLoggedIn) {
        // Check if session has expired
        final sessionExpired = await _isSessionExpired();
        if (sessionExpired) {
          await clearSession();
          return false;
        }

        // Update last activity
        await _updateLastActivity();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error checking login status: $e');
      return false;
    }
  }

  // Check if session has expired
  static Future<bool> _isSessionExpired() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool(_rememberMeKey) ?? false;

      if (rememberMe) {
        return false; // Remember me sessions don't expire
      }

      final lastActivity = await getLastActivity();
      if (lastActivity == null) return true;

      final sessionTimeout = await getSessionTimeout();
      final now = DateTime.now();
      final timeDifference = now.difference(lastActivity);

      return timeDifference > sessionTimeout;
    } catch (e) {
      debugPrint('Error checking session expiration: $e');
      return true;
    }
  }

  // Update last activity
  static Future<void> _updateLastActivity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastActivityKey, DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Error updating last activity: $e');
    }
  }

  // Get session timeout duration
  static Future<Duration> getSessionTimeout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeoutMinutes = prefs.getInt(_sessionTimeoutKey) ?? 30;
      return Duration(minutes: timeoutMinutes);
    } catch (e) {
      debugPrint('Error getting session timeout: $e');
      return _defaultSessionTimeout;
    }
  }

  // Set session timeout duration
  static Future<bool> setSessionTimeout(Duration timeout) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_sessionTimeoutKey, timeout.inMinutes);
      debugPrint('Session timeout set to: ${timeout.inMinutes} minutes');
      return true;
    } catch (e) {
      debugPrint('Error setting session timeout: $e');
      return false;
    }
  }

  // Check if remember me is enabled
  static Future<bool> isRememberMeEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_rememberMeKey) ?? false;
    } catch (e) {
      debugPrint('Error checking remember me: $e');
      return false;
    }
  }

  // Set remember me
  static Future<bool> setRememberMe(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_rememberMeKey, enabled);
      debugPrint('Remember me set to: $enabled');
      return true;
    } catch (e) {
      debugPrint('Error setting remember me: $e');
      return false;
    }
  }

  // Get session duration
  static Future<Duration?> getSessionDuration() async {
    try {
      final loginTime = await getLoginTime();
      if (loginTime == null) return null;

      final now = DateTime.now();
      return now.difference(loginTime);
    } catch (e) {
      debugPrint('Error getting session duration: $e');
      return null;
    }
  }

  // Get session info
  static Future<Map<String, dynamic>?> getSessionInfo() async {
    try {
      final isLoggedInStatus = await isLoggedIn();
      if (!isLoggedInStatus) return null;

      final loginTime = await getLoginTime();
      final lastActivity = await getLastActivity();
      final sessionDuration = await getSessionDuration();
      final sessionTimeout = await getSessionTimeout();
      final rememberMe = await isRememberMeEnabled();
      final deviceInfo = await getDeviceInfo();

      return {
        'loginTime': loginTime?.toIso8601String(),
        'lastActivity': lastActivity?.toIso8601String(),
        'sessionDuration': sessionDuration?.inSeconds,
        'sessionTimeout': sessionTimeout.inMinutes,
        'rememberMe': rememberMe,
        'deviceInfo': deviceInfo,
        'isExpired': await _isSessionExpired(),
      };
    } catch (e) {
      debugPrint('Error getting session info: $e');
      return null;
    }
  }

  // Clear user session (logout)
  static Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Clear session data
      await prefs.remove(_userIdKey);
      await prefs.remove(_emailKey);
      await prefs.remove(_userTypeKey);
      await prefs.remove(_userNameKey);
      await prefs.remove(_sessionTokenKey);
      await prefs.remove(_loginTimeKey);
      await prefs.remove(_lastActivityKey);
      await prefs.remove(_deviceInfoKey);
      await prefs.setBool(_isLoggedInKey, false);

      // Don't clear remember me and session timeout settings

      debugPrint('User session cleared successfully');
    } catch (e) {
      debugPrint('Error clearing session: $e');
      rethrow;
    }
  }

  // Clear all data (including settings)
  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      debugPrint('All session data cleared successfully');
    } catch (e) {
      debugPrint('Error clearing all data: $e');
      rethrow;
    }
  }

  // Get all session data
  static Future<Map<String, dynamic>> getSessionData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedInStatus = await isLoggedIn();

      return {
        'userId': prefs.getInt(_userIdKey),
        'email': prefs.getString(_emailKey),
        'userType': prefs.getString(_userTypeKey),
        'userName': prefs.getString(_userNameKey),
        'sessionToken': prefs.getString(_sessionTokenKey),
        'loginTime': prefs.getString(_loginTimeKey),
        'lastActivity': prefs.getString(_lastActivityKey),
        'deviceInfo': prefs.getString(_deviceInfoKey),
        'isLoggedIn': isLoggedInStatus,
        'rememberMe': prefs.getBool(_rememberMeKey) ?? false,
        'sessionTimeout': prefs.getInt(_sessionTimeoutKey) ?? 30,
      };
    } catch (e) {
      debugPrint('Error getting session data: $e');
      return {};
    }
  }

  // Update user name
  static Future<void> updateUserName(String newName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userNameKey, newName);
      debugPrint('User name updated: $newName');
    } catch (e) {
      debugPrint('Error updating user name: $e');
      rethrow;
    }
  }

  // Update user type
  static Future<void> updateUserType(String newType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userTypeKey, newType);
      debugPrint('User type updated: $newType');
    } catch (e) {
      debugPrint('Error updating user type: $e');
      rethrow;
    }
  }

  // Update user email
  static Future<void> updateUserEmail(String newEmail) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_emailKey, newEmail);
      debugPrint('User email updated: $newEmail');
    } catch (e) {
      debugPrint('Error updating user email: $e');
      rethrow;
    }
  }

  // Get user session data
  static Future<Map<String, dynamic>?> getUserSession() async {
    try {
      final isLoggedInStatus = await isLoggedIn();
      if (!isLoggedInStatus) return null;

      final sessionData = await getSessionData();
      final sessionInfo = await getSessionInfo();

      return {
        ...sessionData,
        'sessionInfo': sessionInfo,
      };
    } catch (e) {
      debugPrint('Error getting user session: $e');
      return null;
    }
  }

  // Validate session token
  static Future<bool> validateSessionToken(String token) async {
    try {
      final storedToken = await getSessionToken();
      return storedToken == token;
    } catch (e) {
      debugPrint('Error validating session token: $e');
      return false;
    }
  }

  // Refresh session
  static Future<bool> refreshSession() async {
    try {
      final isLoggedInStatus = await isLoggedIn();
      if (!isLoggedInStatus) return false;

      await _updateLastActivity();
      debugPrint('Session refreshed successfully');
      return true;
    } catch (e) {
      debugPrint('Error refreshing session: $e');
      return false;
    }
  }

  // Check if session is about to expire
  static Future<bool> isSessionAboutToExpire() async {
    try {
      final lastActivity = await getLastActivity();
      if (lastActivity == null) return true;

      final sessionTimeout = await getSessionTimeout();
      const warningThreshold = Duration(minutes: 5); // 5 minutes warning
      final now = DateTime.now();
      final timeDifference = now.difference(lastActivity);
      final timeUntilExpiry = sessionTimeout - timeDifference;

      return timeUntilExpiry <= warningThreshold;
    } catch (e) {
      debugPrint('Error checking if session is about to expire: $e');
      return true;
    }
  }

  // Get time until session expires
  static Future<Duration?> getTimeUntilExpiry() async {
    try {
      final lastActivity = await getLastActivity();
      if (lastActivity == null) return null;

      final sessionTimeout = await getSessionTimeout();
      final now = DateTime.now();
      final timeDifference = now.difference(lastActivity);
      final timeUntilExpiry = sessionTimeout - timeDifference;

      return timeUntilExpiry.isNegative ? Duration.zero : timeUntilExpiry;
    } catch (e) {
      debugPrint('Error getting time until expiry: $e');
      return null;
    }
  }

  // Set auto logout
  static Future<bool> setAutoLogout(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_autoLogoutKey, enabled);
      debugPrint('Auto logout set to: $enabled');
      return true;
    } catch (e) {
      debugPrint('Error setting auto logout: $e');
      return false;
    }
  }

  // Check if auto logout is enabled
  static Future<bool> isAutoLogoutEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_autoLogoutKey) ?? true;
    } catch (e) {
      debugPrint('Error checking auto logout: $e');
      return true;
    }
  }

  // Get session statistics
  static Future<Map<String, dynamic>> getSessionStatistics() async {
    try {
      final loginTime = await getLoginTime();
      final sessionDuration = await getSessionDuration();
      final sessionTimeout = await getSessionTimeout();
      final rememberMe = await isRememberMeEnabled();
      final autoLogout = await isAutoLogoutEnabled();

      return {
        'loginTime': loginTime?.toIso8601String(),
        'sessionDuration': sessionDuration?.inSeconds,
        'sessionTimeout': sessionTimeout.inMinutes,
        'rememberMe': rememberMe,
        'autoLogout': autoLogout,
        'isExpired': await _isSessionExpired(),
        'isAboutToExpire': await isSessionAboutToExpire(),
        'timeUntilExpiry': await getTimeUntilExpiry(),
      };
    } catch (e) {
      debugPrint('Error getting session statistics: $e');
      return {};
    }
  }

  // Export session data
  static Future<Map<String, dynamic>> exportSessionData() async {
    try {
      final sessionData = await getSessionData();
      final sessionInfo = await getSessionInfo();
      final sessionStatistics = await getSessionStatistics();

      return {
        'sessionData': sessionData,
        'sessionInfo': sessionInfo,
        'sessionStatistics': sessionStatistics,
        'exportedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('Error exporting session data: $e');
      return {};
    }
  }

  // Import session data
  static Future<bool> importSessionData(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionData = data['sessionData'] as Map<String, dynamic>;

      // Import session data
      for (final entry in sessionData.entries) {
        final key = entry.key;
        final value = entry.value;

        if (value is int) {
          await prefs.setInt(key, value);
        } else if (value is String) {
          await prefs.setString(key, value);
        } else if (value is bool) {
          await prefs.setBool(key, value);
        }
      }

      debugPrint('Session data imported successfully');
      return true;
    } catch (e) {
      debugPrint('Error importing session data: $e');
      return false;
    }
  }
}
