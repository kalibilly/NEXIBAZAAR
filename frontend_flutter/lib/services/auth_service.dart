import 'package:dio/dio.dart';
import '../models/index.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient apiClient;

  AuthService(this.apiClient);

  Future<User> register({
    required String username,
    required String email,
    required String password,
    required String password2,
    String? firstName,
    String? lastName,
    String accountType = 'customer',
  }) async {
    try {
      final response = await apiClient.post(
        '/users/register/',
        data: {
          'username': username,
          'email': email,
          'password': password,
          'password2': password2,
          'first_name': firstName,
          'last_name': lastName,
          'account_type': accountType,
        },
      );

      if (response.statusCode == 201) {
        final userData = response.data['user'];
        final token = response.data['token'];
        apiClient.setToken(token);
        return User.fromJson({...userData, 'token': token});
      }
      throw Exception('Registration failed');
    } catch (e) {
      rethrow;
    }
  }

  Future<User> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await apiClient.post(
        '/users/login/',
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final userData = response.data['user'];
        final token = response.data['token'];
        apiClient.setToken(token);
        return User.fromJson({...userData, 'token': token});
      }
      throw Exception('Login failed');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await apiClient.post('/users/logout/', data: {});
      apiClient.clearToken();
    } catch (e) {
      apiClient.clearToken();
    }
  }

  Future<User> getProfile() async {
    try {
      final response = await apiClient.get('/users/profile/');
      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      }
      throw Exception('Failed to load profile');
    } catch (e) {
      rethrow;
    }
  }

  Future<User> updateProfile({
    String? email,
    String? firstName,
    String? lastName,
    String? accountType,
  }) async {
    try {
      final response = await apiClient.put(
        '/users/update_profile/',
        data: {
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          if (accountType != null) 'account_type': accountType,
        },
      );

      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      }
      throw Exception('Failed to update profile');
    } catch (e) {
      rethrow;
    }
  }
}
