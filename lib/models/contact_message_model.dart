class ContactMessage {
  final int? id;
  final String name;
  final String email;
  final String subject;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? adminResponse;

  ContactMessage({
    this.id,
    required this.name,
    required this.email,
    required this.subject,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.adminResponse,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'subject': subject,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead ? 1 : 0,
      'adminResponse': adminResponse,
    };
  }

  factory ContactMessage.fromMap(Map<String, dynamic> map) {
    return ContactMessage(
      id: map['id'],
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      subject: map['subject'] ?? '',
      message: map['message'] ?? '',
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      isRead: map['isRead'] == 1,
      adminResponse: map['adminResponse'],
    );
  }

  ContactMessage copyWith({
    int? id,
    String? name,
    String? email,
    String? subject,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    String? adminResponse,
  }) {
    return ContactMessage(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      adminResponse: adminResponse ?? this.adminResponse,
    );
  }
}
