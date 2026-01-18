import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItem {
  final String itemID;
  final String name;
  final String description;
  final double price;
  final String imagePath;
  final String category;
  final List<String> ingredients;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;

  const MenuItem({
    required this.itemID,
    required this.name,
    required this.description,
    required this.price,
    required this.imagePath,
    required this.category,
    this.ingredients = const [],
    this.calories = 450,
    this.protein = 25,
    this.fat = 18,
    this.carbs = 42,
  });

  MenuItem copyWith({
    String? itemID,
    String? name,
    String? description,
    double? price,
    String? imagePath,
    String? category,
    List<String>? ingredients,
    double? calories,
    double? protein,
    double? fat,
    double? carbs,
  }) {
    return MenuItem(
      itemID: itemID ?? this.itemID,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imagePath: imagePath ?? this.imagePath,
      category: category ?? this.category,
      ingredients: ingredients ?? this.ingredients,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      carbs: carbs ?? this.carbs,
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
      ingredients: (map['ingredients'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      calories: (map['calories'] as num?)?.toDouble() ?? 450,
      protein: (map['protein'] as num?)?.toDouble() ?? 25,
      fat: (map['fat'] as num?)?.toDouble() ?? 18,
      carbs: (map['carbs'] as num?)?.toDouble() ?? 42,
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
      ingredients: [],
      calories: 450,
      protein: 25,
      fat: 18,
      carbs: 42,
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
      'ingredients': ingredients,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
    };
  }

  @override
  String toString() {
    return 'MenuItem(itemID: $itemID, name: $name, price: $price)';
  }
}
