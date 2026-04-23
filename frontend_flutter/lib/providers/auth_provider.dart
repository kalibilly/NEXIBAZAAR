import 'package:flutter/material.dart';
import '../models/index.dart';
import '../services/index.dart';

class AuthProvider with ChangeNotifier {
  final AuthService authService;
  User? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this.authService);

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isSeller => _user?.accountType == 'seller';
  bool get isCustomer => _user?.accountType == 'customer';

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
