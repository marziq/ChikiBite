import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String itemId;
  final String name;
  final int quantity;
  final double price;
  final Map<String, String>? options;

  const OrderItem({
    required this.itemId,
    required this.name,
    required this.quantity,
    required this.price,
    this.options,
  });

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'name': name,
      'quantity': quantity,
      'price': price,
      if (options != null) 'options': options,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      itemId: map['itemId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      options: (map['options'] as Map?)?.cast<String, String>(),
    );
  }

  @override
  String toString() {
    return 'OrderItem(itemId: $itemId, name: $name, qty: $quantity)';
  }
}

class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double total;
  final String status; // pending, preparing, delivering, completed, cancelled
  final String deliveryAddress;
  final String paymentMethod;
  final int pointsUsed;
  final DateTime? createdAt;

  const Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.status,
    required this.deliveryAddress,
    required this.paymentMethod,
    this.pointsUsed = 0,
    this.createdAt,
  });

  Order copyWith({
    String? id,
    String? userId,
    List<OrderItem>? items,
    double? total,
    String? status,
    String? deliveryAddress,
    String? paymentMethod,
    int? pointsUsed,
    DateTime? createdAt,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      total: total ?? this.total,
      status: status ?? this.status,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      pointsUsed: pointsUsed ?? this.pointsUsed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Order.fromMap(Map<String, dynamic> map, {String? docId}) {
    final created = map['createdAt'];
    DateTime? createdAt;
    if (created is Timestamp) {
      createdAt = created.toDate();
    } else if (created is String) {
      createdAt = DateTime.tryParse(created);
    } else if (created is int) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(created);
    }

    final itemsList = (map['items'] as List?)
            ?.map((e) => OrderItem.fromMap(e as Map<String, dynamic>))
            .toList() ??
        [];

    return Order(
      id: (map['id'] as String?) ?? docId ?? '',
      userId: map['userId'] as String? ?? '',
      items: itemsList,
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] as String? ?? 'pending',
      deliveryAddress: map['deliveryAddress'] as String? ?? '',
      paymentMethod: map['paymentMethod'] as String? ?? '',
      pointsUsed: (map['pointsUsed'] as num?)?.toInt() ?? 0,
      createdAt: createdAt,
    );
  }

  factory Order.fromDocument(DocumentSnapshot doc) {
    final data = doc.data();
    if (data is Map<String, dynamic>) {
      return Order.fromMap(data, docId: doc.id);
    }
    return Order(
      id: doc.id,
      userId: '',
      items: [],
      total: 0,
      status: 'pending',
      deliveryAddress: '',
      paymentMethod: '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((e) => e.toMap()).toList(),
      'total': total,
      'status': status,
      'deliveryAddress': deliveryAddress,
      'paymentMethod': paymentMethod,
      'pointsUsed': pointsUsed,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    };
  }

  @override
  String toString() {
    return 'Order(id: $id, userId: $userId, total: $total, status: $status)';
  }
}
