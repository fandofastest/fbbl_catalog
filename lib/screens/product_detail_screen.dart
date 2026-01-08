import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_image.dart';
import '../providers/order_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class ProductDetailArgs {
  final Product product;
  ProductDetailArgs({required this.product});
}

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product_detail';
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ProductImage(
              assetName: product.imageUrl,
              fallbackText: product.name,
              category: product.category.name,
              borderRadius: BorderRadius.circular(12),
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          Text(product.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(product.category.name, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('£${product.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(width: 12),
              Text('Stock: ${product.stock}', style: const TextStyle(color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 12),
          Text(product.description),
          const SizedBox(height: 12),
          const SizedBox(height: 24),
          Consumer<OrderProvider>(
            builder: (context, orders, _) {
              final inCart = orders.items.any((item) => item.product.id == product.id);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            orders.add(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${product.name} added to order')),
                            );
                          },
                          icon: Icon(inCart ? Icons.done : Icons.add_shopping_cart_outlined),
                          label: Text(inCart ? 'Added' : 'Add to Order'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        tooltip: 'Share',
                        onPressed: () {
                          Share.share('Check this product: ${product.name} (${product.category.name})');
                        },
                        icon: const Icon(Icons.share_outlined),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
