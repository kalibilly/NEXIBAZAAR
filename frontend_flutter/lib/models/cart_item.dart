import 'product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get subtotal => product.price * quantity;

  void incrementQuantity() {
    if (quantity < product.stock) {
      quantity++;
    }
  }

  void decrementQuantity() {
    if (quantity > 1) {
      quantity--;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': product.id,
      'quantity': quantity,
    };
  }
}
