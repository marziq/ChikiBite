import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';

/// Cart service using ChangeNotifier for state management
class CartService extends ChangeNotifier {
  final List<CartItem> _items = [];

  /// Get all items in the cart
  List<CartItem> get items => List.unmodifiable(_items);

  /// Get total number of items (sum of quantities)
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  /// Get number of unique items in cart
  int get uniqueItemCount => _items.length;

  /// Check if cart is empty
  bool get isEmpty => _items.isEmpty;

  /// Check if cart is not empty
  bool get isNotEmpty => _items.isNotEmpty;

  /// Calculate subtotal of all items
  double get subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);

  /// Add item to cart or increment quantity if already exists
  void addItem({
    required String itemId,
    required String name,
    required double price,
    required String imagePath,
    int quantity = 1,
  }) {
    // Check if item already exists in cart
    final existingIndex = _items.indexWhere((item) => item.itemId == itemId);

    if (existingIndex >= 0) {
      // Increment quantity
      _items[existingIndex].quantity += quantity;
    } else {
      // Add new item
      _items.add(CartItem(
        itemId: itemId,
        name: name,
        price: price,
        imagePath: imagePath,
        quantity: quantity,
      ));
    }
    notifyListeners();
  }

  /// Remove item from cart completely
  void removeItem(String itemId) {
    _items.removeWhere((item) => item.itemId == itemId);
    notifyListeners();
  }

  /// Update quantity of an item
  void updateQuantity(String itemId, int quantity) {
    if (quantity <= 0) {
      removeItem(itemId);
      return;
    }

    final index = _items.indexWhere((item) => item.itemId == itemId);
    if (index >= 0) {
      _items[index].quantity = quantity;
      notifyListeners();
    }
  }

  /// Increment item quantity by 1
  void incrementQuantity(String itemId) {
    final index = _items.indexWhere((item) => item.itemId == itemId);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  /// Decrement item quantity by 1 (removes if quantity becomes 0)
  void decrementQuantity(String itemId) {
    final index = _items.indexWhere((item) => item.itemId == itemId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  /// Clear all items from cart
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  /// Get cart items as list of maps for order creation
  List<Map<String, dynamic>> toOrderItems() {
    return _items.map((item) => item.toOrderItemMap()).toList();
  }
}

/// Global instance of CartService (can also use Provider)
final cartService = CartService();
