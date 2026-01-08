import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api.dart';
import '../models/auth_user.dart';

class AuthService {
  final http.Client _client;

  AuthService({http.Client? client}) : _client = client ?? http.Client();

  Future<({AuthUser user, String token})> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
  }) async {
    final uri = Uri.parse(ApiConfig.url('/api/auth/register'));
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'address': address,
      }),
    );

    if (response.statusCode != 201) {
      final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      final message = body is Map && body['message'] is String ? body['message'] as String : 'Failed to register';
      throw Exception(message);
    }

    final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
    final token = jsonMap['token']?.toString();
    final userJson = jsonMap['user'];
    if (token == null || userJson is! Map<String, dynamic>) {
      throw Exception('Invalid response from server');
    }
    return (user: AuthUser.fromJson(userJson), token: token);
  }

  Future<({AuthUser user, String token})> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse(ApiConfig.url('/api/auth/login'));
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    if (response.statusCode != 200) {
      final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      final message = body is Map && body['message'] is String ? body['message'] as String : 'Failed to login';
      throw Exception(message);
    }
    final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
    final token = jsonMap['token']?.toString();
    final userJson = jsonMap['user'];
    if (token == null || userJson is! Map<String, dynamic>) {
      throw Exception('Invalid response from server');
    }
    return (user: AuthUser.fromJson(userJson), token: token);
  }
}
