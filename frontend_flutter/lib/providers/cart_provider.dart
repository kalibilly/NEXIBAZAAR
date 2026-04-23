import 'package:flutter/material.dart';
import 'models/index.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.length;

  double get totalPrice {
    return _items.fold(0, (total, item) => total + item.subtotal);
  }

  void addToCart(Product product) {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex >= 0) {
      _items[existingIndex].incrementQuantity();
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void removeFromCart(int productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(int productId, int quantity) {
    final item = _items.firstWhere((item) => item.product.id == productId);
    item.quantity = quantity;
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  List<Map<String, dynamic>> getCartItems() {
    return _items.map((item) => item.toJson()).toList();
  }
}
