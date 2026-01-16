import 'package:cloud_firestore/cloud_firestore.dart';

/// Types of discounts a promo code can offer
enum DiscountType {
  percentage, // e.g., 10% off
  fixedAmount, // e.g., RM5 off
  freeDelivery, // Free delivery
}

/// Model representing a promo code
class PromoCode {
  final String id;
  final String code; // The actual code users enter (e.g., "WELCOME10")
  final String description;
  final DiscountType discountType;
  final double discountValue; // Percentage (0-100) or fixed amount
  final double? minOrderAmount; // Minimum order to use this promo
  final double? maxDiscountAmount; // Maximum discount cap for percentage discounts
  final int? usageLimit; // Total usage limit across all users
  final int usageCount; // Current usage count
  final int? perUserLimit; // How many times each user can use this
  final DateTime? validFrom;
  final DateTime? validUntil;
  final bool isActive;
  final List<String>? applicableCategories; // Specific menu categories (null = all)
  final DateTime createdAt;
  final String? userId; // For personal promo codes (from point redemption)
  final bool isPersonal; // True if this is a personal code for specific user
  final int? pointsCost; // How many points it cost to redeem (for display)

  const PromoCode({
    required this.id,
    required this.code,
    required this.description,
    required this.discountType,
    required this.discountValue,
    this.minOrderAmount,
    this.maxDiscountAmount,
    this.usageLimit,
    this.usageCount = 0,
    this.perUserLimit,
    this.validFrom,
    this.validUntil,
    this.isActive = true,
    this.applicableCategories,
    required this.createdAt,
    this.userId,
    this.isPersonal = false,
    this.pointsCost,
  });

  /// Check if the promo code is currently valid
  bool get isValid {
    if (!isActive) return false;
    
    final now = DateTime.now();
    
    // Check date validity
    if (validFrom != null && now.isBefore(validFrom!)) return false;
    if (validUntil != null && now.isAfter(validUntil!)) return false;
    
    // Check usage limit
    if (usageLimit != null && usageCount >= usageLimit!) return false;
    
    return true;
  }

  /// Calculate the discount amount for a given subtotal
  double calculateDiscount(double subtotal) {
    if (!isValid) return 0;
    
    // Check minimum order amount
    if (minOrderAmount != null && subtotal < minOrderAmount!) return 0;
    
    double discount = 0;
    
    switch (discountType) {
      case DiscountType.percentage:
        discount = subtotal * (discountValue / 100);
        // Apply max discount cap if set
        if (maxDiscountAmount != null && discount > maxDiscountAmount!) {
          discount = maxDiscountAmount!;
        }
        break;
      case DiscountType.fixedAmount:
        discount = discountValue;
        // Don't discount more than the subtotal
        if (discount > subtotal) discount = subtotal;
        break;
      case DiscountType.freeDelivery:
        // Free delivery is handled separately (returns 0 here)
        discount = 0;
        break;
    }
    
    return discount;
  }

  /// Get a human-readable discount description
  String get discountDescription {
    switch (discountType) {
      case DiscountType.percentage:
        return '${discountValue.toInt()}% off';
      case DiscountType.fixedAmount:
        return 'RM${discountValue.toStringAsFixed(2)} off';
      case DiscountType.freeDelivery:
        return 'Free Delivery';
    }
  }

  PromoCode copyWith({
    String? id,
    String? code,
    String? description,
    DiscountType? discountType,
    double? discountValue,
    double? minOrderAmount,
    double? maxDiscountAmount,
    int? usageLimit,
    int? usageCount,
    int? perUserLimit,
    DateTime? validFrom,
    DateTime? validUntil,
    bool? isActive,
    List<String>? applicableCategories,
    DateTime? createdAt,
    String? userId,
    bool? isPersonal,
    int? pointsCost,
  }) {
    return PromoCode(
      id: id ?? this.id,
      code: code ?? this.code,
      description: description ?? this.description,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      maxDiscountAmount: maxDiscountAmount ?? this.maxDiscountAmount,
      usageLimit: usageLimit ?? this.usageLimit,
      usageCount: usageCount ?? this.usageCount,
      perUserLimit: perUserLimit ?? this.perUserLimit,
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
      isActive: isActive ?? this.isActive,
      applicableCategories: applicableCategories ?? this.applicableCategories,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      isPersonal: isPersonal ?? this.isPersonal,
      pointsCost: pointsCost ?? this.pointsCost,
    );
  }

