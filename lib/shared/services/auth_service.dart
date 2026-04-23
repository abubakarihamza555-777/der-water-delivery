import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_delivery_app/shared/models/user_model.dart';
import 'package:water_delivery_app/core/services/supabase_service.dart';

class AuthService {
  static const String _userKey = 'user_data';

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await SupabaseService.signIn(email, password);

      if (response['success']) {
        await saveUser(response['user']);
        return response;
      }
      return response;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String role = 'customer',
  }) async {
    try {
      final response = await SupabaseService.signUp(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: role,
      );

      if (response['success']) {
        await saveUser(response['user']);
        return response;
      }
      return response;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await SupabaseService.getCurrentUser();
      if (response['success']) {
        await saveUser(response['user']);
        return response;
      }
      return response;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<String?> getToken() async {
    try {
      final session = SupabaseService.auth.currentSession;
      return session?.accessToken;
    } catch (e) {
      return null;
    }
  }

  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, user.toJson().toString());
  }

  Future<void> logout() async {
    try {
      await SupabaseService.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
    } catch (e) {
      // Continue with local cleanup even if Supabase logout fails
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
    }
  }
}
