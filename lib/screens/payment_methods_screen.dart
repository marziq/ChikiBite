import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../services/profile_service.dart';
import '../models/user.dart' as app_user;

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  app_user.User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final user = await profileService.getUserProfileOnce(uid);
      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showAddPaymentDialog({
    Map<String, dynamic>? existingMethod,
  }) async {
    String selectedType = existingMethod?['type'] ?? 'Card';
    final cardNumberController = TextEditingController(
      text: existingMethod?['cardNumber'] ?? '',
    );
    final cardHolderController = TextEditingController(
      text: existingMethod?['cardHolder'] ?? '',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            existingMethod == null
                ? 'Add Payment Method'
                : 'Edit Payment Method',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Payment Type Dropdown
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Payment Type',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Card', 'Cash', 'E-Wallet'].map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setDialogState(() {
                        selectedType = newValue;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),

                // Card-specific fields
                if (selectedType == 'Card') ...[
                  TextField(
                    controller: cardNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Card Number (Last 4 digits)',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., 1234',
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: cardHolderController,
                    decoration: const InputDecoration(
                      labelText: 'Card Holder Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],

                // E-Wallet specific field
                if (selectedType == 'E-Wallet') ...[
                  TextField(
                    controller: cardHolderController,
                    decoration: const InputDecoration(
                      labelText: 'E-Wallet Name (e.g., PayPal, Venmo)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],

                // Cash doesn't need additional fields
                if (selectedType == 'Cash')
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Pay with cash on delivery',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedType == 'Card') {
                  if (cardNumberController.text.trim().isEmpty ||
                      cardHolderController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill all fields'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                }

                final uid =
                    firebase_auth.FirebaseAuth.instance.currentUser?.uid;
                if (uid != null) {
                  final paymentData = {
                    'type': selectedType,
                    if (selectedType == 'Card') ...{
                      'cardNumber': cardNumberController.text.trim(),
                      'cardHolder': cardHolderController.text.trim(),
                    },
                    if (selectedType == 'E-Wallet')
                      'walletName': cardHolderController.text.trim(),
                  };

                  try {
                    if (existingMethod == null) {
                      await profileService.addPaymentMethod(uid, paymentData);
                    } else {
                      await profileService.updatePaymentMethod(
                        uid,
                        existingMethod['id'],
                        paymentData,
                      );
                    }
                    Navigator.pop(context, true);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[700],
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      _loadUserData();
    }
  }

  Future<void> _deletePaymentMethod(String methodId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment Method'),
        content: const Text(
          'Are you sure you want to delete this payment method?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final uid = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        try {
          await profileService.deletePaymentMethod(uid, methodId);
          _loadUserData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment method deleted'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  Future<void> _setDefaultPaymentMethod(String methodId) async {
    final uid = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        await profileService.setDefaultPaymentMethod(uid, methodId);
        _loadUserData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Default payment method updated'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  IconData _getPaymentIcon(String type) {
    switch (type) {
      case 'Card':
        return Icons.credit_card;
      case 'Cash':
        return Icons.money;
      case 'E-Wallet':
        return Icons.account_balance_wallet;
      default:
        return Icons.payment;
    }
  }

  String _getPaymentDescription(Map<String, dynamic> method) {
    final type = method['type'] ?? 'Unknown';
    switch (type) {
      case 'Card':
        return '**** ${method['cardNumber'] ?? '****'}';
      case 'Cash':
        return 'Pay on delivery';
      case 'E-Wallet':
        return method['walletName'] ?? 'E-Wallet';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentUser?.paymentMethods == null ||
                _currentUser!.paymentMethods!.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.payment_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No payment methods added',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first payment method',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _currentUser!.paymentMethods!.length,
              itemBuilder: (context, index) {
                final method = _currentUser!.paymentMethods![index];
                final isDefault = method['isDefault'] == true;
                final type = method['type'] ?? 'Unknown';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: isDefault
                        ? BorderSide(color: Colors.orange[700]!, width: 2)
                        : BorderSide.none,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDefault
                            ? Colors.orange[100]
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getPaymentIcon(type),
                        color: isDefault
                            ? Colors.orange[800]
                            : Colors.grey[600],
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(
                          type,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange[700],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Default',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(_getPaymentDescription(method)),
                    ),
                    trailing: PopupMenuButton(
                      icon: const Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        if (!isDefault)
                          PopupMenuItem(
                            onTap: () => _setDefaultPaymentMethod(method['id']),
                            child: const Row(
                              children: [
                                Icon(Icons.check_circle_outline),
                                SizedBox(width: 8),
                                Text('Set as Default'),
                              ],
                            ),
                          ),
                        PopupMenuItem(
                          onTap: () => Future.delayed(
                            Duration.zero,
                            () => _showAddPaymentDialog(existingMethod: method),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.edit_outlined),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          onTap: () => _deletePaymentMethod(method['id']),
                          child: const Row(
                            children: [
                              Icon(Icons.delete_outline, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPaymentDialog(),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Payment'),
      ),
    );
  }
}
