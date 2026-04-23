import 'package:water_delivery_app/core/services/api_service.dart';
import 'package:water_delivery_app/features/auth/models/auth_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  
  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await ApiService.post('auth/login', {
        'email': email,
        'password': password,
      });
      
      if (response['success']) {
        final data = response['data'];
        return {
          'success': true,
          'token': data['token'],
          'user': User.fromJson(data['user']),
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
  
  // Register
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    try {
      final response = await ApiService.post('auth/register', {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'role': role,
      });
      
      if (response['success']) {
        final data = response['data'];
        return {
          'success': true,
          'token': data['token'],
          'user': User.fromJson(data['user']),
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
  
  // Get current user
  Future<Map<String, dynamic>> getCurrentUser(String token) async {
    try {
      final response = await ApiService.get('auth/me', token: token);
      
      if (response['success']) {
        return {
          'success': true,
          'user': User.fromJson(response['data']),
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to get user',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
  
  // Update user profile
  Future<Map<String, dynamic>> updateUser({
    required String token,
    String? name,
    String? phone,
    String? profileImage,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;
      if (profileImage != null) data['profileImage'] = profileImage;
      
      final response = await ApiService.put('auth/update', data, token: token);
      
      if (response['success']) {
        return {
          'success': true,
          'user': User.fromJson(response['data']),
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Update failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
  
  // Change password
  Future<Map<String, dynamic>> changePassword({
    required String token,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await ApiService.post('auth/change-password', {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }, token: token);
      
      return {
        'success': response['success'],
        'message': response['message'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
  
  // Reset password
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      final response = await ApiService.post('auth/reset-password', {
        'email': email,
      });
      
      return {
        'success': response['success'],
        'message': response['message'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
  
  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
  
  // Store token locally
  Future<void> storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }
  
  // Get stored token
  Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
  
  // Store user data
  Future<void> storeUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, user.toJson().toString());
  }
  
  // Get stored user
  Future<User?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);
    if (userString != null) {
      // Parse JSON string to Map
      // return User.fromJson(jsonDecode(userString));
    }
    return null;
  }
  
  // Clear all stored data
  Future<void> clearStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
  
  // Check if token is valid
  Future<bool> isTokenValid() async {
    final token = await getStoredToken();
    if (token == null) return false;
    
    try {
      final response = await ApiService.get('auth/verify', token: token);
      return response['success'];
    } catch (e) {
      return false;
    }
  }
}