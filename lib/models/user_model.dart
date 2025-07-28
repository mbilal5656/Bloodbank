class UserModel {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String userType;
  final String? bloodGroup;
  final int? age;
  final String? contactNumber;
  final String createdAt;
  final String updatedAt;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.userType,
    this.bloodGroup,
    this.age,
    this.contactNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create from Map (from database)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      userType: map['userType'] as String,
      bloodGroup: map['bloodGroup'] as String?,
      age: map['age'] as int?,
      contactNumber: map['contactNumber'] as String?,
      createdAt: map['createdAt'] as String,
      updatedAt: map['updatedAt'] as String,
    );
  }

  // Convert to Map (for database)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'password': password,
      'userType': userType,
      'bloodGroup': bloodGroup,
      'age': age,
      'contactNumber': contactNumber,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Create a copy with updated fields
  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? userType,
    String? bloodGroup,
    int? age,
    String? contactNumber,
    String? createdAt,
    String? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      userType: userType ?? this.userType,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      age: age ?? this.age,
      contactNumber: contactNumber ?? this.contactNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Check if user is admin
  bool get isAdmin => userType == 'Admin';

  // Check if user is donor
  bool get isDonor => userType == 'Donor';

  // Check if user is receiver
  bool get isReceiver => userType == 'Receiver';

  // Get display name
  String get displayName => name.isNotEmpty ? name : email;

  // Get user type display name
  String get userTypeDisplay {
    switch (userType) {
      case 'Admin':
        return 'Administrator';
      case 'Donor':
        return 'Blood Donor';
      case 'Receiver':
        return 'Blood Receiver';
      default:
        return userType;
    }
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, userType: $userType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
