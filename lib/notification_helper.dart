import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'dart:async';

class NotificationHelper {
  static const String _notificationsKey = 'notifications';
  static const String _nextNotificationIdKey = 'next_notification_id';
  static const String _notificationSettingsKey = 'notification_settings';
  static const String _scheduledNotificationsKey = 'scheduled_notifications';

  // Flutter Local Notifications
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Notification settings
  static bool _isInitialized = false;
  // Initialize notifications
  static Future<void> initialize() async {
    try {
      if (_isInitialized) return;

      // Initialize SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey);

      if (notificationsJson == null) {
        // Initialize empty notifications list
        await prefs.setString(_notificationsKey, '[]');
        await prefs.setInt(_nextNotificationIdKey, 1);
      }

      // Initialize Flutter Local Notifications
      await _initializeLocalNotifications();

      // Load notification settings
      await _loadNotificationSettings();

      _isInitialized = true;
    } catch (e) {
      // Handle initialization error silently
    }
  }

  // Initialize Flutter Local Notifications
  static Future<void> _initializeLocalNotifications() async {
    try {
      // Android settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS settings
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      // Initialize settings
      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
          );

      // Initialize plugin
      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
    } catch (e) {
      // Handle initialization error silently
    }
  }

  // Load notification settings
  static Future<void> _loadNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_notificationSettingsKey);

      if (settingsJson == null) {
        // Set default settings
        final defaultSettings = {
          'enabled': true,
          'sound': true,
          'vibration': true,
          'priority': 'high',
          'autoClear': true,
        };
        await prefs.setString(
          _notificationSettingsKey,
          jsonEncode(defaultSettings),
        );
      }
    } catch (e) {
      // Handle error silently
    }
  }

  // Get notification settings
  static Future<Map<String, dynamic>> getNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_notificationSettingsKey);

      if (settingsJson != null) {
        return jsonDecode(settingsJson);
      }

      return {
        'enabled': true,
        'sound': true,
        'vibration': true,
        'priority': 'high',
        'autoClear': true,
      };
    } catch (e) {
      return {
        'enabled': true,
        'sound': true,
        'vibration': true,
        'priority': 'high',
        'autoClear': true,
      };
    }
  }

  // Update notification settings
  static Future<bool> updateNotificationSettings(
    Map<String, dynamic> settings,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_notificationSettingsKey, jsonEncode(settings));
      return true;
    } catch (e) {
      return false;
    }
  }

  // Add notification
  static Future<bool> addNotification({
    required String title,
    required String message,
    required String type,
    int? userId,
    String priority = 'Normal',
    Map<String, dynamic>? payload,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey);
      final nextId = prefs.getInt(_nextNotificationIdKey) ?? 1;

      final List<dynamic> notifications = notificationsJson != null
          ? jsonDecode(notificationsJson)
          : [];

      final notification = {
        'id': nextId,
        'title': title,
        'message': message,
        'type': type,
        'userId': userId,
        'priority': priority,
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
        'payload': payload,
      };

      notifications.add(notification);

      await prefs.setString(_notificationsKey, jsonEncode(notifications));
      await prefs.setInt(_nextNotificationIdKey, nextId + 1);

      // Show local notification if enabled
      await _showLocalNotification(notification);

      return true;
    } catch (e) {
      return false;
    }
  }

  // Show local notification
  static Future<void> _showLocalNotification(
    Map<String, dynamic> notification,
  ) async {
    try {
      final settings = await getNotificationSettings();
      if (!settings['enabled']) return;

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'bloodbank_channel',
            'Blood Bank Notifications',
            channelDescription: 'Notifications for blood bank activities',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            enableVibration: true,
            playSound: true,
          );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.show(
        notification['id'],
        notification['title'],
        notification['message'],
        platformChannelSpecifics,
        payload: jsonEncode(notification),
      );
    } catch (e) {
      // Handle error silently
    }
  }

  // Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    try {
      final payload = response.payload;
      if (payload != null) {
        final notification = jsonDecode(payload);

        // Handle notification tap based on type
        _handleNotificationTap(notification);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  // Handle notification tap based on type
  static void _handleNotificationTap(Map<String, dynamic> notification) {
    final type = notification['type'];

    switch (type) {
      case 'blood_request':
        // Navigate to blood request details
        break;
      case 'donation_reminder':
        // Navigate to donation page
        break;
      case 'inventory_alert':
        // Navigate to inventory page
        break;
      default:
        // Handle unknown notification type
        break;
    }
  }

  // Get notifications for user
  static Future<List<Map<String, dynamic>>> getNotificationsForUser(
    int userId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey);

      if (notificationsJson != null) {
        final List<dynamic> notifications = jsonDecode(notificationsJson);
        return notifications
            .where(
              (notification) =>
                  notification['userId'] == userId ||
                  notification['userId'] == null,
            )
            .cast<Map<String, dynamic>>()
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Get notifications by type
  static Future<List<Map<String, dynamic>>> getNotificationsByType(
    String type,
    int? userId,
  ) async {
    try {
      final notifications = await getNotificationsForUser(userId ?? 0);
      return notifications
          .where((notification) => notification['type'] == type)
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Mark notification as read
  static Future<bool> markNotificationAsRead(int notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey);

      if (notificationsJson != null) {
        final List<dynamic> notifications = jsonDecode(notificationsJson);
        final notificationIndex = notifications.indexWhere(
          (n) => n['id'] == notificationId,
        );

        if (notificationIndex != -1) {
          notifications[notificationIndex]['isRead'] = true;
          await prefs.setString(_notificationsKey, jsonEncode(notifications));
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Mark all notifications as read
  static Future<bool> markAllNotificationsAsRead(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey);

      if (notificationsJson != null) {
        final List<dynamic> notifications = jsonDecode(notificationsJson);
        bool hasChanges = false;

        for (int i = 0; i < notifications.length; i++) {
          final notification = notifications[i];
          if ((notification['userId'] == userId ||
                  notification['userId'] == null) &&
              !notification['isRead']) {
            notifications[i]['isRead'] = true;
            hasChanges = true;
          }
        }

        if (hasChanges) {
          await prefs.setString(_notificationsKey, jsonEncode(notifications));
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Delete specific notification
  static Future<bool> deleteNotification(int notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey);

      if (notificationsJson != null) {
        final List<dynamic> notifications = jsonDecode(notificationsJson);
        final filteredNotifications = notifications
            .where((notification) => notification['id'] != notificationId)
            .toList();

        if (filteredNotifications.length < notifications.length) {
          await prefs.setString(
            _notificationsKey,
            jsonEncode(filteredNotifications),
          );
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Schedule notification (simplified)
  static Future<bool> scheduleNotification({
    required String title,
    required String message,
    required DateTime scheduledDate,
    String type = 'reminder',
    Map<String, dynamic>? payload,
  }) async {
    try {
      // For now, just add to regular notifications
      return await addNotification(
        title: title,
        message: message,
        type: type,
        payload: payload,
      );
    } catch (e) {
      return false;
    }
  }

  // Cancel scheduled notification (simplified)
  static Future<bool> cancelScheduledNotification(int notificationId) async {
    try {
      return await deleteNotification(notificationId);
    } catch (e) {
      return false;
    }
  }

  // Cancel all scheduled notifications (simplified)
  static Future<bool> cancelAllScheduledNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_scheduledNotificationsKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get unread notifications count
  static Future<int> getUnreadNotificationsCount(int userId) async {
    try {
      final notifications = await getNotificationsForUser(userId);
      return notifications
          .where((notification) => !notification['isRead'])
          .length;
    } catch (e) {
      return 0;
    }
  }

  // Poll for notifications (called periodically)
  static Future<void> pollNotifications(int userId) async {
    try {
      // Update badge or UI as needed
    } catch (e) {
      // Handle polling error silently
    }
  }

  // Clear all notifications for user
  static Future<bool> clearNotificationsForUser(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey);

      if (notificationsJson != null) {
        final List<dynamic> notifications = jsonDecode(notificationsJson);
        final filteredNotifications = notifications
            .where((notification) => notification['userId'] != userId)
            .toList();

        await prefs.setString(
          _notificationsKey,
          jsonEncode(filteredNotifications),
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Show notification snackbar
  static void showNotificationSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.blue,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Show notification dialog
  static Future<void> showNotificationDialog(
    BuildContext context,
    String title,
    String message, {
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            if (cancelText != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onCancel?.call();
                },
                child: Text(cancelText),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm?.call();
              },
              child: Text(confirmText ?? 'OK'),
            ),
          ],
        );
      },
    );
  }

  // Show notification bottom sheet
  static Future<void> showNotificationBottomSheet(
    BuildContext context,
    String title,
    String message, {
    List<Widget>? actions,
  }) async {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(message),
              if (actions != null) ...[const SizedBox(height: 16), ...actions],
            ],
          ),
        );
      },
    );
  }

  // Dispose resources
  static void dispose() {
    _isInitialized = false;
  }
}
