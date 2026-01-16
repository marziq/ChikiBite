import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart' as app_order;

/// Service for order CRUD operations with Firestore
class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Track active timers to prevent duplicates
  final Map<String, Timer> _activeTimers = {};
  
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

  /// Get the next status based on current status and order type
  String? _getNextStatus(String currentStatus, bool isPickup) {
    switch (currentStatus.toLowerCase()) {
      case 'pending':
        return 'preparing';
      case 'preparing':
        return isPickup ? 'ready_for_pickup' : 'delivering';
      case 'ready_for_pickup':
      case 'delivering':
        return 'completed';
      default:
        return null; // No next status (already completed or cancelled)
    }
  }

  /// Start automatic status progression for an order
  /// Updates status every [intervalSeconds] seconds (default 10)
  void startAutomaticStatusProgression(
    String orderId, {
    bool isPickup = false,
    int intervalSeconds = 10,
  }) {
    // Cancel any existing timer for this order
    _activeTimers[orderId]?.cancel();
    
    // Start a periodic timer to update status
    _activeTimers[orderId] = Timer.periodic(
      Duration(seconds: intervalSeconds),
      (timer) async {
        try {
          // Get current order status
          final order = await getOrder(orderId);
          if (order == null) {
            timer.cancel();
            _activeTimers.remove(orderId);
            return;
          }

          // Get next status
          final nextStatus = _getNextStatus(order.status, isPickup);
          
          if (nextStatus == null) {
            // Order is completed or cancelled, stop the timer
            timer.cancel();
            _activeTimers.remove(orderId);
            return;
          }

          // Update to next status
          await updateOrderStatus(orderId, nextStatus);
          
          // If completed, stop the timer
          if (nextStatus == 'completed') {
            timer.cancel();
            _activeTimers.remove(orderId);
          }
        } catch (e) {
          // Stop timer on error
          timer.cancel();
          _activeTimers.remove(orderId);
        }
      },
    );
  }

  /// Stop automatic status progression for an order
  void stopAutomaticStatusProgression(String orderId) {
    _activeTimers[orderId]?.cancel();
    _activeTimers.remove(orderId);
  }

  /// Stop all automatic status progressions
  void stopAllAutomaticProgressions() {
    for (final timer in _activeTimers.values) {
      timer.cancel();
    }
    _activeTimers.clear();
  }
}

/// Global instance of OrderService
final orderService = OrderService();

