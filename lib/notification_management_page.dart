import 'package:flutter/material.dart';
import 'notification_helper.dart';
import 'session_manager.dart';
import 'main.dart' show UserSession;

class NotificationManagementPage extends StatefulWidget {
  const NotificationManagementPage({super.key});

  @override
  State<NotificationManagementPage> createState() =>
      _NotificationManagementPageState();
}

class _NotificationManagementPageState
    extends State<NotificationManagementPage> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedType = 'info';
  String _selectedTargetUserType = 'all';

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get notifications for current user
      final notifications = await NotificationHelper.getNotificationsForUser(
        UserSession.userId,
      );

      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendNotification() async {
    if (_titleController.text.isEmpty || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final success = await NotificationHelper.addNotification(
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
        type: _selectedType,
        userId: null, // Send to all users
      );

      if (success) {
        _titleController.clear();
        _messageController.clear();
        _selectedType = 'info';
        _selectedTargetUserType = 'all';

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        await _loadNotifications();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send notification'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending notification: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _markAsRead(int notificationId) async {
    try {
      final success = await NotificationHelper.markNotificationAsRead(
        notificationId,
      );
      if (success) {
        await _loadNotifications();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification marked as read'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> _clearNotifications() async {
    try {
      final success = await NotificationHelper.clearNotificationsForUser(
        UserSession.userId,
      );
      if (success) {
        await _loadNotifications();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notifications cleared'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error clearing notifications: $e');
    }
  }

  Color _getNotificationColor(String type) {
    switch (type.toLowerCase()) {
      case 'success':
        return Colors.green;
      case 'error':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'info':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String type) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Management'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _clearNotifications,
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear All Notifications',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Send Notification Form
                Card(
                  margin: const EdgeInsets.all(16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Send Notification',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: const Color(0xFF1A237E),
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            labelText: 'Message',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedType,
                                decoration: const InputDecoration(
                                  labelText: 'Type',
                                  border: OutlineInputBorder(),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'info',
                                    child: Text('Info'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'success',
                                    child: Text('Success'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'warning',
                                    child: Text('Warning'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'error',
                                    child: Text('Error'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedType = value!;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: _sendNotification,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A237E),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Send'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Notifications List
                Expanded(
                  child: _notifications.isEmpty
                      ? const Center(
                          child: Text(
                            'No notifications found',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _notifications.length,
                          itemBuilder: (context, index) {
                            final notification = _notifications[index];
                            final isRead = notification['isRead'] ?? false;
                            final type = notification['type'] ?? 'info';
                            final createdAt = DateTime.tryParse(
                              notification['createdAt'] ?? '',
                            );

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 4.0,
                              ),
                              color: isRead ? Colors.grey[50] : Colors.white,
                              child: ListTile(
                                leading: Icon(
                                  _getNotificationIcon(type),
                                  color: _getNotificationColor(type),
                                ),
                                title: Text(
                                  notification['title'] ?? '',
                                  style: TextStyle(
                                    fontWeight: isRead
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(notification['message'] ?? ''),
                                    if (createdAt != null)
                                      Text(
                                        '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: !isRead
                                    ? IconButton(
                                        onPressed: () =>
                                            _markAsRead(notification['id']),
                                        icon: const Icon(Icons.mark_email_read),
                                        tooltip: 'Mark as Read',
                                      )
                                    : null,
                                onTap: () {
                                  NotificationHelper.showNotificationDialog(
                                    context,
                                    notification['title'] ?? '',
                                    notification['message'] ?? '',
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
