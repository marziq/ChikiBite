import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/promo_code.dart';

/// Result of validating a promo code
class PromoCodeValidationResult {
  final bool isValid;
  final String? errorMessage;
  final PromoCode? promoCode;
  final double discountAmount;

  const PromoCodeValidationResult({
    required this.isValid,
    this.errorMessage,
    this.promoCode,
    this.discountAmount = 0,
  });

  factory PromoCodeValidationResult.success(PromoCode promoCode, double discountAmount) {
    return PromoCodeValidationResult(
      isValid: true,
      promoCode: promoCode,
      discountAmount: discountAmount,
    );
  }

  factory PromoCodeValidationResult.error(String message) {
    return PromoCodeValidationResult(
      isValid: false,
      errorMessage: message,
    );
  }
}

/// Service for promo code operations with Firestore
class PromoCodeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Collection references
  CollectionReference<Map<String, dynamic>> get _promoCodesCollection =>
      _firestore.collection('promoCodes');

  CollectionReference<Map<String, dynamic>> get _promoUsageCollection =>
      _firestore.collection('promoCodeUsage');

  /// Create a new promo code
  Future<String> createPromoCode(PromoCode promoCode) async {
    try {
      final docRef = await _promoCodesCollection.add(promoCode.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create promo code: $e');
    }
  }

  /// Get promo code by code string
  Future<PromoCode?> getPromoCodeByCode(String code) async {
    try {
      final querySnapshot = await _promoCodesCollection
          .where('code', isEqualTo: code.toUpperCase())
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return PromoCode.fromDocument(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get promo code: $e');
    }
  }

  /// Get promo code by ID
  Future<PromoCode?> getPromoCodeById(String id) async {
    try {
      final doc = await _promoCodesCollection.doc(id).get();
      if (doc.exists) {
        return PromoCode.fromDocument(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get promo code: $e');
    }
  }

  /// Get all active promo codes
  Stream<List<PromoCode>> getActivePromoCodes() {
    return _promoCodesCollection
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PromoCode.fromDocument(doc))
            .where((promo) => promo.isValid)
            .toList());
  }

  /// Get all promo codes (for admin)
  Stream<List<PromoCode>> getAllPromoCodes() {
    return _promoCodesCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PromoCode.fromDocument(doc)).toList());
  }

  /// Check how many times a user has used a specific promo code
  Future<int> getUserUsageCount(String promoCodeId, String userId) async {
    try {
      final querySnapshot = await _promoUsageCollection
          .where('promoCodeId', isEqualTo: promoCodeId)
          .where('userId', isEqualTo: userId)
          .get();
      return querySnapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  /// Validate a promo code for a user and order subtotal
  Future<PromoCodeValidationResult> validatePromoCode({
    required String code,
    required String userId,
    required double subtotal,
  }) async {
    try {
      // Find the promo code
      final promoCode = await getPromoCodeByCode(code);

      if (promoCode == null) {
        return PromoCodeValidationResult.error('Invalid promo code');
      }

      // Check if promo is active
      if (!promoCode.isActive) {
        return PromoCodeValidationResult.error('This promo code is no longer active');
      }

      // Check date validity
      final now = DateTime.now();
      if (promoCode.validFrom != null && now.isBefore(promoCode.validFrom!)) {
        return PromoCodeValidationResult.error('This promo code is not yet valid');
      }
      if (promoCode.validUntil != null && now.isAfter(promoCode.validUntil!)) {
        return PromoCodeValidationResult.error('This promo code has expired');
      }

      // Check global usage limit
      if (promoCode.usageLimit != null && 
          promoCode.usageCount >= promoCode.usageLimit!) {
        return PromoCodeValidationResult.error('This promo code has reached its usage limit');
      }

      // Check per-user usage limit
      if (promoCode.perUserLimit != null) {
        final userUsageCount = await getUserUsageCount(promoCode.id, userId);
        if (userUsageCount >= promoCode.perUserLimit!) {
          return PromoCodeValidationResult.error(
            'You have already used this promo code the maximum number of times'
          );
        }
      }

      // Check minimum order amount
      if (promoCode.minOrderAmount != null && 
          subtotal < promoCode.minOrderAmount!) {
        return PromoCodeValidationResult.error(
          'Minimum order of RM${promoCode.minOrderAmount!.toStringAsFixed(2)} required'
        );
      }

      // Calculate discount
      final discount = promoCode.calculateDiscount(subtotal);

      return PromoCodeValidationResult.success(promoCode, discount);
    } catch (e) {
      return PromoCodeValidationResult.error('Failed to validate promo code');
    }
  }

  /// Record promo code usage and increment usage count
  Future<void> recordPromoUsage({
    required String promoCodeId,
    required String userId,
    required String orderId,
    required double discountApplied,
  }) async {
    try {
      // Create usage record
      final usage = PromoCodeUsage(
        id: '',
        promoCodeId: promoCodeId,
        userId: userId,
        orderId: orderId,
        discountApplied: discountApplied,
        usedAt: DateTime.now(),
      );
      await _promoUsageCollection.add(usage.toMap());

      // Increment usage count on promo code
      await _promoCodesCollection.doc(promoCodeId).update({
        'usageCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to record promo usage: $e');
    }
  }

  /// Update promo code
  Future<void> updatePromoCode(String id, Map<String, dynamic> updates) async {
    try {
      await _promoCodesCollection.doc(id).update(updates);
    } catch (e) {
      throw Exception('Failed to update promo code: $e');
    }
  }

  /// Deactivate promo code
  Future<void> deactivatePromoCode(String id) async {
    await updatePromoCode(id, {'isActive': false});
  }

  /// Delete promo code
  Future<void> deletePromoCode(String id) async {
    try {
      await _promoCodesCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete promo code: $e');
    }
  }

  /// Seed initial promo codes (for demo/testing)
  Future<void> seedPromoCodes() async {
    try {
      // Check if promo codes already exist
      final existing = await _promoCodesCollection.limit(1).get();
      if (existing.docs.isNotEmpty) {
        return; // Already seeded
      }

      final now = DateTime.now();
      final oneYearLater = now.add(const Duration(days: 365));

      final promoCodesData = [
        PromoCode(
          id: '',
          code: 'WELCOME10',
          description: 'Welcome discount! 10% off your first order',
          discountType: DiscountType.percentage,
          discountValue: 10,
          minOrderAmount: 15.00,
          maxDiscountAmount: 20.00,
          perUserLimit: 1,
          validUntil: oneYearLater,
          isActive: true,
          createdAt: now,
        ),
        PromoCode(
          id: '',
          code: 'SAVE5',
          description: 'Save RM5 on your order',
          discountType: DiscountType.fixedAmount,
          discountValue: 5,
          minOrderAmount: 25.00,
          usageLimit: 100,
          isActive: true,
          createdAt: now,
        ),
        PromoCode(
          id: '',
          code: 'FREEDELIVERY',
          description: 'Free delivery on orders above RM30',
          discountType: DiscountType.freeDelivery,
          discountValue: 0,
          minOrderAmount: 30.00,
          isActive: true,
          createdAt: now,
        ),
        PromoCode(
          id: '',
          code: 'CHIKI20',
          description: 'Special: 20% off up to RM15',
          discountType: DiscountType.percentage,
          discountValue: 20,
          minOrderAmount: 20.00,
          maxDiscountAmount: 15.00,
          usageLimit: 50,
          isActive: true,
          createdAt: now,
        ),
        PromoCode(
          id: '',
          code: 'NEWYEAR',
          description: 'New Year Special: RM10 off',
          discountType: DiscountType.fixedAmount,
          discountValue: 10,
          minOrderAmount: 40.00,
          validUntil: oneYearLater,
          isActive: true,
          createdAt: now,
        ),
      ];

      for (final promo in promoCodesData) {
        await createPromoCode(promo);
      }
    } catch (e) {
      // Silently fail seeding
    }
  }
}

/// Global instance of PromoCodeService
final promoCodeService = PromoCodeService();
