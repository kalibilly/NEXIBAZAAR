import 'package:dio/dio.dart';

class ApiClient {
  static const String baseUrl = 'http://localhost:8000/api';
  late Dio _dio;
  String? _token;

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
          return handler.next(options);
        },
        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

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
