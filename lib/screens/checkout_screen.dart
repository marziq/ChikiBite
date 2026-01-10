import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? cartItems;
  final double? subtotal;

  const CheckoutScreen({super.key, this.cartItems, this.subtotal});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String selectedPaymentMethod = 'card';
  String selectedDelivery = 'home';
  bool usePromoCode = false;
  TextEditingController promoController = TextEditingController();

  // Sample cart items
  final List<Map<String, dynamic>> cartItems = [
    {'name': 'Chicken Burger', 'quantity': 2, 'price': 10.00},
    {'name': 'Fried Rice', 'quantity': 1, 'price': 8.00},
    {'name': 'Orange Juice', 'quantity': 2, 'price': 3.00},
  ];

  late double subtotal;
  late double tax;
  late double deliveryFee;
  late double promoDiscount;
  late double total;

  @override
  void initState() {
    super.initState();
    calculateTotals();
  }

  void calculateTotals() {
    subtotal = cartItems.fold(
      0,
      (sum, item) => sum + (item['price'] * item['quantity']),
    );
    tax = subtotal * 0.06; // 6% tax
    deliveryFee = 3.50;
    promoDiscount = usePromoCode
        ? subtotal * 0.1
        : 0; // 10% discount if promo applied
    total = subtotal + tax + deliveryFee - promoDiscount;
  }

  @override
  Widget build(BuildContext context) {
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
      ),
      body: SingleChildScrollView(
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
                children: List.generate(cartItems.length, (index) {
                  final item = cartItems[index];
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
                                  item['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'x${item['quantity']}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'RM ${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[800],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      if (index < cartItems.length - 1)
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
                        calculateTotals();
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
                        child: Text(
                          '123 Jalan Merdeka, 50150 Kuala Lumpur',
                          style: TextStyle(
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
                    'Delivery in 30-40 minutes',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'Change Address',
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
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
                    'RM ${deliveryFee.toStringAsFixed(2)}',
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
                      Text(
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
                onPressed: () {
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
                  Future.delayed(const Duration(seconds: 2), () {
                    Navigator.pop(context);
                  });
                },
                child: const Text(
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
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
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
