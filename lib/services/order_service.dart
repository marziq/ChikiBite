import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart' as app_order;

/// Service for order CRUD operations with Firestore
class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Collection reference for orders
  CollectionReference<Map<String, dynamic>> get _ordersCollection =>
      _firestore.collection('orders');

  /// Create a new order in Firestore
  Future<String> createOrder(app_order.Order order) async {
    try {
      final docRef = await _ordersCollection.add(order.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  /// Get order by ID
  Future<app_order.Order?> getOrder(String orderId) async {
    try {
      final doc = await _ordersCollection.doc(orderId).get();
      if (doc.exists) {
        return app_order.Order.fromDocument(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get order: $e');
    }
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _ordersCollection.doc(orderId).update({'status': status});
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  /// Cancel order (set status to 'cancelled')
  Future<void> cancelOrder(String orderId) async {
    await updateOrderStatus(orderId, 'cancelled');
  }

  /// Get orders stream for a specific user
  Stream<QuerySnapshot> getUserOrdersStream(String userId) {
    return _ordersCollection
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  /// Get active orders stream for a user (pending, preparing, delivering)
  Stream<QuerySnapshot> getActiveOrdersStream(String userId) {
    return _ordersCollection
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  /// Delete order (admin only)
  Future<void> deleteOrder(String orderId) async {
    try {
      await _ordersCollection.doc(orderId).delete();
    } catch (e) {
      throw Exception('Failed to delete order: $e');
    }
  }
}

/// Global instance of OrderService
final orderService = OrderService();
