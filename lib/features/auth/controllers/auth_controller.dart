import 'package:flutter/material.dart';
import 'package:water_delivery_app/features/auth/models/auth_model.dart';
import 'package:water_delivery_app/features/auth/services/auth_service.dart';
import 'package:water_delivery_app/core/services/navigation_service.dart';
import 'package:water_delivery_app/config/routes/app_routes.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  // State variables
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;
  String? _authToken;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  String? get authToken => _authToken;
  bool get isLoggedIn => _authToken != null && _currentUser != null;
  
  // Constructor
  AuthController() {
    _checkAuthStatus();
  }
  
  // Check if user is already logged in
  Future<void> _checkAuthStatus() async {
    final token = await _authService.getStoredToken();
    if (token != null) {
      _authToken = token;
      await fetchCurrentUser();
    }
  }
  
  // Login user
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _authService.login(email, password);
      
      if (response['success']) {
        _authToken = response['token'];
        _currentUser = response['user'];
        
        // Store token
        await _authService.storeToken(_authToken!);
        await _authService.storeUser(_currentUser!);
        
        _setLoading(false);
        
        // Navigate based on role
        _navigateByRole(_currentUser!.role);
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Login failed';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }
  
  // Register user
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
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
        _authToken = response['token'];
        _currentUser = response['user'];
        
        // Store token
        await _authService.storeToken(_authToken!);
        await _authService.storeUser(_currentUser!);
        
        _setLoading(false);
        
        // Navigate based on role
        _navigateByRole(_currentUser!.role);
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Registration failed';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }
  
  // Logout user
  Future<void> logout(BuildContext context) async {
    await _authService.logout();
    _authToken = null;
    _currentUser = null;
    await _authService.clearStoredData();
    NavigationService.navigateAndRemoveUntil(AppRoutes.login);
  }
  
  // Fetch current user
  Future<void> fetchCurrentUser() async {
    _setLoading(true);
    
    try {
      final response = await _authService.getCurrentUser(_authToken!);
      if (response['success']) {
        _currentUser = response['user'];
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }
  
  // Update user profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? profileImage,
  }) async {
    _setLoading(true);
    
    try {
      final response = await _authService.updateUser(
        token: _authToken!,
        name: name,
        phone: phone,
        profileImage: profileImage,
      );
      
      if (response['success']) {
        _currentUser = response['user'];
        await _authService.storeUser(_currentUser!);
        _setLoading(false);
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Update failed';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }
  
  // Change password
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    
    try {
      final response = await _authService.changePassword(
        token: _authToken!,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      
      _setLoading(false);
      
      if (response['success']) {
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Password change failed';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }
  
  // Reset password
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    
    try {
      final response = await _authService.resetPassword(email);
      _setLoading(false);
      return response['success'];
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }
  
  // Navigate by role
  void _navigateByRole(String role) {
    switch (role) {
      case 'customer':
        NavigationService.navigateAndRemoveUntil(AppRoutes.customerHome);
        break;
      case 'delivery':
        NavigationService.navigateAndRemoveUntil(AppRoutes.deliveryDashboard);
        break;
      case 'admin':
        NavigationService.navigateAndRemoveUntil(AppRoutes.adminDashboard);
        break;
      default:
        NavigationService.navigateAndRemoveUntil(AppRoutes.customerHome);
    }
  }
  
  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}