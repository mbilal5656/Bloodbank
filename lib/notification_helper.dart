import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationHelper {
  static const String _notificationsKey = 'notifications';
  static const String _nextNotificationIdKey = 'next_notification_id';

  // Initialize notifications
  static Future<void> initializeNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey);

      if (notificationsJson == null) {
        // Initialize empty notifications list
        await prefs.setString(_notificationsKey, '[]');
        await prefs.setInt(_nextNotificationIdKey, 1);
        debugPrint('Notifications initialized successfully');
      }
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  // Add notification
  static Future<bool> addNotification({
    required String title,
    required String message,
    required String type,
    int? userId,
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
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
      };

      notifications.add(notification);

      await prefs.setString(_notificationsKey, jsonEncode(notifications));
      await prefs.setInt(_nextNotificationIdKey, nextId + 1);

      debugPrint('Notification added successfully: $title');
      return true;
    } catch (e) {
      debugPrint('Error adding notification: $e');
      return false;
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

  // Show notification snackbar
  static void showNotificationSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Show notification dialog
  static Future<void> showNotificationDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
