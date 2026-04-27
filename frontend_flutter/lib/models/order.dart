class Order {
  final int id;
  final int userId;
  final String? userEmail;
  final String orderNumber;
  final double totalPrice;
  final String status;
  final String paymentStatus;
  final bool otpConfirmed;
  final String shippingAddress;
  final String phone;
  final List<OrderItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.userId,
    this.userEmail,
    required this.orderNumber,
    required this.totalPrice,
    required this.status,
    required this.shippingAddress,
    required this.phone,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var itemsList = <OrderItem>[];
    if (json['items'] != null) {
      itemsList = (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList();
    }

    return Order(
      id: json['id'],
      userId: json['user'],
      userEmail: json['user_email'],
      orderNumber: json['order_number'],
      totalPrice: double.parse(json['total_price'].toString()),
      status: json['status'],
      paymentStatus: json['payment_status'] ?? 'unpaid',
      otpConfirmed: json['otp_confirmed'] ?? false,
      shippingAddress: json['shipping_address'],
      phone: json['phone'],
      items: itemsList,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'total_price': totalPrice,
      'status': status,
      'shipping_address': shippingAddress,
      'phone': phone,
    };
  }
}

class OrderItem {
  final int id;
  final int productId;
  final String productName;
  final double price;
  final int quantity;
  final DateTime createdAt;

  OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.createdAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      productId: json['product']['id'],
      productName: json['product']['name'],
      price: double.parse(json['price'].toString()),
      quantity: json['quantity'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  double get subtotal => price * quantity;
}
