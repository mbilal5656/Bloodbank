class BloodInventoryModel {
  final int? id;
  final String bloodGroup;
  final int quantity;
  final String status;
  final String lastUpdated;
  final int? createdBy;

  BloodInventoryModel({
    this.id,
    required this.bloodGroup,
    required this.quantity,
    required this.status,
    required this.lastUpdated,
    this.createdBy,
  });

  // Create from Map (from database)
  factory BloodInventoryModel.fromMap(Map<String, dynamic> map) {
    return BloodInventoryModel(
      id: map['id'] as int?,
      bloodGroup: map['bloodGroup'] as String,
      quantity: map['quantity'] as int,
      status: map['status'] as String,
      lastUpdated: map['lastUpdated'] as String,
      createdBy: map['createdBy'] as int?,
    );
  }

  // Convert to Map (for database)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'bloodGroup': bloodGroup,
      'quantity': quantity,
      'status': status,
      'lastUpdated': lastUpdated,
      'createdBy': createdBy,
    };
  }

  // Create a copy with updated fields
  BloodInventoryModel copyWith({
    int? id,
    String? bloodGroup,
    int? quantity,
    String? status,
    String? lastUpdated,
    int? createdBy,
  }) {
    return BloodInventoryModel(
      id: id ?? this.id,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  // Check if blood is available
  bool get isAvailable => quantity > 0 && status == 'Available';

  // Check if blood is low (less than 5 units)
  bool get isLow => quantity <= 5 && quantity > 0;

  // Check if blood is critical (0 units)
  bool get isCritical => quantity == 0;

  // Get status color
  String get statusColor {
    if (isCritical) return '#F44336'; // Red
    if (isLow) return '#FF9800'; // Orange
    return '#4CAF50'; // Green
  }

  // Get status display text
  String get statusDisplay {
    if (isCritical) return 'Out of Stock';
    if (isLow) return 'Low Stock';
    return 'Available';
  }

  // Get quantity display
  String get quantityDisplay => '$quantity units';

  @override
  String toString() {
    return 'BloodInventoryModel(id: $id, bloodGroup: $bloodGroup, quantity: $quantity, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BloodInventoryModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 