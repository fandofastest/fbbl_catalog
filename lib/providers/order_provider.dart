import 'package:flutter/foundation.dart';

import '../models/order_item.dart';
import '../models/product.dart';

class OrderProvider extends ChangeNotifier {
  final Map<String, OrderItem> _items = {};

  List<OrderItem> get items => _items.values.toList();
  bool get hasItems => _items.isNotEmpty;
  int get totalQuantity => _items.values.fold(0, (sum, item) => sum + item.quantity);
  bool contains(Product product) => _items.containsKey(product.id);

  void add(Product product, {int quantity = 1}) {
    if (quantity <= 0) return;
    final current = _items[product.id];
    final updatedQty = (current?.quantity ?? 0) + quantity;
    _items[product.id] = OrderItem(product: product, quantity: updatedQty);
    notifyListeners();
  }

  void setQuantity(Product product, int quantity) {
    if (quantity <= 0) {
      _items.remove(product.id);
    } else {
      _items[product.id] = OrderItem(product: product, quantity: quantity);
    }
    notifyListeners();
  }

  void remove(Product product) {
    _items.remove(product.id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  List<Map<String, dynamic>> toTransactionItems() {
    return _items.values
        .map((item) => {
              'productId': item.product.id,
              'qty': item.quantity,
            })
        .toList();
  }
}
