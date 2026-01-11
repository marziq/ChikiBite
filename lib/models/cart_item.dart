/// Model representing an item in the shopping cart
class CartItem {
  final String itemId;
  final String name;
  final double price;
  final String imagePath;
  int quantity;

  CartItem({
    required this.itemId,
    required this.name,
    required this.price,
    required this.imagePath,
    this.quantity = 1,
  });

  /// Total price for this item (price * quantity)
  double get totalPrice => price * quantity;

  /// Convert to map for order creation
  Map<String, dynamic> toOrderItemMap() {
    return {
      'itemId': itemId,
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }

  @override
  String toString() {
    return 'CartItem(itemId: $itemId, name: $name, qty: $quantity, price: $price)';
  }
}
