import 'package:flutter/foundation.dart';

@immutable
class TransactionItemProduct {
  final String id;
  final String name;
  final int price;

  const TransactionItemProduct({
    required this.id,
    required this.name,
    required this.price,
  });

  factory TransactionItemProduct.fromJson(Map<String, dynamic> json) {
    return TransactionItemProduct(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
    );
  }
}

@immutable
class TransactionLine {
  final TransactionItemProduct product;
  final int qty;
  final int price;

  const TransactionLine({
    required this.product,
    required this.qty,
    required this.price,
  });

  factory TransactionLine.fromJson(Map<String, dynamic> json) {
    final prodJson = json['productId'];
    return TransactionLine(
      product: prodJson is Map<String, dynamic>
          ? TransactionItemProduct.fromJson(prodJson)
          : const TransactionItemProduct(id: '', name: '', price: 0),
      qty: (json['qty'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toInt() ?? 0,
    );
  }
}

@immutable
class UserTransaction {
  final String id;
  final String userId;
  final List<TransactionLine> items;
  final int total;
  final String status;

  const UserTransaction({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.status,
  });

  factory UserTransaction.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final parsed = rawItems is List
        ? rawItems
            .whereType<Map>()
            .map((e) => TransactionLine.fromJson(e.cast<String, dynamic>()))
            .toList()
        : <TransactionLine>[];
    return UserTransaction(
      id: json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      items: parsed,
      total: (json['total'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? '',
    );
  }
}
