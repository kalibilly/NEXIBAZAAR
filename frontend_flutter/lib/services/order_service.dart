import 'package:dio/dio.dart';
import '../models/index.dart';
import 'api_client.dart';

class OrderService {
  final ApiClient apiClient;

  OrderService(this.apiClient);

  Future<List<Order>> getMyOrders() async {
    try {
      final response = await apiClient.get('/orders/my_orders/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Order.fromJson(json)).toList();
      }
      throw Exception('Failed to load orders');
    } catch (e) {
      rethrow;
    }
  }

  Future<Order> getOrder(int id) async {
    try {
      final response = await apiClient.get('/orders/$id/');
      if (response.statusCode == 200) {
        return Order.fromJson(response.data);
      }
      throw Exception('Failed to load order');
    } catch (e) {
      rethrow;
    }
  }

  Future<Order> createOrder({
    required String shippingAddress,
    required String phone,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final response = await apiClient.post(
        '/orders/',
        data: {
          'shipping_address': shippingAddress,
          'phone': phone,
          'items': items,
        },
      );

      if (response.statusCode == 201) {
        return Order.fromJson(response.data);
      }
      throw Exception('Failed to create order');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateOrderStatus(int orderId, String status) async {
    try {
      final response = await apiClient.patch(
        '/orders/$orderId/update_status/',
        data: {'status': status},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update order status');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> confirmDelivery(int orderId, String otp) async {
    try {
      final response = await apiClient.post(
        '/orders/$orderId/confirm_delivery/',
        data: {'otp': otp},
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to confirm delivery');
      }
    } catch (e) {
      rethrow;
    }
  }
}
