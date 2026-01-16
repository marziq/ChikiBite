import 'package:cloud_firestore/cloud_firestore.dart';

/// Types of vouchers
enum VoucherType {
  freeItem,        // Free specific item category (burger, drink, etc.)
  percentDiscount, // Percentage discount
  fixedDiscount,   // Fixed amount discount
  freeDelivery,    // Free delivery
}

/// Status of a voucher
enum VoucherStatus {
  available,  // Ready to use
  used,       // Already redeemed
  expired,    // Past expiry date
}

/// Model representing a user's redeemed voucher
class Voucher {
  final String id;
  final String userId;
  final String name;           // e.g., "Free Burger"
  final String description;
  final VoucherType type;
  final String? itemCategory;  // For freeItem type: "burger", "drink", "fries", etc.
  final double? discountValue; // For discount types
  final int pointsCost;        // How many points it cost
  final VoucherStatus status;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final DateTime? usedAt;
  final String? usedOnOrderId;

  const Voucher({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.type,
    this.itemCategory,
    this.discountValue,
    required this.pointsCost,
    this.status = VoucherStatus.available,
    required this.createdAt,
    this.expiresAt,
    this.usedAt,
    this.usedOnOrderId,
  });

  bool get isValid {
    if (status != VoucherStatus.available) return false;
    if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) return false;
    return true;
  }

  Voucher copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    VoucherType? type,
    String? itemCategory,
    double? discountValue,
    int? pointsCost,
    VoucherStatus? status,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? usedAt,
    String? usedOnOrderId,
  }) {
    return Voucher(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      itemCategory: itemCategory ?? this.itemCategory,
      discountValue: discountValue ?? this.discountValue,
      pointsCost: pointsCost ?? this.pointsCost,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      usedAt: usedAt ?? this.usedAt,
      usedOnOrderId: usedOnOrderId ?? this.usedOnOrderId,
    );
  }

  factory Voucher.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    VoucherType parseType(dynamic value) {
      if (value is String) {
        switch (value) {
          case 'freeItem':
            return VoucherType.freeItem;
          case 'percentDiscount':
            return VoucherType.percentDiscount;
          case 'fixedDiscount':
            return VoucherType.fixedDiscount;
          case 'freeDelivery':
            return VoucherType.freeDelivery;
        }
      }
      return VoucherType.freeItem;
    }

    VoucherStatus parseStatus(dynamic value) {
      if (value is String) {
        switch (value) {
          case 'available':
            return VoucherStatus.available;
          case 'used':
            return VoucherStatus.used;
          case 'expired':
            return VoucherStatus.expired;
        }
      }
      return VoucherStatus.available;
    }

    return Voucher(
      id: docId ?? (map['id'] as String?) ?? '',
      userId: (map['userId'] as String?) ?? '',
      name: (map['name'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      type: parseType(map['type']),
      itemCategory: map['itemCategory'] as String?,
      discountValue: (map['discountValue'] as num?)?.toDouble(),
      pointsCost: (map['pointsCost'] as num?)?.toInt() ?? 0,
      status: parseStatus(map['status']),
      createdAt: parseDate(map['createdAt']) ?? DateTime.now(),
      expiresAt: parseDate(map['expiresAt']),
      usedAt: parseDate(map['usedAt']),
      usedOnOrderId: map['usedOnOrderId'] as String?,
    );
  }

  factory Voucher.fromDocument(DocumentSnapshot doc) {
    final data = doc.data();
    if (data is Map<String, dynamic>) {
      return Voucher.fromMap(data, docId: doc.id);
    }
    return Voucher(
      id: doc.id,
      userId: '',
      name: '',
      description: '',
      type: VoucherType.freeItem,
      pointsCost: 0,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'type': type.name,
      if (itemCategory != null) 'itemCategory': itemCategory,
      if (discountValue != null) 'discountValue': discountValue,
      'pointsCost': pointsCost,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      if (expiresAt != null) 'expiresAt': Timestamp.fromDate(expiresAt!),
      if (usedAt != null) 'usedAt': Timestamp.fromDate(usedAt!),
      if (usedOnOrderId != null) 'usedOnOrderId': usedOnOrderId,
    };
  }

  @override
  String toString() {
    return 'Voucher(name: $name, type: $type, status: $status)';
  }
}

/// Predefined redemption options
class RedemptionOption {
  final String name;
  final String description;
  final int pointsCost;
  final VoucherType type;
  final String? itemCategory;
  final double? discountValue;
  final IconType icon;

  const RedemptionOption({
    required this.name,
    required this.description,
    required this.pointsCost,
    required this.type,
    this.itemCategory,
    this.discountValue,
    required this.icon,
  });
}

enum IconType {
  burger,
  drink,
  meal,
  discount,
  delivery,
  percent,
}

/// Available redemption options
final List<RedemptionOption> redemptionOptions = [
  const RedemptionOption(
    name: 'Free Burger',
    description: 'Get any burger for free',
    pointsCost: 500,
    type: VoucherType.freeItem,
    itemCategory: 'burger',
    icon: IconType.burger,
  ),
  const RedemptionOption(
    name: 'Free Drink',
    description: 'Get any drink for free',
    pointsCost: 200,
    type: VoucherType.freeItem,
    itemCategory: 'drink',
    icon: IconType.drink,
  ),
  const RedemptionOption(
    name: 'Free Meal',
    description: 'Get a complete meal combo free',
    pointsCost: 1000,
    type: VoucherType.freeItem,
    itemCategory: 'meal',
    icon: IconType.meal,
  ),
  const RedemptionOption(
    name: '10% Discount',
    description: 'Get 10% off your order',
    pointsCost: 300,
    type: VoucherType.percentDiscount,
    discountValue: 10,
    icon: IconType.discount,
  ),
  const RedemptionOption(
    name: 'Free Delivery',
    description: 'Free delivery on your order',
    pointsCost: 250,
    type: VoucherType.freeDelivery,
    icon: IconType.delivery,
  ),
  const RedemptionOption(
    name: '25% Discount',
    description: 'Get 25% off your order',
    pointsCost: 800,
    type: VoucherType.percentDiscount,
    discountValue: 25,
    icon: IconType.percent,
  ),
];
