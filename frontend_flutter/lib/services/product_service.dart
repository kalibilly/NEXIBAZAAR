import 'package:dio/dio.dart';
import '../models/index.dart';
import 'api_client.dart';

class ProductService {
  final ApiClient apiClient;

  ProductService(this.apiClient);

  Future<List<Product>> getProducts({
    int? page,
    String? search,
    String? ordering,
    int? category,
  }) async {
    try {
      final response = await apiClient.get(
        '/products/',
        queryParameters: {
          if (page != null) 'page': page,
          if (search != null) 'search': search,
          if (ordering != null) 'ordering': ordering,
          if (category != null) 'category': category,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> results = response.data['results'] ?? response.data;
        return results.map((json) => Product.fromJson(json)).toList();
      }
      throw Exception('Failed to load products');
    } catch (e) {
      rethrow;
    }
  }

  Future<Product> getProduct(int id) async {
    try {
      final response = await apiClient.get('/products/$id/');
      if (response.statusCode == 200) {
        return Product.fromJson(response.data);
      }
      throw Exception('Failed to load product');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Product>> getFeaturedProducts() async {
    try {
      final response = await apiClient.get('/products/featured/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Product.fromJson(json)).toList();
      }
      throw Exception('Failed to load featured products');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Category>> getCategories() async {
    try {
      final response = await apiClient.get('/categories/');
      if (response.statusCode == 200) {
        final List<dynamic> results = response.data['results'] ?? response.data;
        return results.map((json) => Category.fromJson(json)).toList();
      }
      throw Exception('Failed to load categories');
    } catch (e) {
      rethrow;
    }
  }

  Future<Category> getCategory(int id) async {
    try {
      final response = await apiClient.get('/categories/$id/');
      if (response.statusCode == 200) {
        return Category.fromJson(response.data);
      }
      throw Exception('Failed to load category');
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getProductsByCategory() async {
    try {
      final response = await apiClient.get('/products/by_category/');
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to load products by category');
    } catch (e) {
      rethrow;
    }
  }
}
