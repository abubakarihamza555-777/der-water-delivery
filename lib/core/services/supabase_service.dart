import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:water_delivery_app/config/supabase_config.dart';
import 'package:water_delivery_app/shared/models/user_model.dart';

class SupabaseService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Getters
  static SupabaseClient get client => _supabase;
  static GoTrueClient get auth => _supabase.auth;

  // Authentication methods
  static Future<Map<String, dynamic>> signIn(
      String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final userData = await _supabase
            .from(SupabaseConfig.usersTable)
            .select()
            .eq('id', response.user!.id)
            .single();

        return {
          'success': true,
          'user': UserModel.fromJson(userData),
          'session': response.session,
        };
      }

      return {'success': false, 'message': 'Login failed'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    String role = 'customer',
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'phone': phone,
          'role': role,
        },
      );

      if (response.user != null) {
        // Create user profile
        final userData = {
          'id': response.user!.id,
          'name': name,
          'email': email,
          'phone': phone,
          'role': role,
          'is_verified': false,
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
        };

        await _supabase.from(SupabaseConfig.usersTable).insert(userData);

        return {
          'success': true,
          'user': UserModel.fromJson(userData),
          'session': response.session,
        };
      }

      return {'success': false, 'message': 'Registration failed'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'No user logged in'};
      }

      final userData = await _supabase
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('id', user.id)
          .single();

      return {
        'success': true,
        'user': UserModel.fromJson(userData),
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Generic CRUD operations
  static Future<List<Map<String, dynamic>>> fetch(
    String table, {
    String? select,
    List<Filter>? filters,
    String? orderBy,
    int? limit,
  }) async {
    try {
      dynamic query = _supabase.from(table).select(select ?? '*');

      if (filters != null) {
        for (final filter in filters) {
          query = query.filter(filter.column, filter.operator, filter.value);
        }
      }

      if (orderBy != null) {
        final parts = orderBy.split(' ');
        query = query.order(parts[0],
            ascending: parts.length == 1 || parts[1] != 'desc');
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final data = await query;
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }

  static Future<Map<String, dynamic>> insert(
      String table, Map<String, dynamic> data) async {
    try {
      final response = await _supabase.from(table).insert(data).select();
      return response.first;
    } catch (e) {
      throw Exception('Failed to insert data: $e');
    }
  }

  static Future<Map<String, dynamic>> update(
    String table,
    Map<String, dynamic> data,
    String idColumn,
    String id,
  ) async {
    try {
      final response =
          await _supabase.from(table).update(data).eq(idColumn, id).select();
      return response.first;
    } catch (e) {
      throw Exception('Failed to update data: $e');
    }
  }

  static Future<void> delete(String table, String idColumn, String id) async {
    try {
      await _supabase.from(table).delete().eq(idColumn, id);
    } catch (e) {
      throw Exception('Failed to delete data: $e');
    }
  }

  // Real-time subscription
  static Stream<List<Map<String, dynamic>>> subscribeToTable(
    String table, {
    String? event,
    List<Filter>? filters,
  }) {
    return _supabase.from(table).stream(primaryKey: ['id']).asBroadcastStream();
  }
}

class Filter {
  final String column;
  final String operator;
  final dynamic value;

  Filter(this.column, this.operator, this.value);
}
