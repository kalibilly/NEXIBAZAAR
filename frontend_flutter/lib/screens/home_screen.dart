import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/index.dart';
import '../providers/index.dart';
import '../services/index.dart';
import '../widgets/index.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ProductService _productService;
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productService = context.read<ProductService>();
    _productsFuture = _productService.getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NexiBazaar'),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, theme, _) {
              return IconButton(
                icon: Icon(theme.mode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode),
                onPressed: () => theme.toggleMode(),
              );
            },
          ),
          Consumer<CartProvider>(
            builder: (context, cart, _) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.pushNamed(context, '/cart');
                    },
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              if (auth.isAuthenticated) {
                // show seller dashboard shortcut if applicable
                List<PopupMenuEntry> menuItems = [
                  const PopupMenuItem(
                    child: Text('Orders'),
                    value: 'orders',
                  ),
                ];
                if (auth.user?.accountType == 'seller') {
                  menuItems.add(
                    const PopupMenuItem(
                      child: Text('Seller Dashboard'),
                      value: 'seller',
                    ),
                  );
                }
                menuItems.add(const PopupMenuDivider());
                menuItems.add(
                  const PopupMenuItem(
                    child: Text('Logout'),
                    value: 'logout',
                  ),
                );

                return IconButton(
                  icon: const Icon(Icons.account_circle),
                  onPressed: () {
                    showMenu(
                      context: context,
                      position: const RelativeRect.fromLTRB(0, 80, 0, 0),
                      items: menuItems,
                    ).then((value) {
                      if (value == 'orders') {
                        Navigator.pushNamed(context, '/orders');
                      } else if (value == 'seller') {
                        Navigator.pushNamed(context, '/seller-dashboard');
                      } else if (value == 'logout') {
                        auth.logout();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Logged out')),
                        );
                      }
                    });
                  },
                );
              } else {
                return IconButton(
                  icon: const Icon(Icons.login),
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                );
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Failed to load products'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _productsFuture = _productService.getProducts();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return const Center(
              child: Text('No products available'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ProductCard(
                product: products[index],
                onTap: () {
                  // Navigate to product details if needed
                },
              );
            },
          );
        },
      ),
    );
  }
}
