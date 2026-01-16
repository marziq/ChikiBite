import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/voucher.dart';
import 'profile_service.dart';

/// Service for managing vouchers
class VoucherService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Collection reference for vouchers
  CollectionReference<Map<String, dynamic>> get _vouchersCollection =>
      _firestore.collection('vouchers');

  /// Redeem points for a voucher
  Future<Voucher?> redeemPoints({
    required String userId,
    required RedemptionOption option,
  }) async {
    try {
      // Check if user has enough points
      final currentPoints = await profileService.getPointsBalance(userId);
      if (currentPoints < option.pointsCost) {
        return null; // Not enough points
      }

      // Deduct points
      final success = await profileService.deductPoints(
        userId,
        option.pointsCost,
        reason: 'Redeemed: ${option.name}',
      );

      if (!success) {
        return null;
      }

      // Create voucher
      final now = DateTime.now();
      final voucher = Voucher(
        id: '',
        userId: userId,
        name: option.name,
        description: option.description,
        type: option.type,
        itemCategory: option.itemCategory,
        discountValue: option.discountValue,
        pointsCost: option.pointsCost,
        status: VoucherStatus.available,
        createdAt: now,
        expiresAt: now.add(const Duration(days: 30)), // Valid for 30 days
      );

      // Save to Firestore
      final docRef = await _vouchersCollection.add(voucher.toMap());

      return voucher.copyWith(id: docRef.id);
    } catch (e) {
      return null;
    }
  }

  /// Get user's available vouchers
  Stream<List<Voucher>> getUserVouchers(String userId) {
    return _vouchersCollection
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'available')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Voucher.fromDocument(doc))
            .where((v) => v.isValid)
            .toList());
  }

  /// Get all user vouchers (including used)
  Future<List<Voucher>> getAllUserVouchers(String userId) async {
    try {
      final snapshot = await _vouchersCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => Voucher.fromDocument(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get vouchers applicable to a cart category
  Future<List<Voucher>> getApplicableVouchers({
    required String userId,
    List<String>? cartCategories,
  }) async {
    try {
      final snapshot = await _vouchersCollection
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'available')
          .get();

      final vouchers = snapshot.docs
          .map((doc) => Voucher.fromDocument(doc))
          .where((v) => v.isValid)
          .toList();

      // Filter by category if needed
      if (cartCategories == null || cartCategories.isEmpty) {
        return vouchers;
      }

      return vouchers.where((v) {
        if (v.type != VoucherType.freeItem) return true; // Discounts apply to all
        if (v.itemCategory == null) return true; // No category restriction
        return cartCategories.contains(v.itemCategory);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Mark voucher as used
  Future<bool> useVoucher(String voucherId, String orderId) async {
    try {
      await _vouchersCollection.doc(voucherId).update({
        'status': 'used',
        'usedAt': Timestamp.fromDate(DateTime.now()),
        'usedOnOrderId': orderId,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get voucher by ID
  Future<Voucher?> getVoucher(String voucherId) async {
    try {
      final doc = await _vouchersCollection.doc(voucherId).get();
      if (doc.exists) {
        return Voucher.fromDocument(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Count available vouchers for user
  Future<int> getAvailableVoucherCount(String userId) async {
    try {
      final snapshot = await _vouchersCollection
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'available')
          .get();
      return snapshot.docs
          .map((doc) => Voucher.fromDocument(doc))
          .where((v) => v.isValid)
          .length;
    } catch (e) {
      return 0;
    }
  }
}

/// Global instance
final voucherService = VoucherService();
