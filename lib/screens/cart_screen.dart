import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../services/transaction_service.dart';
import 'auth_screen.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';
  const CartScreen({super.key});

  Future<void> _placeOrder(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final orders = context.read<OrderProvider>();
    if (!orders.hasItems) return;

    if (auth.token == null) {
      await Navigator.of(context).pushNamed(AuthScreen.routeName);
      if (!context.mounted) return;
      if (context.read<AuthProvider>().token == null) return;
    }

    final token = context.read<AuthProvider>().token!;
    final payload = orders.toTransactionItems();

    try {
      final res = await TransactionService().createTransaction(token: token, items: payload);
      final item = res['item'];
      final total = item is Map ? item['total'] : null;
      final status = item is Map ? item['status'] : null;

      orders.clear();

      final totalText = total is num ? ' • Total: £${(total / 100).toStringAsFixed(2)}' : '';
      final statusText = status != null ? ' • Status: $status' : '';
      final message = 'Order placed$totalText$statusText';
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      Navigator.of(context).pop();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>();

    final items = orders.items;
    final totalPence = items.fold<int>(0, (sum, item) => sum + (item.product.price * item.quantity));

    return Scaffold(
      appBar: AppBar(title: const Text('Basket')),
      body: items.isEmpty
          ? const Center(child: Text('Your basket is empty'))
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final price = item.product.price;
                      final lineTotal = price * item.quantity;
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.product.name,
                                      style: const TextStyle(fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Remove',
                                    onPressed: () => context.read<OrderProvider>().remove(item.product),
                                    icon: const Icon(Icons.delete_outline),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text('£${(price / 100).toStringAsFixed(2)}'),
                                  const SizedBox(width: 10),
                                  Text('Stock: ${item.product.stock}', style: const TextStyle(color: Colors.black54)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: item.quantity <= 1
                                        ? null
                                        : () => context.read<OrderProvider>().setQuantity(item.product, item.quantity - 1),
                                    icon: const Icon(Icons.remove_circle_outline),
                                  ),
                                  Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w700)),
                                  IconButton(
                                    onPressed: () => context.read<OrderProvider>().setQuantity(item.product, item.quantity + 1),
                                    icon: const Icon(Icons.add_circle_outline),
                                  ),
                                  const Spacer(),
                                  Text('Line total: £${(lineTotal / 100).toStringAsFixed(2)}'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.4)),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Text('Total', style: TextStyle(fontWeight: FontWeight.w700)),
                            const Spacer(),
                            Text('£${(totalPence / 100).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () => _placeOrder(context),
                          icon: const Icon(Icons.shopping_cart_checkout),
                          label: const Text('Place order'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
