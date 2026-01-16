import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../services/cart_service.dart';
import '../services/order_service.dart';
import '../services/profile_service.dart';
import '../services/promo_code_service.dart';
import '../services/voucher_service.dart';
import '../models/order.dart' as app_order;
import '../models/promo_code.dart';
import '../models/voucher.dart' show Voucher, VoucherStatus, VoucherType;

extension FirstWhereOrNullExtension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    try {
      return firstWhere(test);
    } catch (e) {
      return null;
    }
  }
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> with WidgetsBindingObserver {
  String selectedPaymentMethod = 'card';
  String selectedDelivery = 'home';
  bool _isPlacingOrder = false;
  bool _isLoadingAddresses = true;
  bool _isValidatingPromo = false;
  bool _isLoadingVouchers = false;
  List<Map<String, dynamic>> _userAddresses = [];
  Map<String, dynamic>? _selectedAddress;
  TextEditingController promoController = TextEditingController();
  TextEditingController newAddressController = TextEditingController();
  
  // Promo code state
  PromoCode? _appliedPromoCode;
  double _promoDiscount = 0;
  String? _promoErrorMessage;
  bool _isFreeDelivery = false;
  
  // Voucher state
  List<Voucher> _userVouchers = [];
  Voucher? _appliedVoucher;
  double _voucherDiscount = 0;
  bool _freeDeliveryFromVoucher = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserAddresses();
    _loadUserVouchers();
    // Seed promo codes if they don't exist
    promoCodeService.seedPromoCodes();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh vouchers when app comes back to foreground
      _loadUserVouchers();
    }
  }

  Future<void> _loadUserVouchers() async {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        setState(() {
          _isLoadingVouchers = true;
        });
        // Add a small delay to ensure Firebase has synced
        await Future.delayed(const Duration(milliseconds: 500));
        final vouchers = await voucherService.getAllUserVouchers(user.uid);
        print('Loaded ${vouchers.length} total vouchers');
        for (var v in vouchers) {
          print('Voucher: ${v.name}, Status: ${v.status}, IsValid: ${v.isValid}');
        }
        if (mounted) {
          setState(() {
            // Only show available/valid vouchers
            _userVouchers = vouchers.where((v) => v.isValid).toList();
            print('Filtered to ${_userVouchers.length} valid vouchers');
            _isLoadingVouchers = false;
          });
        }
      } catch (e) {
        print('Error loading vouchers: $e');
        if (mounted) {
          setState(() {
            _isLoadingVouchers = false;
          });
        }
      }
    } else {
      setState(() {
        _isLoadingVouchers = false;
      });
    }
  }

  Future<void> _loadUserAddresses() async {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userProfile = await profileService.getUserProfileOnce(user.uid);
        if (mounted) {
          setState(() {
            _userAddresses = userProfile?.addresses ?? [];
            // Select default address or first address
            _selectedAddress = _userAddresses.firstWhere(
              (addr) => addr['isDefault'] == true,
              orElse: () => _userAddresses.isNotEmpty ? _userAddresses.first : {},
            );
            if (_selectedAddress?.isEmpty ?? true) {
              _selectedAddress = null;
            }
            _isLoadingAddresses = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoadingAddresses = false;
          });
        }
      }
    } else {
      setState(() {
        _isLoadingAddresses = false;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    promoController.dispose();
    newAddressController.dispose();
    super.dispose();
  }

  double calculateSubtotal(CartService cart) {
    return cart.subtotal;
  }

  double calculateTax(double subtotal) {
    return subtotal * 0.06; // 6% tax
  }

  double calculateDeliveryFee() {
    if (selectedDelivery == 'pickup') return 0.0;
    // Free delivery from promo code
    if (_isFreeDelivery) return 0.0;
    // Free delivery from voucher
    if (_freeDeliveryFromVoucher) return 0.0;
    return 3.50;
  }

  double calculatePromoDiscount(double subtotal) {
    // Use the validated promo discount
    return _promoDiscount;
  }

  double calculateTotal(CartService cart) {
    final subtotal = calculateSubtotal(cart);
    final tax = calculateTax(subtotal);
    final deliveryFee = calculateDeliveryFee();
    final promoDiscount = calculatePromoDiscount(subtotal);
    return subtotal + tax + deliveryFee - promoDiscount - _voucherDiscount;
  }

  Future<void> _applyPromoCode(double subtotal) async {
    final code = promoController.text.trim();
    if (code.isEmpty) {
      setState(() {
        _promoErrorMessage = 'Please enter a promo code';
      });
      return;
    }

    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _promoErrorMessage = 'Please login to use promo codes';
      });
      return;
    }

    setState(() {
      _isValidatingPromo = true;
      _promoErrorMessage = null;
    });

    final result = await promoCodeService.validatePromoCode(
      code: code,
      userId: user.uid,
      subtotal: subtotal,
    );

    if (mounted) {
      setState(() {
        _isValidatingPromo = false;
        if (result.isValid && result.promoCode != null) {
          _appliedPromoCode = result.promoCode;
          _promoDiscount = result.discountAmount;
          _isFreeDelivery = result.promoCode!.discountType == DiscountType.freeDelivery;
          _promoErrorMessage = null;
        } else {
          _appliedPromoCode = null;
          _promoDiscount = 0;
          _isFreeDelivery = false;
          _promoErrorMessage = result.errorMessage;
        }
      });
    }
  }

  void _removePromoCode() {
    setState(() {
      _appliedPromoCode = null;
      _promoDiscount = 0;
      _isFreeDelivery = false;
      _promoErrorMessage = null;
      promoController.clear();
    });
  }

  void _applyVoucher(Voucher voucher, double subtotal, CartService cart) {
    String? errorMessage;
    double discountAmount = 0;
    bool isFreeDelivery = false;
    
    // Calculate voucher discount based on type
    switch (voucher.type) {
      case VoucherType.percentDiscount:
        if (voucher.discountValue != null) {
          discountAmount = subtotal * (voucher.discountValue! / 100);
        }
        break;
      case VoucherType.fixedDiscount:
        if (voucher.discountValue != null) {
          discountAmount = voucher.discountValue!;
        }
        break;
      case VoucherType.freeDelivery:
        discountAmount = 0;
        isFreeDelivery = true;
        break;
      case VoucherType.freeItem:
        // Strict validation for free items
        if (voucher.name.toLowerCase().contains('burger')) {
          // Free Burger: Check if cart has burger
          final burgerItem = cart.items.firstWhereOrNull(
            (item) => item.name.toLowerCase().contains('burger') || 
                      item.name.toLowerCase().contains('chicken')
          );
          if (burgerItem != null) {
            discountAmount = burgerItem.price;
          } else {
            errorMessage = 'No burger/chicken found in cart!';
          }
        } else if (voucher.name.toLowerCase().contains('drinks')) {
          // Free Drink: Check if cart has drink
          final drinkItem = cart.items.firstWhereOrNull(
            (item) {
              final name = item.name.toLowerCase();
              return name.contains('drinks') ||
                     name.contains('beverage') ||
                     name.contains('juice') ||
                     name.contains('tea') ||
                     name.contains('coffee') ||
                     name.contains('water') ||
                     name.contains('cola') ||
                     name.contains('soda') ||
                     name.contains('shake') ||
                     name.contains('smoothie') ||
                     name.contains('lemonade');
            }
          );
          if (drinkItem != null) {
            discountAmount = drinkItem.price;
          } else {
            errorMessage = 'No drink found in cart!';
          }
        } else if (voucher.name.toLowerCase().contains('meal')) {
          // Free Meal: Check if cart has 1 burger/chicken AND 1 drink
          final burgerItem = cart.items.firstWhereOrNull(
            (item) => item.name.toLowerCase().contains('burger') ||
                      item.name.toLowerCase().contains('chicken')
          );
          final drinkItem = cart.items.firstWhereOrNull(
            (item) {
              final name = item.name.toLowerCase();
              return name.contains('drinks') ||
                     name.contains('beverage') ||
                     name.contains('juice') ||
                     name.contains('tea') ||
                     name.contains('coffee') ||
                     name.contains('water') ||
                     name.contains('cola') ||
                     name.contains('soda') ||
                     name.contains('shake') ||
                     name.contains('smoothie') ||
                     name.contains('lemonade');
            }
          );
          
          if (burgerItem == null) {
            errorMessage = 'Free Meal requires a burger/chicken in cart!';
          } else if (drinkItem == null) {
            errorMessage = 'Free Meal requires a drink in cart!';
          } else {
            discountAmount = burgerItem.price + drinkItem.price;
          }
        }
        break;
    }
    
    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red[700],
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
    
    setState(() {
      _appliedVoucher = voucher;
      _voucherDiscount = discountAmount;
      _freeDeliveryFromVoucher = isFreeDelivery;
    });
    
    // Mark voucher as used in Firebase
    _markVoucherAsUsed(voucher);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Voucher applied! You save RM ${discountAmount.toStringAsFixed(2)}'),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _markVoucherAsUsed(Voucher voucher) async {
    try {
      // Update voucher status to used in Firebase
      await voucherService.markVoucherAsUsed(voucher.id);
      
      // Remove from local list
      if (mounted) {
        setState(() {
          _userVouchers.removeWhere((v) => v.id == voucher.id);
        });
      }
    } catch (e) {
      print('Error marking voucher as used: $e');
    }
  }

  void _removeVoucher() {
    setState(() {
      _appliedVoucher = null;
      _voucherDiscount = 0;
      _freeDeliveryFromVoucher = false;
    });
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

  String _getFormattedAddress(Map<String, dynamic> address) {
    final parts = <String>[];
    if (address['street'] != null && address['street'].toString().isNotEmpty) {
      parts.add(address['street']);
    }
    if (address['city'] != null && address['city'].toString().isNotEmpty) {
      parts.add(address['city']);
    }
    if (address['state'] != null && address['state'].toString().isNotEmpty) {
      parts.add(address['state']);
    }
    if (address['postalCode'] != null && address['postalCode'].toString().isNotEmpty) {
      parts.add(address['postalCode']);
    }
    return parts.isNotEmpty ? parts.join(', ') : 'No address details';
  }

  Future<void> _showAddAddressDialog() async {
    final streetController = TextEditingController();
    final cityController = TextEditingController();
    final stateController = TextEditingController();
    final postalCodeController = TextEditingController();
    final labelController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add New Address',
          style: TextStyle(
            color: Colors.orange[800],
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelController,
                decoration: InputDecoration(
                  labelText: 'Label (e.g., Home, Office)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.label_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: streetController,
                decoration: InputDecoration(
                  labelText: 'Street Address *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.home_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cityController,
                decoration: InputDecoration(
                  labelText: 'City *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.location_city),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: stateController,
                decoration: InputDecoration(
                  labelText: 'State',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.map_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: postalCodeController,
                decoration: InputDecoration(
                  labelText: 'Postal Code',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.pin_drop_outlined),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (streetController.text.isEmpty || cityController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Street and City are required'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[800],
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result == true) {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user != null) {
        final newAddress = {
          'label': labelController.text.isEmpty ? 'Home' : labelController.text,
          'street': streetController.text,
          'city': cityController.text,
          'state': stateController.text,
          'postalCode': postalCodeController.text,
        };

        await profileService.addAddress(user.uid, newAddress);
        await _loadUserAddresses();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Address added successfully'),
              backgroundColor: Colors.green[700],
            ),
          );
        }
      }
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

    // Validate address for delivery orders
    if (selectedDelivery == 'home' && _selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a delivery address'),
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
        deliveryAddress: selectedDelivery == 'pickup' 
            ? 'Pickup from store' 
            : _getFormattedAddress(_selectedAddress!),
        paymentMethod: _getPaymentMethodName(selectedPaymentMethod),
        createdAt: DateTime.now(),
      );

      // Save to Firestore and get the order ID
      final orderId = await orderService.createOrder(order);

      // Record promo code usage if one was applied
      if (_appliedPromoCode != null) {
        await promoCodeService.recordPromoUsage(
          promoCodeId: _appliedPromoCode!.id,
          userId: user.uid,
          orderId: orderId,
          discountApplied: _promoDiscount,
        );
      }

      // Start automatic status progression (updates every 10 seconds)
      final isPickup = selectedDelivery == 'pickup';
      orderService.startAutomaticStatusProgression(
        orderId,
        isPickup: isPickup,
        intervalSeconds: 10,
      );

      // Add reward points (RM1 = 1 point)
      final orderTotal = calculateTotal(cart);
      final pointsEarned = ProfileService.calculatePointsForOrder(orderTotal);
      if (pointsEarned > 0) {
        await profileService.addPoints(
          user.uid,
          pointsEarned,
          reason: 'Order #${orderId.substring(0, 8)}',
        );
      }

      // Clear cart after successful order
      cart.clearCart();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Order placed successfully! 🎉 +$pointsEarned points earned!',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green[700],
            duration: const Duration(seconds: 3),
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
                      _buildPromoCodeSection(subtotal),

                      const SizedBox(height: 24),

                      // Voucher Section
                      _buildSectionTitle('Redeem Voucher'),
                      const SizedBox(height: 12),
                      _buildVoucherSection(subtotal, cart),

                      const SizedBox(height: 24),

                      // Delivery Address Section
                      _buildSectionTitle('Delivery Address'),
                      const SizedBox(height: 12),
                      _buildDeliveryAddressSection(),

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
                            if (_appliedPromoCode != null && (promoDiscount > 0 || _isFreeDelivery)) ...[
                              const SizedBox(height: 12),
                              _buildPriceRow(
                                'Promo (${_appliedPromoCode!.code})',
                                promoDiscount > 0 
                                    ? '- RM ${promoDiscount.toStringAsFixed(2)}'
                                    : _isFreeDelivery ? 'Free Delivery' : '',
                                isDiscount: true,
                              ),
                            ],
                            if (_appliedVoucher != null && (_voucherDiscount > 0 || _freeDeliveryFromVoucher)) ...[
                              const SizedBox(height: 12),
                              _buildPriceRow(
                                'Voucher (${_appliedVoucher!.name})',
                                _voucherDiscount > 0 
                                    ? '- RM ${_voucherDiscount.toStringAsFixed(2)}'
                                    : _freeDeliveryFromVoucher ? 'Free Delivery' : '',
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

  Widget _buildPromoCodeSection(double subtotal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _appliedPromoCode != null 
              ? Colors.green[400]! 
              : _promoErrorMessage != null 
                  ? Colors.red[300]! 
                  : Colors.orange[200]!,
          width: _appliedPromoCode != null ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Applied promo code display
          if (_appliedPromoCode != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _appliedPromoCode!.code,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _appliedPromoCode!.description,
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 12,
                          ),
                        ),
                        if (_promoDiscount > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            'You save: RM${_promoDiscount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.green[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                        if (_isFreeDelivery) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Free Delivery Applied!',
                            style: TextStyle(
                              color: Colors.green[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _removePromoCode,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Promo code input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: promoController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Enter promo code',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _isValidatingPromo ? null : () => _applyPromoCode(subtotal),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _isValidatingPromo
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Apply',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            // Error message
            if (_promoErrorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700], size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _promoErrorMessage!,
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }


  Widget _buildDeliveryAddressSection() {
    // Show loading state
    if (_isLoadingAddresses) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange[200]!),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show empty state with add button
    if (_userAddresses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange[200]!),
        ),
        child: Column(
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'No saved addresses',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _showAddAddressDialog,
              icon: const Icon(Icons.add_location_alt, size: 18),
              label: const Text('Add Address'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[800],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Show address list with selection
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        children: [
          ..._userAddresses.map((address) {
            final isSelected = _selectedAddress?['id'] == address['id'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedAddress = address;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.orange[50] : Colors.grey[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? Colors.orange[800]! : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      address['label']?.toString().toLowerCase() == 'office'
                          ? Icons.work_outline
                          : Icons.home_outlined,
                      color: isSelected ? Colors.orange[800] : Colors.grey[600],
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                address['label']?.toString() ?? 'Address',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isSelected ? Colors.orange[800] : Colors.black87,
                                ),
                              ),
                              if (address['isDefault'] == true) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[100],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Default',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.orange[800],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getFormattedAddress(address),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: Colors.orange[800],
                        size: 24,
                      ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 4),
          // Add new address button
          GestureDetector(
            onTap: _showAddAddressDialog,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey[300]!,
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_location_alt_outlined,
                    color: Colors.orange[800],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Add New Address',
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Delivery time info
          Text(
            selectedDelivery == 'pickup'
                ? 'Ready for pickup in 15-20 minutes'
                : 'Delivery in 30-40 minutes',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
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

  Widget _buildVoucherSection(double subtotal, CartService cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _appliedVoucher != null 
              ? Colors.green[400]! 
              : Colors.blue[200]!,
          width: _appliedVoucher != null ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_appliedVoucher != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _appliedVoucher!.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _appliedVoucher!.description,
                          style: TextStyle(
                            color: Colors.green[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _removeVoucher,
                    child: Icon(Icons.close, color: Colors.green[700], size: 20),
                  ),
                ],
              ),
            ),
          ] else if (_isLoadingVouchers) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            ),
          ] else if (_userVouchers.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.card_giftcard, color: Colors.grey[500], size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No vouchers available',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Earn points to redeem!',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _loadUserVouchers,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.refresh,
                        color: Colors.orange[800],
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Vouchers list
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _userVouchers.map((voucher) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => _applyVoucher(voucher, subtotal, cart),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              voucher.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              voucher.description,
                              style: TextStyle(
                                color: Colors.blue[600],
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

