class MenuItem {
  final String name;
  final String description;
  final String category;
  final double price;
  final String imagePath;

  MenuItem({
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.imagePath,
  });
}

final List<MenuItem> menuItems = [
  MenuItem(
    name: 'Chicken Burger',
    description:
        'Juicy crispy chicken patty with fresh lettuce, tomato, and creamy mayo in a toasted bun.',
    category: 'Burgers',
    price: 8.50,
    imagePath: 'assets/img/chicken-burger.jpg',
  ),
  MenuItem(
    name: 'Spicy Chicken Burger',
    description:
        'Extra crispy chicken coated in spicy seasoning, topped with spicy sauce for a bold kick.',
    category: 'Burgers',
    price: 9.50,
    imagePath: 'assets/img/spicy-chicken-burger.jpg',
  ),
  MenuItem(
    name: 'Triple Cheesy Burger',
    description:
        'Crispy chicken fillet layered with three types of cheese and smoky sauce.',
    category: 'Burgers',
    price: 12.50,
    imagePath: 'assets/img/triple-cheesy-burger.jpg',
  ),
  MenuItem(
    name: 'Mushroom Chicken Burger',
    description:
        'Grilled chicken fillet glazed with mushroom sauce, paired with grilled mushroom',
    category: 'Burgers',
    price: 15.80,
    imagePath: 'assets/img/mushroom-burger.jpg',
  ),
  MenuItem(
    name: 'ChickZilla Burger',
    description:
        'Two layers of crispy chicken patties stacked with cheese and special house sauce.',
    category: 'Burgers',
    price: 17.80,
    imagePath: 'assets/img/chickzilla-burger.jpg',
  ),
  MenuItem(
    name: '2-Piece Crispy Chicken',
    description:
        'Golden fried chicken pieces seasoned with ChikiBite\'s signature spice.',
    category: 'Chickens',
    price: 8.00,
    imagePath: 'assets/img/2-Piece Crispy Chicken.png',
  ),
  MenuItem(
    name: '2-Piece Ghost Pepper Glazed Chicken',
    description:
        'Crispy fried chicken with a spicy coating of ghost pepper for heat lovers.',
    category: 'Chickens',
    price: 10.50,
    imagePath: 'assets/img/2- Piece Ghost Pepper Glazed Chicken.png',
  ),
  MenuItem(
    name: 'Chicken Tenders (5 Pcs)',
    description:
        'Tender chicken strips fried to perfection, served with dipping sauce.',
    category: 'Chickens',
    price: 12.00,
    imagePath: 'assets/img/Chicken Tenders (5 Pcs).png',
  ),
  MenuItem(
    name: 'Chicken Bucket Deluxe (10 Pcs)',
    description: 'Fill entire bucket with your favourite type of fried chicken',
    category: 'Chickens',
    price: 89.90,
    imagePath: 'assets/img/Chicken Bucket Deluxe (10 Pcs).png',
  ),
  MenuItem(
    name: 'Chocolate Lava Cake',
    description: 'Warm chocolate cake with a gooey molten center.',
    category: 'Desserts',
    price: 6.50,
    imagePath: 'assets/img/Chocolate Lava Cake.png',
  ),
  MenuItem(
    name: 'Cheesecake Slice',
    description: 'Creamy cheesecake with a buttery biscuit base.',
    category: 'Desserts',
    price: 6.00,
    imagePath: 'assets/img/Cheesecake Slice.png',
  ),
  MenuItem(
    name: 'Vanilla Ice Cream Cup',
    description: 'Classic vanilla ice cream served chilled and smooth.',
    category: 'Desserts',
    price: 4.00,
    imagePath: 'assets/img/Vanilla Ice Cream Cup.png',
  ),
  MenuItem(
    name: 'Iced Lemon Tea',
    description: 'Refreshing lemon tea served cold with ice.',
    category: 'Drinks',
    price: 3.50,
    imagePath: 'assets/img/Iced Lemon Tea.png',
  ),
  MenuItem(
    name: 'Coca Cola',
    description: 'Chilled fizzy cola to complement your meal.',
    category: 'Drinks',
    price: 3.00,
    imagePath: 'assets/img/Coca Cola.png',
  ),
  MenuItem(
    name: 'Chocolate Milkshake',
    description: 'Creamy chocolate milkshake topped with chocolate drizzle.',
    category: 'Drinks',
    price: 5.50,
    imagePath: 'assets/img/Chocolate Milkshake.png',
  ),
  MenuItem(
    name: 'Strawberry Milkshake',
    description: 'Smooth strawberry milkshake made with fresh strawberries.',
    category: 'Drinks',
    price: 5.50,
    imagePath: 'assets/img/Strawberry Milkshake.png',
  ),
  MenuItem(
    name: 'Chicken Nugget (9 Pcs)',
    description: 'Bite-sized chicken nuggets, fried crispy and juicy inside.',
    category: 'Snacks',
    price: 9.50,
    imagePath: 'assets/img/Chicken Nugget  (9 Pcs).png',
  ),
  MenuItem(
    name: 'French Fries',
    description: 'Crispy golden fries lightly salted and served hot.',
    category: 'Snacks',
    price: 4.50,
    imagePath: 'assets/img/French Fries.png',
  ),
  MenuItem(
    name: 'Cheesy Fries',
    description: 'French fries topped with melted cheese sauce.',
    category: 'Snacks',
    price: 6.00,
    imagePath: 'assets/img/Cheesy Fries.png',
  ),
  MenuItem(
    name: 'Onion Rings',
    description: 'Crunchy battered onion rings fried until golden brown.',
    category: 'Snacks',
    price: 7.00,
    imagePath: 'assets/img/Onion Rings.png',
  ),
  MenuItem(
    name: 'Mashed Potato Bowl',
    description: 'Creamy mashed potatoes topped with rich gravy.',
    category: 'Snacks',
    price: 5.00,
    imagePath: 'assets/img/Mashed Potato Bowl.png',
  ),
];
