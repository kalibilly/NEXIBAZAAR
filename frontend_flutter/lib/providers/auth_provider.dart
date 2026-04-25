import 'package:flutter/material.dart';
import '../models/index.dart';
import '../services/index.dart';

class AuthProvider with ChangeNotifier {
  final AuthService authService;
  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  AuthProvider(this.authService);

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isInitialized => _isInitialized;
  bool get isSeller => _user?.accountType == 'seller';
  bool get isCustomer => _user?.accountType == 'customer';

  /// Initialize auth on app startup - restores token and user
  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check if token exists in storage
      if (authService.apiClient.isAuthenticated) {
        // Try to load user profile with existing token
        _user = await authService.getProfile();
        print('✅ User restored from token: ${_user?.username}');
      }
    } catch (e) {
      print('⚠️ Could not restore user: $e');
      authService.apiClient.clearToken();
      _user = null;
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String password2,
    String? firstName,
    String? lastName,
    String accountType = 'customer',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await authService.register(
        username: username,
        email: email,
        password: password,
        password2: password2,
        firstName: firstName,
        lastName: lastName,
        accountType: accountType,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await authService.login(username: username, password: password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> switchToSeller() async {
    if (_user == null) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await authService.updateProfile(accountType: 'seller');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await authService.logout();
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
