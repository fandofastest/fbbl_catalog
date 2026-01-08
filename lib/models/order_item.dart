import 'product.dart';

class OrderItem {
  final Product product;
  final int quantity;

  const OrderItem({
    required this.product,
    this.quantity = 1,
  });

  OrderItem copyWith({int? quantity}) {
    return OrderItem(
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }
}
