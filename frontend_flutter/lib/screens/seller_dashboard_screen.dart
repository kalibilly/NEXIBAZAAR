import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/index.dart';
import '../services/order_service.dart';
import '../models/order.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({Key? key}) : super(key: key);

  @override
  _SellerDashboardScreenState createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  late Future<List<Order>> _ordersFuture;
  late OrderService _orderService;
  double _walletBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _orderService = Provider.of<OrderService>(context, listen: false);
    _ordersFuture = _loadSellerOrders();
    _loadWallet();
  }

  Future<List<Order>> _loadSellerOrders() async {
    final response = await _orderService.apiClient.get('/users/seller_orders/');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((json) => Order.fromJson(json)).toList();
    }
    throw Exception('Failed to fetch seller orders');
  }

  Future<void> _loadWallet() async {
    final response = await _orderService.apiClient.get('/users/wallet/');
    if (response.statusCode == 200) {
      setState(() {
        _walletBalance = double.parse(response.data['balance'].toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    if (auth.user?.accountType != 'seller') {
      return Scaffold(
        appBar: AppBar(title: const Text('Seller Dashboard')),
        body: const Center(child: Text('Access denied')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Wallet Balance: \$${_walletBalance.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            const Text('Orders', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Expanded(
              child: FutureBuilder<List<Order>>(
                future: _ordersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: \\${snapshot.error}'));
                  }
                  final orders = snapshot.data ?? [];
                  if (orders.isEmpty) {
                    return const Center(child: Text('No orders yet'));
                  }
                  return ListView(
                    children: orders.map((order) {
                      return Card(
                        child: ListTile(
                          title: Text('Order #${order.orderNumber}'),
                          subtitle: Text('Total: \$${order.totalPrice} - Status: ${order.status}'),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
