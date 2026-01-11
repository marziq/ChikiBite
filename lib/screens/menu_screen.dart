import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'food_detail.dart';
import '../models/menu.dart';
import '../services/firestore_service.dart';

class MenuScreen extends StatefulWidget {
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final _firestoreService = firestoreService;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = getFilteredItems();

    return SafeArea(
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.filter_list, color: Colors.orange[800]),
                ),
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
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No menu items available'),
                  );
                }

                // Convert docs to MenuItem objects
                final items = snapshot.data!.docs
                    .map((doc) => MenuItem.fromDocument(doc))
                    .toList();

                // Filter by search query
                final filteredItems = items
                    .where((item) =>
                        item.name.toLowerCase().contains(_searchQuery) ||
                        item.description.toLowerCase().contains(_searchQuery))
                    .toList();

                if (filteredItems.isEmpty) {
                  return const Center(
                    child: Text('No items match your search'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FoodDetailScreen(
                              foodName: item.name,
                              description: item.description,
                              price: item.price,
                              category: item.categoryId,
                              imagePath: item.imageUrl,
                              rating: 4.5 + (index % 3) * 0.2,
                              reviews: 100 + (index * 10),
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
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Food Image
                            Container(
                              width: 120,
                              height: 120,
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
                                child: item.imageUrl.startsWith('http')
                                    ? Image.network(
                                        item.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Icon(
                                            Icons.fastfood,
                                            size: 50,
                                            color: Colors.orange[700],
                                          );
                                        },
                                      )
                                    : Image.asset(
                                        item.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
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
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.add,
                                              color: Colors.white,
                                            ),
                                            onPressed: () {
                                              // Add to cart functionality
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    '${item.name} added to cart',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  backgroundColor:
                                                      Colors.orange[800],
                                                  duration: const Duration(
                                                    seconds: 2,
                                                  ),
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
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
