import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Users ---
  Future<void> addUser(String uid, Map<String, dynamic> data) {
    return _db.collection('users').doc(uid).set({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<DocumentSnapshot> getUser(String uid) {
    return _db.collection('users').doc(uid).get();
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) {
    return _db.collection('users').doc(uid).update(data);
  }

  // --- Menu ---
  Future<DocumentReference> addMenuItem(Map<String, dynamic> item) {
    return _db.collection('menu').add({
      ...item,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateMenuItem(String id, Map<String, dynamic> data) {
    return _db.collection('menu').doc(id).update(data);
  }

  Stream<QuerySnapshot> menuStream({bool onlyAvailable = true}) {
    final coll = _db.collection('menu');
    if (onlyAvailable) {
      return coll.where('available', isEqualTo: true).snapshots();
    }
    return coll.snapshots();
  }

  // --- Orders ---
  Future<DocumentReference> placeOrder(Map<String, dynamic> order) {
    return _db.collection('orders').add({
      ...order,
      'createdAt': FieldValue.serverTimestamp(),
      'status': order['status'] ?? 'pending',
    });
  }

  Stream<QuerySnapshot> ordersForUser(String uid) {
    return _db
        .collection('orders')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> updateOrderStatus(String orderId, String status) {
    return _db.collection('orders').doc(orderId).update({'status': status});
  }

  // --- Helpers ---
  Future<void> runTransaction(
    Future<void> Function(Transaction tx) transactionHandler,
  ) {
    return _db.runTransaction(transactionHandler);
  }

  Future<void> batchWrite(List<Function(WriteBatch)> writes) async {
    final batch = _db.batch();
    for (final w in writes) {
      w(batch);
    }
    return batch.commit();
  }
}

// Simple singleton for easy use across the app
final firestoreService = FirestoreService();
