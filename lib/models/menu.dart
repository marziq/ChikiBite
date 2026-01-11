import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItem {
  final String itemID;
  final String name;
  final String description;
  final double price;
  final String imagePath;
  final String category;

  const MenuItem({
    required this.itemID,
    required this.name,
    required this.description,
    required this.price,
    required this.imagePath,
    required this.category,
  });

  MenuItem copyWith({
    String? itemID,
    String? name,
    String? description,
    double? price,
    String? imagePath,
    String? category,
  }) {
    return MenuItem(
      itemID: itemID ?? this.itemID,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imagePath: imagePath ?? this.imagePath,
      category: category ?? this.category,
    );
  }

  factory MenuItem.fromMap(Map<String, dynamic> map, {String? docId}) {
    return MenuItem(
      itemID: (map['itemID'] as String?) ?? docId ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      imagePath: map['imagePath'] as String? ?? '',
      category: map['category'] as String? ?? '',
    );
  }

  factory MenuItem.fromDocument(DocumentSnapshot doc) {
    final data = doc.data();
    if (data is Map<String, dynamic>) {
      return MenuItem.fromMap(data, docId: doc.id);
    }
    return MenuItem(
      itemID: doc.id,
      name: '',
      description: '',
      price: 0,
      imagePath: '',
      category: '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemID': itemID,
      'name': name,
      'description': description,
      'price': price,
      'imagePath': imagePath,
      'category': category,
    };
  }

  @override
  String toString() {
    return 'MenuItem(itemID: $itemID, name: $name, price: $price)';
  }
}
