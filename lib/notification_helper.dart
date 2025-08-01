import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'dart:async';
import 'package:timezone/timezone.dart' as tz;

class NotificationHelper {
  static const String _notificationsKey = 'notifications';
  static const String _nextNotificationIdKey = 'next_notification_id';
  static const String _notificationSettingsKey = 'notification_settings';

  // Flutter Local Notifications
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Notification settings
  static bool _isInitialized = false;
  static Timer? _notificationTimer;

  // Initialize notifications
  static Future<void> initializeNotifications() async {
    try {
      if (_isInitialized) return;

      // Initialize SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey);

      if (notificationsJson == null) {
        // Initialize empty notifications list
        await prefs.setString(_notificationsKey, '[]');
        await prefs.setInt(_nextNotificationIdKey, 1);
        debugPrint('Notifications initialized successfully');
      }

      // Initialize Flutter Local Notifications
      await _initializeLocalNotifications();

      // Load notification settings
      await _loadNotificationSettings();

      _isInitialized = true;
      debugPrint('Notification system initialized successfully');
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
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

      debugPrint('Flutter Local Notifications initialized');
    } catch (e) {
      debugPrint('Error initializing Flutter Local Notifications: $e');
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
            _notificationSettingsKey, jsonEncode(defaultSettings));
      }
    } catch (e) {
      debugPrint('Error loading notification settings: $e');
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
      debugPrint('Error getting notification settings: $e');
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
      Map<String, dynamic> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_notificationSettingsKey, jsonEncode(settings));
      debugPrint('Notification settings updated successfully');
      return true;
    } catch (e) {
      debugPrint('Error updating notification settings: $e');
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

      final List<dynamic> notifications =
          notificationsJson != null ? jsonDecode(notificationsJson) : [];

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

      debugPrint('Notification added successfully: $title');
      return true;
    } catch (e) {
      debugPrint('Error adding notification: $e');
      return false;
    }
  }

  // Show local notification
  static Future<void> _showLocalNotification(
      Map<String, dynamic> notification) async {
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
      debugPrint('Error showing local notification: $e');
    }
  }

  // Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    try {
      final payload = response.payload;
      if (payload != null) {
        final notification = jsonDecode(payload);
        debugPrint('Notification tapped: ${notification['title']}');

        // Handle notification tap based on type
        _handleNotificationTap(notification);
      }
    } catch (e) {
      debugPrint('Error handling notification tap: $e');
    }
  }

  // Handle notification tap based on type
  static void _handleNotificationTap(Map<String, dynamic> notification) {
    final type = notification['type'];
    final payload = notification['payload'];

    switch (type) {
      case 'blood_request':
        // Navigate to blood request details
        debugPrint('Navigate to blood request: ${payload?['requestId']}');
        break;
      case 'donation_reminder':
        // Navigate to donation page
        debugPrint('Navigate to donation page');
        break;
      case 'inventory_alert':
        // Navigate to inventory page
        debugPrint('Navigate to inventory page');
        break;
      default:
        debugPrint('Unknown notification type: $type');
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
      debugPrint('Error getting notifications for user: $e');
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
      debugPrint('Error getting notifications by type: $e');
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
          debugPrint('Notification marked as read: $notificationId');
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
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
          debugPrint('All notifications marked as read for user: $userId');
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
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
      debugPrint('Error getting unread notifications count: $e');
      return 0;
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
        debugPrint('Notifications cleared for user: $userId');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error clearing notifications for user: $e');
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
          debugPrint('Notification deleted: $notificationId');
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      return false;
    }
  }

  // Schedule notification
  static Future<bool> scheduleNotification({
    required String title,
    required String message,
    required DateTime scheduledDate,
    required String type,
    int? userId,
    String priority = 'Normal',
    Map<String, dynamic>? payload,
  }) async {
    try {
      final settings = await getNotificationSettings();
      if (!settings['enabled']) return false;

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'bloodbank_scheduled_channel',
        'Scheduled Blood Bank Notifications',
        channelDescription: 'Scheduled notifications for blood bank activities',
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

      final notificationId = DateTime.now().millisecondsSinceEpoch;
      final notification = {
        'id': notificationId,
        'title': title,
        'message': message,
        'type': type,
        'userId': userId,
        'priority': priority,
        'payload': payload,
      };

      // Convert DateTime to TZDateTime for scheduling
      final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        title,
        message,
        tzDateTime,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: jsonEncode(notification),
      );

      debugPrint('Notification scheduled for: $scheduledDate');
      return true;
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
      return false;
    }
  }

  // Cancel scheduled notification
  static Future<bool> cancelScheduledNotification(int notificationId) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(notificationId);
      debugPrint('Scheduled notification cancelled: $notificationId');
      return true;
    } catch (e) {
      debugPrint('Error cancelling scheduled notification: $e');
      return false;
    }
  }

  // Cancel all scheduled notifications
  static Future<bool> cancelAllScheduledNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      debugPrint('All scheduled notifications cancelled');
      return true;
    } catch (e) {
      debugPrint('Error cancelling all scheduled notifications: $e');
      return false;
    }
  }

  // Start notification polling
  static void startNotificationPolling(int userId, Duration interval) {
    _notificationTimer?.cancel();
    _notificationTimer = Timer.periodic(interval, (timer) async {
      try {
        final unreadCount = await getUnreadNotificationsCount(userId);
        if (unreadCount > 0) {
          debugPrint('Unread notifications: $unreadCount');
          // You can add badge update logic here
        }
      } catch (e) {
        debugPrint('Error in notification polling: $e');
      }
    });
  }

  // Stop notification polling
  static void stopNotificationPolling() {
    _notificationTimer?.cancel();
    _notificationTimer = null;
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
              if (actions != null) ...[
                const SizedBox(height: 16),
                ...actions,
              ],
            ],
          ),
        );
      },
    );
  }

  // Dispose resources
  static void dispose() {
    stopNotificationPolling();
    _isInitialized = false;
  }
}
