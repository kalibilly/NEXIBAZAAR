import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/index.dart';
import '../services/order_service.dart';
import '../models/order.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final orderService = Provider.of<OrderService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: auth.isAuthenticated
          ? FutureBuilder<List<Order>>(
              future: orderService.getMyOrders(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final orders = snapshot.data ?? [];
                if (orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_bag, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('No orders yet'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, '/home'),
                          child: const Text('Continue Shopping'),
                        ),
                      ],
                    ),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.all(8),
                  children: orders.map((order) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Order #${order.orderNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('Status: ${order.status}'),
                            Text('Payment: ${order.paymentStatus}'),
                            Text('Total: \$${order.totalPrice.toStringAsFixed(2)}'),
                            const SizedBox(height: 8),
                            if (order.paymentStatus == 'paid' && !order.otpConfirmed)
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: TextEditingController(),
                                      decoration: InputDecoration(hintText: 'Delivery OTP', border: OutlineInputBorder()),
                                      onChanged: (val) {
                                        // store in local variable? easier to prompt dialog here
                                      },
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      // prompting OTP input
                                      showDialog(
                                        context: context,
                                        builder: (ctx) {
                                          final otpController = TextEditingController();
                                          return AlertDialog(
                                            title: const Text('Confirm Delivery'),
                                            content: TextField(
                                              controller: otpController,
                                              decoration: const InputDecoration(labelText: 'OTP'),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(ctx),
                                                child: const Text('Cancel'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  final otp = otpController.text;
                                                  try {
                                                    await orderService.confirmDelivery(order.id, otp);
                                                    Navigator.pop(ctx);
                                                    // refresh list by rebuilding
                                                    (context as Element).reassemble();
                                                  } catch (e) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Error: $e')),
                                                    );
                                                  }
                                                },
                                                child: const Text('Submit'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: const Text('Confirm'),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 8),
                            ExpansionTile(
                              title: const Text('Items'),
                              children: order.items
                                  .map((item) => ListTile(
                                        title: Text(item.productName),
                                        subtitle: Text('x${item.quantity} - \$${item.price}'),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Please login to view your orders'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: const Text('Login'),
                  ),
                ],
              ),
            ),
    );
  }
}