  factory PromoCode.fromMap(Map<String, dynamic> map, {String? docId}) {
    // Parse dates
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      return null;
    }

    // Parse discount type
    DiscountType parseDiscountType(dynamic value) {
      if (value is String) {
        switch (value) {
          case 'percentage':
            return DiscountType.percentage;
          case 'fixedAmount':
            return DiscountType.fixedAmount;
          case 'freeDelivery':
            return DiscountType.freeDelivery;
        }
      }
      return DiscountType.percentage;
    }

    return PromoCode(
      // Prioritize docId over map id, since map id might be empty string
      id: docId ?? (map['id'] as String?) ?? '',
      code: (map['code'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      discountType: parseDiscountType(map['discountType']),
      discountValue: (map['discountValue'] as num?)?.toDouble() ?? 0,
      minOrderAmount: (map['minOrderAmount'] as num?)?.toDouble(),
      maxDiscountAmount: (map['maxDiscountAmount'] as num?)?.toDouble(),
      usageLimit: (map['usageLimit'] as num?)?.toInt(),
      usageCount: (map['usageCount'] as num?)?.toInt() ?? 0,
      perUserLimit: (map['perUserLimit'] as num?)?.toInt(),
      validFrom: parseDate(map['validFrom']),
      validUntil: parseDate(map['validUntil']),
      isActive: (map['isActive'] as bool?) ?? true,
      applicableCategories: (map['applicableCategories'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      createdAt: parseDate(map['createdAt']) ?? DateTime.now(),
      userId: map['userId'] as String?,
      isPersonal: (map['isPersonal'] as bool?) ?? false,
      pointsCost: (map['pointsCost'] as num?)?.toInt(),
    );
  }

  factory PromoCode.fromDocument(DocumentSnapshot doc) {
    final data = doc.data();
    if (data is Map<String, dynamic>) {
      return PromoCode.fromMap(data, docId: doc.id);
    }
    return PromoCode(
      id: doc.id,
      code: '',
      description: '',
      discountType: DiscountType.percentage,
      discountValue: 0,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code.toUpperCase(),
      'description': description,
      'discountType': discountType.name,
      'discountValue': discountValue,
      if (minOrderAmount != null) 'minOrderAmount': minOrderAmount,
      if (maxDiscountAmount != null) 'maxDiscountAmount': maxDiscountAmount,
      if (usageLimit != null) 'usageLimit': usageLimit,
      'usageCount': usageCount,
      if (perUserLimit != null) 'perUserLimit': perUserLimit,
      if (validFrom != null) 'validFrom': Timestamp.fromDate(validFrom!),
      if (validUntil != null) 'validUntil': Timestamp.fromDate(validUntil!),
      'isActive': isActive,
      if (applicableCategories != null) 'applicableCategories': applicableCategories,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  @override
  String toString() {
    return 'PromoCode(code: $code, discount: $discountDescription, valid: $isValid)';
  }
}

/// Model to track user's promo code usage
class PromoCodeUsage {
  final String id;
  final String promoCodeId;
  final String userId;
  final String orderId;
  final double discountApplied;
  final DateTime usedAt;

  const PromoCodeUsage({
    required this.id,
    required this.promoCodeId,
    required this.userId,
    required this.orderId,
    required this.discountApplied,
    required this.usedAt,
  });

  factory PromoCodeUsage.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return PromoCodeUsage(
      id: (map['id'] as String?) ?? docId ?? '',
      promoCodeId: (map['promoCodeId'] as String?) ?? '',
      userId: (map['userId'] as String?) ?? '',
      orderId: (map['orderId'] as String?) ?? '',
      discountApplied: (map['discountApplied'] as num?)?.toDouble() ?? 0,
      usedAt: parseDate(map['usedAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'promoCodeId': promoCodeId,
      'userId': userId,
      'orderId': orderId,
      'discountApplied': discountApplied,
      'usedAt': Timestamp.fromDate(usedAt),
    };
  }
}
