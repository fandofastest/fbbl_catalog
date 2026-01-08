import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api.dart';
import '../models/transaction.dart';

class TransactionService {
  final http.Client _client;

  TransactionService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> createTransaction({
    required String token,
    required List<Map<String, dynamic>> items,
  }) async {
    final uri = Uri.parse(ApiConfig.url('/api/me/transaksi'));
    final res = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'items': items}),
    );

    if (res.statusCode != 201) {
      final body = res.body.isNotEmpty ? jsonDecode(res.body) : null;
      final message = body is Map && body['message'] is String ? body['message'] as String : 'Failed to create transaction';
      throw Exception(message);
    }

    final jsonMap = jsonDecode(res.body);
    if (jsonMap is Map<String, dynamic>) return jsonMap;
    throw Exception('Invalid response from server');
  }

  Future<List<UserTransaction>> fetchMyTransactions({
    required String token,
  }) async {
    final uri = Uri.parse(ApiConfig.url('/api/me/transaksi'));
    final res = await _client.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200) {
      final body = res.body.isNotEmpty ? jsonDecode(res.body) : null;
      final message = body is Map && body['message'] is String ? body['message'] as String : 'Failed to load transactions';
      throw Exception(message);
    }

    final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
    final items = jsonMap['items'];
    if (items is! List) return [];
    return items
        .whereType<Map>()
        .map((e) => UserTransaction.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  Future<Map<String, dynamic>> cancelTransaction({
    required String token,
    required String id,
  }) async {
    final uri = Uri.parse(ApiConfig.url('/api/me/transaksi/$id/cancel'));
    final res = await _client.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200) {
      final body = res.body.isNotEmpty ? jsonDecode(res.body) : null;
      final message = body is Map && body['message'] is String ? body['message'] as String : 'Failed to cancel transaction';
      throw Exception(message);
    }

    final jsonMap = jsonDecode(res.body);
    if (jsonMap is Map<String, dynamic>) return jsonMap;
    throw Exception('Invalid response from server');
  }
}
