import 'package:flutter/material.dart';
import 'package:water_delivery_app/shared/models/user_model.dart';
import 'package:water_delivery_app/shared/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null && _currentUser != null;
  bool get isCustomer => _currentUser?.isCustomer ?? false;
  bool get isDelivery => _currentUser?.isDelivery ?? false;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  AuthProvider() {
    _loadStoredData();
  }

  Future<void> _loadStoredData() async {
    _token = await _authService.getToken();
    if (_token != null) {
      await fetchCurrentUser();
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.login(email, password);
      if (response['success']) {
        _token = response['token'];
        _currentUser = response['user'];
        _setLoading(false);
        return true;
      } else {
        _error = response['message'];
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String role = 'customer',
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: role,
      );
      if (response['success']) {
        _token = response['token'];
        _currentUser = response['user'];
        _setLoading(false);
        return true;
      } else {
        _error = response['message'];
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<void> fetchCurrentUser() async {
    if (_token == null) return;

    _setLoading(true);
    try {
      final response = await _authService.getCurrentUser();
      if (response['success']) {
        _currentUser = response['user'];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _token = null;
    _currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
