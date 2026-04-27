import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String baseUrl = 'https://nexibazaar.onrender.com/api';
  static const String _tokenKey = 'auth_token';
  
  late Dio _dio;
  String? _token;
  late SharedPreferences _prefs;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        responseType: ResponseType.json,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_token != null) {
            options.headers['Authorization'] = 'Token $_token';
          }
          options.headers['Content-Type'] = 'application/json';
          print('🔗 API Request: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onError: (error, handler) {
          print('❌ API Error: ${error.message}');
          return handler.next(error);
        },
        onResponse: (response, handler) {
          print('✅ API Response: ${response.statusCode} ${response.requestOptions.path}');
          return handler.next(response);
        },
      ),
    );
  }

  /// Initialize shared preferences - call this once on app startup
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _token = _prefs.getString(_tokenKey);
    if (_token != null) {
      print('🔑 Token restored from storage: ${_token!.substring(0, 10)}...');
    }
  }

  void setToken(String token) {
    _token = token;
    _prefs.setString(_tokenKey, token);
    print('💾 Token saved to storage');
  }

  void clearToken() {
    _token = null;
    _prefs.remove(_tokenKey);
    print('🗑️ Token cleared');
  }

  String? getToken() => _token;
  bool get isAuthenticated => _token != null;

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {required dynamic data}) {
    return _dio.post(path, data: data);
  }

  Future<Response> put(String path, {required dynamic data}) {
    return _dio.put(path, data: data);
  }

  Future<Response> patch(String path, {required dynamic data}) {
    return _dio.patch(path, data: data);
  }

  Future<Response> delete(String path) {
    return _dio.delete(path);
  }
}
