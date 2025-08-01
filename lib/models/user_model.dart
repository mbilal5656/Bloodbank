class UserModel {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String userType;
  final String? bloodGroup;
  final int? age;
  final String? contactNumber;
  final String? address;
  final bool isActive;
  final DateTime? lastLogin;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.userType,
    this.bloodGroup,
    this.age,
    this.contactNumber,
    this.address,
    this.isActive = true,
    this.lastLogin,
    required this.createdAt,
    required this.updatedAt,
  });

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
      address: map['address'] as String?,
      isActive: (map['isActive'] as int?) == 1,
      lastLogin: map['lastLogin'] != null
          ? DateTime.parse(map['lastLogin'] as String)
          : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'userType': userType,
      'bloodGroup': bloodGroup,
      'age': age,
      'contactNumber': contactNumber,
      'address': address,
      'isActive': isActive ? 1 : 0,
      'lastLogin': lastLogin?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? userType,
    String? bloodGroup,
    int? age,
    String? contactNumber,
    String? address,
    bool? isActive,
    DateTime? lastLogin,
    DateTime? createdAt,
    DateTime? updatedAt,
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
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, userType: $userType, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Helper methods
  bool get isAdmin => userType.toLowerCase() == 'admin';
  bool get isDonor => userType.toLowerCase() == 'donor';
  bool get isReceiver => userType.toLowerCase() == 'receiver';

  String get displayName => name.isNotEmpty ? name : email.split('@')[0];

  String get userTypeDisplay {
    switch (userType.toLowerCase()) {
      case 'admin':
        return 'Administrator';
      case 'donor':
        return 'Blood Donor';
      case 'receiver':
        return 'Blood Receiver';
      default:
        return userType;
    }
  }

  String get statusText => isActive ? 'Active' : 'Inactive';

  bool get hasBloodGroup => bloodGroup != null && bloodGroup != 'N/A';

  bool get hasContactInfo => contactNumber != null && contactNumber!.isNotEmpty;

  bool get hasAddress => address != null && address!.isNotEmpty;
}
