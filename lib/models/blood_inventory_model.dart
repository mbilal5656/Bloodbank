class BloodInventoryModel {
  final int? id;
  final String bloodGroup;
  final int quantity;
  final int reservedQuantity;
  final String status;
  final DateTime? expiryDate;
  final DateTime lastUpdated;
  final int? createdBy;
  final String? notes;

  BloodInventoryModel({
    this.id,
    required this.bloodGroup,
    required this.quantity,
    this.reservedQuantity = 0,
    this.status = 'Available',
    this.expiryDate,
    required this.lastUpdated,
    this.createdBy,
    this.notes,
  });

  factory BloodInventoryModel.fromMap(Map<String, dynamic> map) {
    return BloodInventoryModel(
      id: map['id'] as int?,
      bloodGroup: map['bloodGroup'] as String,
      quantity: map['quantity'] as int,
      reservedQuantity: map['reservedQuantity'] as int? ?? 0,
      status: map['status'] as String,
      expiryDate: map['expiryDate'] != null
          ? DateTime.parse(map['expiryDate'] as String)
          : null,
      lastUpdated: DateTime.parse(map['lastUpdated'] as String),
      createdBy: map['createdBy'] as int?,
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bloodGroup': bloodGroup,
      'quantity': quantity,
      'reservedQuantity': reservedQuantity,
      'status': status,
      'expiryDate': expiryDate?.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'createdBy': createdBy,
      'notes': notes,
    };
  }

  BloodInventoryModel copyWith({
    int? id,
    String? bloodGroup,
    int? quantity,
    int? reservedQuantity,
    String? status,
    DateTime? expiryDate,
    DateTime? lastUpdated,
    int? createdBy,
    String? notes,
  }) {
    return BloodInventoryModel(
      id: id ?? this.id,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      quantity: quantity ?? this.quantity,
      reservedQuantity: reservedQuantity ?? this.reservedQuantity,
      status: status ?? this.status,
      expiryDate: expiryDate ?? this.expiryDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      createdBy: createdBy ?? this.createdBy,
      notes: notes ?? this.notes,
    );
  }

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

  // Helper methods
  int get availableQuantity => quantity - reservedQuantity;

  bool get isAvailable => availableQuantity > 0;

  bool get isLowStock => availableQuantity <= 10;

  bool get isCriticalStock => availableQuantity <= 5;

  bool get isExpired =>
      expiryDate != null && expiryDate!.isBefore(DateTime.now());

  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final daysUntilExpiry = expiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 7 && daysUntilExpiry >= 0;
  }

  String get stockLevel {
    if (isCriticalStock) return 'Critical';
    if (isLowStock) return 'Low';
    if (availableQuantity > 50) return 'High';
    return 'Normal';
  }

  String get stockLevelColor {
    switch (stockLevel) {
      case 'Critical':
        return '#FF0000';
      case 'Low':
        return '#FF6600';
      case 'Normal':
        return '#00AA00';
      case 'High':
        return '#006600';
      default:
        return '#888888';
    }
  }

  double get utilizationRate {
    if (quantity == 0) return 0.0;
    return (reservedQuantity / quantity) * 100;
  }

  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'available':
        return 'Available';
      case 'reserved':
        return 'Reserved';
      case 'expired':
        return 'Expired';
      case 'quarantine':
        return 'Quarantine';
      default:
        return status;
    }
  }

  bool get canReserve => isAvailable && !isExpired;

  bool get canDonate => !isExpired;
}
