import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';
import '../models/order.dart' as app_order;

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String selectedPaymentMethod = 'card';
  String selectedDelivery = 'home';
  bool usePromoCode = false;
  bool _isPlacingOrder = false;
  TextEditingController promoController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    addressController.text = '123 Jalan Merdeka, 50150 Kuala Lumpur';
  }

  @override
  void dispose() {
    promoController.dispose();
    addressController.dispose();
    super.dispose();
  }

  double calculateSubtotal(CartService cart) {
    return cart.subtotal;
  }

  double calculateTax(double subtotal) {
    return subtotal * 0.06; // 6% tax
  }

  double calculateDeliveryFee() {
    return selectedDelivery == 'pickup' ? 0.0 : 3.50;
  }

  double calculatePromoDiscount(double subtotal) {
    return usePromoCode ? subtotal * 0.1 : 0; // 10% discount
  }

  double calculateTotal(CartService cart) {
    final subtotal = calculateSubtotal(cart);
    final tax = calculateTax(subtotal);
    final deliveryFee = calculateDeliveryFee();
    final promoDiscount = calculatePromoDiscount(subtotal);
    return subtotal + tax + deliveryFee - promoDiscount;
  }

  String _getPaymentMethodName(String method) {
    switch (method) {
      case 'card':
        return 'Credit/Debit Card';
      case 'wallet':
        return 'E-Wallet';
      case 'cash':
        return 'Cash on Delivery';
      case 'bank':
        return 'Online Banking';
      default:
        return method;
    }
  }

  Future<void> _placeOrder(CartService cart) async {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to place an order'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isPlacingOrder = true;
    });

    try {
      // Create order items from cart
      final orderItems = cart.items.map((item) => app_order.OrderItem(
        itemId: item.itemId,
        name: item.name,
        quantity: item.quantity,
        price: item.price,
      )).toList();

      // Create order object
      final order = app_order.Order(
        id: '', // Will be set by Firestore
        userId: user.uid,
        items: orderItems,
        total: calculateTotal(cart),
        status: 'pending',
        deliveryAddress: addressController.text,
        paymentMethod: _getPaymentMethodName(selectedPaymentMethod),
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await orderService.createOrder(order);

      // Clear cart after successful order
      cart.clearCart();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Order placed successfully! 🎉',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green[700],
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate back after short delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartService>(
      builder: (context, cart, child) {
        final subtotal = calculateSubtotal(cart);
        final tax = calculateTax(subtotal);
        final deliveryFee = calculateDeliveryFee();
        final promoDiscount = calculatePromoDiscount(subtotal);
        final total = calculateTotal(cart);

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text('Checkout'),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 1,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.arrow_back, color: Colors.orange[800]),
            ),
            titleTextStyle: TextStyle(
              color: Colors.orange[800],
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            actions: [
              // Cart item count badge
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    '${cart.itemCount} items',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: cart.isEmpty
              ? _buildEmptyCart()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order Summary Section
                      _buildSectionTitle('Order Summary'),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Column(
                          children: List.generate(cart.items.length, (index) {
                            final item = cart.items[index];
                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              // Quantity controls
                                              GestureDetector(
                                                onTap: () {
                                                  cart.decrementQuantity(item.itemId);
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.orange[100],
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Icon(
                                                    Icons.remove,
                                                    size: 16,
                                                    color: Colors.orange[800],
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                                child: Text(
                                                  'x${item.quantity}',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  cart.incrementQuantity(item.itemId);
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.orange[100],
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Icon(
                                                    Icons.add,
                                                    size: 16,
                                                    color: Colors.orange[800],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'RM ${item.totalPrice.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange[800],
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: () {
                                            cart.removeItem(item.itemId);
                                          },
                                          child: Icon(
                                            Icons.delete_outline,
                                            color: Colors.red[400],
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (index < cart.items.length - 1)
                                  Divider(color: Colors.grey[200], height: 20),
                              ],
                            );
                          }),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Promo Code Section
                      _buildSectionTitle('Promo Code'),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: promoController,
                                decoration: InputDecoration(
                                  hintText: 'Enter promo code',
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  usePromoCode = !usePromoCode;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: usePromoCode
                                      ? Colors.orange[700]
                                      : Colors.orange[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  usePromoCode ? 'Applied' : 'Apply',
                                  style: TextStyle(
                                    color: usePromoCode
                                        ? Colors.white
                                        : Colors.orange[800],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Delivery Address Section
                      _buildSectionTitle('Delivery Address'),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.orange[800],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: addressController,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              selectedDelivery == 'pickup'
                                  ? 'Ready for pickup in 15-20 minutes'
                                  : 'Delivery in 30-40 minutes',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Payment Method Section
                      _buildSectionTitle('Payment Method'),
                      const SizedBox(height: 12),
                      _buildPaymentOption(
                        'card',
                        'Credit/Debit Card',
                        Icons.credit_card,
                        'Visa, Mastercard, Amex',
                      ),
                      const SizedBox(height: 12),
                      _buildPaymentOption(
                        'wallet',
                        'E-Wallet',
                        Icons.account_balance_wallet,
                        'Touch n Go, Boost, GCash',
                      ),
                      const SizedBox(height: 12),
                      _buildPaymentOption(
                        'cash',
                        'Cash on Delivery',
                        Icons.money,
                        'Pay when order arrives',
                      ),
                      const SizedBox(height: 12),
                      _buildPaymentOption(
                        'bank',
                        'Online Banking',
                        Icons.account_balance,
                        'Maybank, CIMB, Public Bank',
                      ),

                      const SizedBox(height: 24),

                      // Delivery Option Section
                      _buildSectionTitle('Delivery Option'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedDelivery = 'home';
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: selectedDelivery == 'home'
                                      ? Colors.orange[50]
                                      : Colors.white,
                                  border: Border.all(
                                    color: selectedDelivery == 'home'
                                        ? Colors.orange[800]!
                                        : Colors.grey[300]!,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.home, color: Colors.orange[800], size: 24),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Home Delivery',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: selectedDelivery == 'home'
                                            ? Colors.orange[800]
                                            : Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'RM 3.50',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedDelivery = 'pickup';
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: selectedDelivery == 'pickup'
                                      ? Colors.orange[50]
                                      : Colors.white,
                                  border: Border.all(
                                    color: selectedDelivery == 'pickup'
                                        ? Colors.orange[800]!
                                        : Colors.grey[300]!,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.store,
                                      color: Colors.orange[800],
                                      size: 24,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Pick Up',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: selectedDelivery == 'pickup'
                                            ? Colors.orange[800]
                                            : Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Free',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.green[600],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Price Breakdown Section
                      _buildSectionTitle('Price Breakdown'),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Column(
                          children: [
                            _buildPriceRow(
                              'Subtotal',
                              'RM ${subtotal.toStringAsFixed(2)}',
                            ),
                            const SizedBox(height: 12),
                            _buildPriceRow('Tax (6%)', 'RM ${tax.toStringAsFixed(2)}'),
                            const SizedBox(height: 12),
                            _buildPriceRow(
                              'Delivery Fee',
                              deliveryFee > 0
                                  ? 'RM ${deliveryFee.toStringAsFixed(2)}'
                                  : 'Free',
                            ),
                            if (usePromoCode) ...[
                              const SizedBox(height: 12),
                              _buildPriceRow(
                                'Promo Discount (10%)',
                                '- RM ${promoDiscount.toStringAsFixed(2)}',
                                isDiscount: true,
                              ),
                            ],
                            Divider(color: Colors.grey[300], height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Amount',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  'RM ${total.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.orange[800],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Place Order Button
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.orange[400]!, Colors.orange[700]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: _isPlacingOrder ? null : () => _placeOrder(cart),
                          child: _isPlacingOrder
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Place Order',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items from the menu to get started',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[800],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            child: const Text('Browse Menu'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildPaymentOption(
    String value,
    String title,
    IconData icon,
    String subtitle,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selectedPaymentMethod == value
              ? Colors.orange[50]
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedPaymentMethod == value
                ? Colors.orange[800]!
                : Colors.grey[300]!,
            width: selectedPaymentMethod == value ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: selectedPaymentMethod == value
                    ? Colors.orange[100]
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.orange[800], size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            if (selectedPaymentMethod == value)
              Icon(Icons.check_circle, color: Colors.orange[800], size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String amount, {
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
        Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isDiscount ? Colors.green[700] : Colors.black87,
          ),
        ),
      ],
    );
  }
}
