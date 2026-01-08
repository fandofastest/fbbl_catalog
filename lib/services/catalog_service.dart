import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api.dart';
import '../models/category.dart';
import '../models/product.dart';

class CatalogService {
  final http.Client _client;

  CatalogService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Category>> fetchCategories({String? query}) async {
    final uri = Uri.parse(ApiConfig.url('/api/public/categories')).replace(
      queryParameters: {
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
      },
    );

    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      dynamic decoded;
      if (res.body.isNotEmpty) {
        try {
          decoded = jsonDecode(res.body);
        } catch (_) {
          decoded = null;
        }
      }
      final message = decoded is Map && decoded['message'] is String
          ? decoded['message'] as String
          : 'Failed to load categories (HTTP ${res.statusCode})';
      throw Exception(message);
    }

    late final Map<String, dynamic> jsonMap;
    try {
      jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      final snippet = res.body.length > 160 ? res.body.substring(0, 160) : res.body;
      throw Exception('Invalid categories response from server. Body: $snippet');
    }
    final items = jsonMap['items'];
    if (items is! List) return [];
    return items
        .whereType<Map>()
        .map((e) => Category.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  Future<List<Product>> fetchProducts({String? query, String? categoryId}) async {
    final uri = Uri.parse(ApiConfig.url('/api/public/products')).replace(
      queryParameters: {
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        if (categoryId != null && categoryId.trim().isNotEmpty) 'categoryId': categoryId.trim(),
      },
    );

    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      dynamic decoded;
      if (res.body.isNotEmpty) {
        try {
          decoded = jsonDecode(res.body);
        } catch (_) {
          decoded = null;
        }
      }
      final message = decoded is Map && decoded['message'] is String
          ? decoded['message'] as String
          : 'Failed to load products (HTTP ${res.statusCode})';
      throw Exception(message);
    }

    late final Map<String, dynamic> jsonMap;
    try {
      jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      final snippet = res.body.length > 160 ? res.body.substring(0, 160) : res.body;
      throw Exception('Invalid products response from server. Body: $snippet');
    }
    final items = jsonMap['items'];
    if (items is! List) return [];
    return items
        .whereType<Map>()
        .map((e) => Product.fromJson(e.cast<String, dynamic>()))
        .toList();
  }
}
