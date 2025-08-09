class NotificationModel {
  final int? id;
  final int? userId;
  final String title;
  final String message;
  final String type;
  final String priority;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? payload;

  NotificationModel({
    this.id,
    this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.priority = 'Normal',
    this.isRead = false,
    required this.createdAt,
    this.payload,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as int?,
      userId: map['userId'] as int?,
      title: map['title'] as String,
      message: map['message'] as String,
      type: map['type'] as String,
      priority: map['priority'] as String? ?? 'Normal',
      isRead: (map['isRead'] as int?) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      payload: map['payload'] != null
          ? Map<String, dynamic>.from(map['payload'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'priority': priority,
      'isRead': isRead ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'payload': payload,
    };
  }

  NotificationModel copyWith({
    int? id,
    int? userId,
    String? title,
    String? message,
    String? type,
    String? priority,
    bool? isRead,
    DateTime? createdAt,
    Map<String, dynamic>? payload,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      payload: payload ?? this.payload,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, type: $type, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Helper methods
  bool get isHighPriority => priority.toLowerCase() == 'high';

  bool get isUrgent => priority.toLowerCase() == 'urgent';

  bool get isCritical => priority.toLowerCase() == 'critical';

  String get priorityColor {
    switch (priority.toLowerCase()) {
      case 'critical':
        return '#FF0000';
      case 'urgent':
        return '#FF6600';
      case 'high':
        return '#FFAA00';
      case 'normal':
        return '#00AA00';
      case 'low':
        return '#006600';
      default:
        return '#888888';
    }
  }

  String get typeDisplay {
    switch (type.toLowerCase()) {
      case 'blood_request':
        return 'Blood Request';
      case 'donation_reminder':
        return 'Donation Reminder';
      case 'inventory_alert':
        return 'Inventory Alert';
      case 'system_notification':
        return 'System Notification';
      case 'user_activity':
        return 'User Activity';
      default:
        return type;
    }
  }

  String get typeIcon {
    switch (type.toLowerCase()) {
      case 'blood_request':
        return '🩸';
      case 'donation_reminder':
        return '💉';
      case 'inventory_alert':
        return '⚠️';
      case 'system_notification':
        return '🔔';
      case 'user_activity':
        return '👤';
      default:
        return '📢';
    }
  }

  bool get isGlobal => userId == null;

  bool get isPersonal => userId != null;

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours < 24;
  }

  bool get isToday {
    final now = DateTime.now();
    return createdAt.year == now.year &&
        createdAt.month == now.month &&
        createdAt.day == now.day;
  }

  String get shortMessage {
    if (message.length <= 50) return message;
    return '${message.substring(0, 50)}...';
  }
}
