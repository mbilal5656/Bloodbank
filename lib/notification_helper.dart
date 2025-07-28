import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'theme/app_theme.dart';

class NotificationHelper {
  static const String _notificationsKey = 'notifications';
  static const String _nextNotificationIdKey = 'next_notification_id';

  // Initialize notifications
  static Future<void> initializeNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey);

      if (notificationsJson == null) {
        // Create default notifications
        final defaultNotifications = [
          {
            'id': 1,
            'title': 'Welcome to Blood Bank System',
            'message': 'Thank you for using our blood bank management system.',
            'type': 'info',
            'timestamp': DateTime.now().toIso8601String(),
            'read': false,
            'targetUserType': 'all',
          },
        ];

        await prefs.setString(_notificationsKey, jsonEncode(defaultNotifications));
        await prefs.setInt(_nextNotificationIdKey, 2);
      }
    } catch (e) {
      print('Error initializing notifications: $e');
      // Don't rethrow to allow app to continue
    }
  }

  // Get all notifications
  static Future<List<Map<String, dynamic>>> getAllNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey);

      if (notificationsJson != null) {
        final List<dynamic> decoded = jsonDecode(notificationsJson);
        return decoded.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error getting all notifications: $e');
      return [];
    }
  }

  // Get notifications by user type
  static Future<List<Map<String, dynamic>>> getNotificationsByUserType(String userType) async {
    try {
      final notifications = await getAllNotifications();
      return notifications.where((notification) {
        final targetType = notification['targetUserType'];
        return targetType == 'all' || targetType == userType;
      }).toList();
    } catch (e) {
      print('Error getting notifications by user type: $e');
      return [];
    }
  }

  // Add new notification
  static Future<bool> addNotification({
    required String title,
    required String message,
    required String type,
    required String targetUserType,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifications = await getAllNotifications();

      // Get next notification ID
      final nextId = prefs.getInt(_nextNotificationIdKey) ?? notifications.length + 1;

      // Create new notification
      final newNotification = {
        'id': nextId,
        'title': title,
        'message': message,
        'type': type,
        'timestamp': DateTime.now().toIso8601String(),
        'read': false,
        'targetUserType': targetUserType,
      };

      notifications.add(newNotification);

      // Save updated notifications list
      await prefs.setString(_notificationsKey, jsonEncode(notifications));
      await prefs.setInt(_nextNotificationIdKey, nextId + 1);

      return true;
    } catch (e) {
      print('Error adding notification: $e');
      return false;
    }
  }

  // Mark notification as read
  static Future<bool> markNotificationAsRead(int notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifications = await getAllNotifications();

      final notificationIndex = notifications.indexWhere((notification) => notification['id'] == notificationId);
      if (notificationIndex != -1) {
        notifications[notificationIndex]['read'] = true;

        await prefs.setString(_notificationsKey, jsonEncode(notifications));
        return true;
      }
      return false;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  // Delete notification
  static Future<bool> deleteNotification(int notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifications = await getAllNotifications();

      final notificationIndex = notifications.indexWhere((notification) => notification['id'] == notificationId);
      if (notificationIndex != -1) {
        notifications.removeAt(notificationIndex);

        await prefs.setString(_notificationsKey, jsonEncode(notifications));
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }

  // Get unread notifications count
  static Future<int> getUnreadNotificationsCount(String userType) async {
    try {
      final notifications = await getNotificationsByUserType(userType);
      return notifications.where((notification) => notification['read'] == false).length;
    } catch (e) {
      print('Error getting unread notifications count: $e');
      return 0;
    }
  }

  // Show notification dialog
  static void showNotificationDialog(BuildContext context, Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(notification['title']),
          content: Text(notification['message']),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Get notification color based on type
  static Color getNotificationColor(String type) {
    switch (type.toLowerCase()) {
      case 'success':
        return AppTheme.successColor;
      case 'error':
        return AppTheme.errorColor;
      case 'warning':
        return AppTheme.warningColor;
      case 'info':
        return AppTheme.infoColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  // Get notification icon based on type
  static IconData getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'success':
        return Icons.check_circle;
      case 'error':
        return Icons.error;
      case 'warning':
        return Icons.warning;
      case 'info':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }
} 