import 'package:cloud_firestore/cloud_firestore.dart';

/// Sample menu data for populating Firestore
final List<Map<String, dynamic>> sampleMenuItems = [
  {
    'name': 'Crispy Chicken Burger',
    'description': 'Golden fried chicken with lettuce, tomato, and mayo',
    'price': 12.99,
    'imageUrl': 'https://via.placeholder.com/300x300?text=Chicken+Burger',
    'categoryId': 'burgers',
    'sizes': ['Regular', 'Large'],
    'extras': ['Cheese +RM1', 'Bacon +RM1.50', 'Extra Sauce'],
    'available': true,
  },
  {
    'name': 'Spicy Beef Burger',
    'description': 'Juicy beef patty with jalapeños and sriracha mayo',
    'price': 14.99,
    'imageUrl': 'https://via.placeholder.com/300x300?text=Beef+Burger',
    'categoryId': 'burgers',
    'sizes': ['Regular', 'Large'],
    'extras': ['Cheese +RM1', 'Bacon +RM1.50', 'Extra Sauce'],
    'available': true,
  },
  {
    'name': 'Classic Cheeseburger',
    'description': 'Beef patty with melted cheddar cheese and pickles',
    'price': 10.99,
    'imageUrl': 'https://via.placeholder.com/300x300?text=Cheeseburger',
    'categoryId': 'burgers',
    'sizes': ['Regular', 'Large'],
    'extras': ['Bacon +RM1.50', 'Extra Cheese +RM1'],
    'available': true,
  },
  {
    'name': 'Grilled Chicken Wrap',
    'description': 'Tender grilled chicken with fresh vegetables in a tortilla',
    'price': 11.99,
    'imageUrl': 'https://via.placeholder.com/300x300?text=Chicken+Wrap',
    'categoryId': 'wraps',
    'sizes': ['Regular', 'Large'],
    'extras': ['Cheese', 'Extra Veggies'],
    'available': true,
  },
  {
    'name': 'Veggie Delight Wrap',
    'description': 'Mixed vegetables with hummus and tahini dressing',
    'price': 9.99,
    'imageUrl': 'https://via.placeholder.com/300x300?text=Veggie+Wrap',
    'categoryId': 'wraps',
    'sizes': ['Regular', 'Large'],
    'extras': ['Extra Hummus', 'Feta Cheese +RM1'],
    'available': true,
  },
  {
    'name': 'Crispy Fries',
    'description': 'Golden crispy fried potatoes with sea salt',
    'price': 4.99,
    'imageUrl': 'https://via.placeholder.com/300x300?text=Fries',
    'categoryId': 'sides',
    'sizes': ['Small', 'Medium', 'Large'],
    'extras': ['Cheese Sauce', 'BBQ Sauce', 'Curry Sauce'],
    'available': true,
  },
  {
    'name': 'Onion Rings',
    'description': 'Crispy battered onion rings with dipping sauce',
    'price': 5.99,
    'imageUrl': 'https://via.placeholder.com/300x300?text=Onion+Rings',
    'categoryId': 'sides',
    'sizes': ['Small', 'Medium', 'Large'],
    'extras': ['Ranch Dip', 'Spicy Dip'],
    'available': true,
  },
  {
    'name': 'Iced Lemonade',
    'description': 'Refreshing fresh-squeezed lemonade with ice',
    'price': 3.99,
    'imageUrl': 'https://via.placeholder.com/300x300?text=Lemonade',
    'categoryId': 'drinks',
    'sizes': ['Small', 'Medium', 'Large'],
    'extras': [],
    'available': true,
  },
  {
    'name': 'Chocolate Milkshake',
    'description': 'Creamy vanilla ice cream blended with chocolate syrup',
    'price': 6.99,
    'imageUrl': 'https://via.placeholder.com/300x300?text=Milkshake',
    'categoryId': 'drinks',
    'sizes': ['Regular', 'Large'],
    'extras': ['Whipped Cream', 'Extra Syrup'],
    'available': true,
  },
  {
    'name': 'Chocolate Cake',
    'description': 'Rich chocolate cake with frosting',
    'price': 7.99,
    'imageUrl': 'https://via.placeholder.com/300x300?text=Chocolate+Cake',
    'categoryId': 'desserts',
    'sizes': ['Single', 'Double'],
    'extras': ['Ice Cream +RM1.50'],
    'available': true,
  },
];

/// Populates Firestore with sample menu data
Future<void> populateSampleMenuData() async {
  final db = FirebaseFirestore.instance;
  final batch = db.batch();

  for (final item in sampleMenuItems) {
    final docRef = db.collection('menu').doc();
    batch.set(docRef, {
      ...item,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  await batch.commit();
  print('✓ Sample menu data added to Firestore');
}

/// Clears all menu items from Firestore (use carefully!)
Future<void> clearMenuData() async {
  final db = FirebaseFirestore.instance;
  final snapshot = await db.collection('menu').get();
  final batch = db.batch();

  for (final doc in snapshot.docs) {
    batch.delete(doc.reference);
  }

  await batch.commit();
  print('✓ Menu data cleared from Firestore');
}

/// Sample users data
final List<Map<String, dynamic>> sampleUsers = [
  {
    'name': 'John Doe',
    'email': 'john@example.com',
    'phone': '+60123456789',
    'points': 150,
    'address': {
      'street': '123 Main St',
      'city': 'Kuala Lumpur',
      'state': 'KL',
      'postalCode': '50050',
    },
  },
  {
    'name': 'Jane Smith',
    'email': 'jane@example.com',
    'phone': '+60198765432',
    'points': 200,
    'address': {
      'street': '456 Oak Ave',
      'city': 'Selangor',
      'state': 'SGL',
      'postalCode': '40000',
    },
  },
];

/// Adds sample user data to Firestore
Future<void> addSampleUser(String uid, int index) async {
  if (index >= sampleUsers.length) return;

  final db = FirebaseFirestore.instance;
  final userData = sampleUsers[index];

  await db.collection('users').doc(uid).set({
    ...userData,
    'createdAt': FieldValue.serverTimestamp(),
  });
  print('✓ Sample user data added for uid: $uid');
}
