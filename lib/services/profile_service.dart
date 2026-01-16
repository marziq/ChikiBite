import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as app_user;
import 'auth_service.dart';

class ProfileService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Create a new user profile document in Firestore on registration
  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
    String? phone,
  }) async {
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'points': 0,
      'addresses': [],
      'favoriteItems': [],
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Get current user profile
  Stream<app_user.User?> getUserProfile(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return app_user.User.fromMap(doc.data()!, docId: doc.id);
      }
      return null;
    });
  }

  // Get user profile once
  Future<app_user.User?> getUserProfileOnce(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return app_user.User.fromMap(doc.data()!, docId: doc.id);
    }
    return null;
  }

  // Update user profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  // Update personal information
  Future<void> updatePersonalInfo({
    required String uid,
    String? name,
    String? phone,
    String? photoUrl,
  }) async {
    final Map<String, dynamic> updates = {};
    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;

    if (updates.isNotEmpty) {
      await updateUserProfile(uid, updates);

      // Also update Firebase Auth display name if name changed
      if (name != null) {
        await AuthService.updateDisplayName(name);
      }
    }
  }

  // Add delivery address
  Future<void> addAddress(String uid, Map<String, dynamic> address) async {
    final user = await getUserProfileOnce(uid);
    final addresses = user?.addresses ?? [];

    // Mark as default if it's the first address
    final newAddress = {
      ...address,
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'isDefault': addresses.isEmpty,
    };

    addresses.add(newAddress);
    await updateUserProfile(uid, {'addresses': addresses});
  }

  // Update delivery address
  Future<void> updateAddress(
    String uid,
    String addressId,
    Map<String, dynamic> updatedAddress,
  ) async {
    final user = await getUserProfileOnce(uid);
    final addresses = user?.addresses ?? [];

    final index = addresses.indexWhere((addr) => addr['id'] == addressId);
    if (index != -1) {
      addresses[index] = {
        ...addresses[index],
        ...updatedAddress,
        'id': addressId,
      };
      await updateUserProfile(uid, {'addresses': addresses});
    }
  }

  // Delete delivery address
  Future<void> deleteAddress(String uid, String addressId) async {
    final user = await getUserProfileOnce(uid);
    final addresses = user?.addresses ?? [];

    addresses.removeWhere((addr) => addr['id'] == addressId);

    // If we deleted the default address, set another as default
    if (addresses.isNotEmpty &&
        !addresses.any((addr) => addr['isDefault'] == true)) {
      addresses[0]['isDefault'] = true;
    }

    await updateUserProfile(uid, {'addresses': addresses});
  }

  // Set default address
  Future<void> setDefaultAddress(String uid, String addressId) async {
    final user = await getUserProfileOnce(uid);
    final addresses = user?.addresses ?? [];

    for (var addr in addresses) {
      addr['isDefault'] = addr['id'] == addressId;
    }

    await updateUserProfile(uid, {'addresses': addresses});
  }

  // Add payment method
  Future<void> addPaymentMethod(
    String uid,
    Map<String, dynamic> paymentMethod,
  ) async {
    final user = await getUserProfileOnce(uid);
    final methods = user?.paymentMethods ?? [];

    final newMethod = {
      ...paymentMethod,
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'isDefault': methods.isEmpty,
    };

    methods.add(newMethod);
    await updateUserProfile(uid, {'paymentMethods': methods});
  }

  // Update payment method
  Future<void> updatePaymentMethod(
    String uid,
    String methodId,
    Map<String, dynamic> updatedMethod,
  ) async {
    final user = await getUserProfileOnce(uid);
    final methods = user?.paymentMethods ?? [];

    final index = methods.indexWhere((method) => method['id'] == methodId);
    if (index != -1) {
      methods[index] = {...methods[index], ...updatedMethod, 'id': methodId};
      await updateUserProfile(uid, {'paymentMethods': methods});
    }
  }

  // Delete payment method
  Future<void> deletePaymentMethod(String uid, String methodId) async {
    final user = await getUserProfileOnce(uid);
    final methods = user?.paymentMethods ?? [];

    methods.removeWhere((method) => method['id'] == methodId);

    // If we deleted the default method, set another as default
    if (methods.isNotEmpty &&
        !methods.any((method) => method['isDefault'] == true)) {
      methods[0]['isDefault'] = true;
    }

    await updateUserProfile(uid, {'paymentMethods': methods});
  }

  // Set default payment method
  Future<void> setDefaultPaymentMethod(String uid, String methodId) async {
    final user = await getUserProfileOnce(uid);
    final methods = user?.paymentMethods ?? [];

    for (var method in methods) {
      method['isDefault'] = method['id'] == methodId;
    }

    await updateUserProfile(uid, {'paymentMethods': methods});
  }

  // Add favorite item
  Future<void> addFavorite(String uid, String itemId) async {
    await _db.collection('users').doc(uid).update({
      'favoriteItems': FieldValue.arrayUnion([itemId]),
    });
  }

  // Remove favorite item
  Future<void> removeFavorite(String uid, String itemId) async {
    await _db.collection('users').doc(uid).update({
      'favoriteItems': FieldValue.arrayRemove([itemId]),
    });
  }

  // Toggle favorite
  Future<void> toggleFavorite(String uid, String itemId) async {
    final user = await getUserProfileOnce(uid);
    final favorites = user?.favoriteItems ?? [];

    if (favorites.contains(itemId)) {
      await removeFavorite(uid, itemId);
    } else {
      await addFavorite(uid, itemId);
    }
  }

  // Update notification settings
  Future<void> updateNotificationSettings(
    String uid,
    Map<String, bool> settings,
  ) async {
    await updateUserProfile(uid, {'notificationSettings': settings});
  }

  // Update language
  Future<void> updateLanguage(String uid, String language) async {
    await updateUserProfile(uid, {'language': language});
  }

  // ============== Points Management ==============

  /// Add points to user account (e.g., after order completion)
  /// RM1 = 1 point
  Future<void> addPoints(String uid, int points, {String? reason}) async {
    if (points <= 0) return;
    
    await _db.collection('users').doc(uid).update({
      'points': FieldValue.increment(points),
    });

    // Record points transaction for history
    await _db.collection('users').doc(uid).collection('pointsHistory').add({
      'type': 'earned',
      'amount': points,
      'reason': reason ?? 'Order purchase',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Deduct points from user account (e.g., for redemption)
  Future<bool> deductPoints(String uid, int points, {String? reason}) async {
    if (points <= 0) return false;

    // Check if user has enough points
    final user = await getUserProfileOnce(uid);
    final currentPoints = user?.points ?? 0;
    
    if (currentPoints < points) {
      return false; // Not enough points
    }

    await _db.collection('users').doc(uid).update({
      'points': FieldValue.increment(-points),
    });

    // Record points transaction for history
    await _db.collection('users').doc(uid).collection('pointsHistory').add({
      'type': 'redeemed',
      'amount': -points,
      'reason': reason ?? 'Points redemption',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return true;
  }

  /// Get current points balance
  Future<int> getPointsBalance(String uid) async {
    final user = await getUserProfileOnce(uid);
    return user?.points ?? 0;
  }

  /// Get points history stream
  Stream<List<Map<String, dynamic>>> getPointsHistory(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('pointsHistory')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList());
  }

  /// Calculate points for an order total (RM1 = 1 point)
  static int calculatePointsForOrder(double orderTotal) {
    return orderTotal.floor(); // Round down to nearest RM
  }
}

// Singleton instance
final profileService = ProfileService();

