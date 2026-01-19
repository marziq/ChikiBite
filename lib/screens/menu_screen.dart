import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'food_detail.dart';
import 'checkout_screen.dart';
import '../models/menu.dart';
import '../data/menu_data.dart';
import '../services/firestore_service.dart';
import '../services/cart_service.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';


class MenuScreen extends StatefulWidget {
const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final _firestoreService = firestoreService;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _sortOption = 'default'; // default, price_low_high, price_high_low

  final List<String> _allCategories = ['All', 'burger', 'chicken', 'snacks', 'dessert', 'drinks'];
  final Map<String, IconData> _categoryIcons = {
    'All': Icons.restaurant,
    'burger': Icons.lunch_dining,
    'chicken': MdiIcons.foodDrumstick,
    'snacks': Icons.bakery_dining,
    'dessert': Icons.cake,
    'drinks': Icons.local_drink,
  };

  final List<String> _categoryOrder = ['burger', 'chicken', 'snacks', 'dessert', 'drinks'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/img/logo.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.fastfood, color: Colors.orange[800]),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
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
                    spreadRadius: 2,
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Consumer<CartService>(
                builder: (context, cartService, _) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CheckoutScreen(),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shopping_cart,
                          color: Colors.white,
                          size: 20,
                        ),
                        if (cartService.items.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Text(
                            cartService.items.length.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search and Filter Bar
            Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search menu...',
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: Colors.grey[600]),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    _showSortDialog();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.filter_list, color: Colors.orange[800]),
                  ),
                ),
              ],
            ),
          ),

          // Categories Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Categories',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _allCategories.length,
                    itemBuilder: (context, index) {
                      final category = _allCategories[index];
                      final isSelected = _selectedCategory == category;
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category; // category is already lowercase from _allCategories
                          });
                        },
                        child: Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.orange[700] : Colors.orange[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? Colors.orange[700]! : Colors.orange[200]!,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _categoryIcons[category] ?? Icons.restaurant,
                                size: 32,
                                color: isSelected ? Colors.white : Colors.orange[700],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                category == 'All' ? 'All' : _capitalizeFirst(category),
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.orange[800],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        
          // Menu List from Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestoreService.menuStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Error loading menu:'),
                        Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No menu items available'),
                  );
                }

                // Convert docs to MenuItem objects and merge with local data
                final items = snapshot.data!.docs
                    .map((doc) {
                      print('Document: ${doc.id}, Data: ${doc.data()}');
                      final firestoreItem = MenuItem.fromDocument(doc);
                      
                      // Find matching item in local menu data to get nutrition/ingredients
                      final localItem = menuItems.firstWhere(
                        (item) => item.itemID == firestoreItem.itemID || 
                                 item.name == firestoreItem.name,
                        orElse: () => firestoreItem,
                      );
                      
                      // Merge: use Firestore data but fill in missing nutrition/ingredients from local data
                      return firestoreItem.ingredients.isEmpty ? firestoreItem.copyWith(
                        ingredients: localItem.ingredients,
                        calories: firestoreItem.calories == 450 ? localItem.calories : firestoreItem.calories,
                        protein: firestoreItem.protein == 25 ? localItem.protein : firestoreItem.protein,
                        fat: firestoreItem.fat == 18 ? localItem.fat : firestoreItem.fat,
                        carbs: firestoreItem.carbs == 42 ? localItem.carbs : firestoreItem.carbs,
                      ) : firestoreItem;
                    })
                    .toList();
                
                print('Total items fetched: ${items.length}');
                
                // Print all unique categories from Firestore
                final uniqueCategories = items.map((item) => item.category).toSet();
                print('Categories in Firestore: $uniqueCategories');

                // Filter by search query and category
                var filteredItems = items
                    .where((item) {
                      final matchesSearch = _searchQuery.isEmpty ||
                          item.name.toLowerCase().contains(_searchQuery) ||
                          item.description.toLowerCase().contains(_searchQuery);
                      final matchesCategory = _selectedCategory == 'All' || 
                          item.category == _selectedCategory;
                      return matchesSearch && matchesCategory;
                    })
                    .toList();
                
                print('Selected Category: $_selectedCategory');
                print('Search Query: $_searchQuery');
                print('Filtered items count: ${filteredItems.length}');
                print('Filtered items: ${filteredItems.map((item) => '${item.name} (${item.category})').toList()}');

                // Apply sorting
                if (_sortOption == 'price_low_high') {
                  filteredItems.sort((a, b) => a.price.compareTo(b.price));
                } else if (_sortOption == 'price_high_low') {
                  filteredItems.sort((a, b) => b.price.compareTo(a.price));
                }

                if (filteredItems.isEmpty) {
                  return const Center(
                    child: Text('No items match your search'),
                  );
                }

                // Group items by category
                Map<String, List<MenuItem>> groupedItems = {};
                for (var item in filteredItems) {
                  if (!groupedItems.containsKey(item.category)) {
                    groupedItems[item.category] = [];
                  }
                  groupedItems[item.category]!.add(item);
                }

                // Build list with category headers
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _getCategoryListCount(groupedItems),
                  itemBuilder: (context, index) {
                    return _buildCategoryOrMenuItem(context, index, groupedItems, _categoryOrder);
                  },
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }

  int _getCategoryListCount(Map<String, List<MenuItem>> groupedItems) {
    int count = 0;
    for (var category in _categoryOrder) {
      if (groupedItems.containsKey(category)) {
        count += 1 + groupedItems[category]!.length; // 1 for header + items
      }
    }
    return count;
  }

  Widget _buildCategoryOrMenuItem(
    BuildContext context,
    int index,
    Map<String, List<MenuItem>> groupedItems,
    List<String> categoryOrder,
  ) {
    int currentIndex = 0;
    
    for (var category in categoryOrder) {
      if (!groupedItems.containsKey(category)) continue;
      
      final items = groupedItems[category]!;
      
      // Category header
      if (index == currentIndex) {
        return Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
          child: Text(
            _capitalizeFirst(category),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.orange[800],
            ),
          ),
        );
      }
      
      currentIndex++;
      
      // Menu items for this category
      for (var item in items) {
        if (index == currentIndex) {
          return _buildMenuItemCard(context, item);
        }
        currentIndex++;
      }
    }
    
    return const SizedBox();
  }

  Widget _buildMenuItemCard(BuildContext context, MenuItem item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodDetailScreen(
              itemId: item.itemID,
              foodName: item.name,
              description: item.description,
              price: item.price,
              category: item.category,
              imagePath: item.imagePath,
              ingredients: item.ingredients,
              calories: item.calories,
              protein: item.protein,
              fat: item.fat,
              carbs: item.carbs,
              rating: 4.5,
              reviews: 100,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
            // Food Image
            Container(
              width: 120,
              constraints: const BoxConstraints(minHeight: 140),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: item.imagePath.startsWith('http')
                    ? Image.network(
                        item.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.fastfood,
                            size: 50,
                            color: Colors.orange[700],
                          );
                        },
                      )
                    : Image.asset(
                        item.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.fastfood,
                            size: 50,
                            color: Colors.orange[700],
                          );
                        },
                      ),
              ),
            ),

            // Food Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'RM ${item.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.orange[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.orange[800],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              // Add to cart using CartService
                              final cart = Provider.of<CartService>(context, listen: false);
                              cart.addItem(
                                itemId: item.itemID,
                                name: item.name,
                                price: item.price,
                                imagePath: item.imagePath,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${item.name} added to cart',
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: Colors.orange[800],
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),        ),      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort By'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Default'),
              value: 'default',
              groupValue: _sortOption,
              onChanged: (value) {
                setState(() {
                  _sortOption = value ?? 'default';
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Price: Low to High'),
              value: 'price_low_high',
              groupValue: _sortOption,
              onChanged: (value) {
                setState(() {
                  _sortOption = value ?? 'default';
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Price: High to Low'),
              value: 'price_high_low',
              groupValue: _sortOption,
              onChanged: (value) {
                setState(() {
                  _sortOption = value ?? 'default';
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
