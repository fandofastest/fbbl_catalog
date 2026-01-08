import 'package:flutter/foundation.dart';

import '../models/category.dart' as catalog;
import '../services/catalog_service.dart';

class CategoryProvider extends ChangeNotifier {
  final CatalogService _service;
  CategoryProvider(this._service);

  List<catalog.Category> _categories = [];
  bool _loading = false;
  String? _error;

  List<catalog.Category> get categories => _categories;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load({String? query}) async {
    if (_loading) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _categories = await _service.fetchCategories(query: query);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
