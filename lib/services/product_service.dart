import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/product.dart';

class ProductService {
  static const String _assetPath = 'assets/data/products.json';

  Future<List<Product>> loadProducts() async {
    final jsonStr = await rootBundle.loadString(_assetPath);
    final List<dynamic> data = jsonDecode(jsonStr) as List<dynamic>;
    return data.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }
}
