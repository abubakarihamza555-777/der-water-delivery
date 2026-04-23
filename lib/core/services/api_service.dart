import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://api.yourdomain.com';
  static const String apiVersion = 'v1';
  
  // Headers
  static Map<String, String> getHeaders({String? token}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  // GET request
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    String? token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/$apiVersion/$endpoint'),
        headers: getHeaders(token: token),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'error': true, 'message': e.toString()};
    }
  }
  
  // POST request
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data, {
    String? token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/$apiVersion/$endpoint'),
        headers: getHeaders(token: token),
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'error': true, 'message': e.toString()};
    }
  }
  
  // PUT request
  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data, {
    String? token,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/$apiVersion/$endpoint'),
        headers: getHeaders(token: token),
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'error': true, 'message': e.toString()};
    }
  }
  
  // DELETE request
  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    String? token,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/$apiVersion/$endpoint'),
        headers: getHeaders(token: token),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'error': true, 'message': e.toString()};
    }
  }
  
  // Handle response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return {
        'success': true,
        'data': jsonDecode(response.body),
      };
    } else {
      return {
        'error': true,
        'message': 'Server error: ${response.statusCode}',
        'statusCode': response.statusCode,
      };
    }
  }
}
