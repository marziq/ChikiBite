import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String categoryId;
  final List<String> sizes;
  final List<String> extras;
  final bool available;
  final DateTime? createdAt;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.categoryId,
    this.sizes = const [],
    this.extras = const [],
    this.available = true,
    this.createdAt,
  });

  MenuItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? categoryId,
    List<String>? sizes,
    List<String>? extras,
    bool? available,
    DateTime? createdAt,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      sizes: sizes ?? this.sizes,
      extras: extras ?? this.extras,
      available: available ?? this.available,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory MenuItem.fromMap(Map<String, dynamic> map, {String? docId}) {
    final created = map['createdAt'];
    DateTime? createdAt;
    if (created is Timestamp) {
      createdAt = created.toDate();
    } else if (created is String) {
      createdAt = DateTime.tryParse(created);
    } else if (created is int) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(created);
    }

    return MenuItem(
      id: (map['id'] as String?) ?? docId ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] as String? ?? '',
      categoryId: map['categoryId'] as String? ?? '',
      sizes: List<String>.from(map['sizes'] as List? ?? []),
      extras: List<String>.from(map['extras'] as List? ?? []),
      available: map['available'] as bool? ?? true,
      createdAt: createdAt,
    );
  }

  factory MenuItem.fromDocument(DocumentSnapshot doc) {
    final data = doc.data();
    if (data is Map<String, dynamic>) {
      return MenuItem.fromMap(data, docId: doc.id);
    }
    return MenuItem(
      id: doc.id,
      name: '',
      description: '',
      price: 0,
      imageUrl: '',
      categoryId: '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'sizes': sizes,
      'extras': extras,
      'available': available,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    };
  }

  @override
  String toString() {
    return 'MenuItem(id: $id, name: $name, price: $price, available: $available)';
  }
}
