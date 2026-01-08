import 'package:flutter/material.dart';
import '../models/product.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../config/company.dart';
import '../widgets/product_image.dart';

class ProductDetailArgs {
  final Product product;
  ProductDetailArgs({required this.product});
}

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product_detail';
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  Future<void> _openWhatsApp(Product p) async {
    final message = Uri.encodeComponent('Hello, I would like to request price for ${p.name}.');
    final number = Company.whatsappNumber.replaceAll('+', '');
    final url = Uri.parse('https://wa.me/$number?text=$message');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // fallback to web view
      await launchUrl(url, mode: LaunchMode.platformDefault);
    }
  }

  Future<void> _emailQuote(Product p) async {
    final subject = Uri.encodeComponent('Price request: ${p.name}');
    final body = Uri.encodeComponent('Hello, I would like to request price and availability for:\n\n'
        '- Product: ${p.name}\n- Category: ${p.category}\n- Packaging: ${p.packaging}\n\nThank you.');
    final url = Uri.parse('mailto:${Company.email}?subject=$subject&body=$body');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

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
              assetName: product.image,
              fallbackText: product.name,
              category: product.category,
              borderRadius: BorderRadius.circular(12),
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          Text(product.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(product.category, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 12),
          Text(product.description),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Packaging: ', style: TextStyle(fontWeight: FontWeight.w600)),
              Text(product.packaging),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _openWhatsApp(product),
                  icon: const Icon(Icons.chat),
                  label: const Text('Request Price'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _emailQuote(product),
                  icon: const Icon(Icons.email_outlined),
                  label: const Text('Email Quote'),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                tooltip: 'Share',
                onPressed: () {
                  Share.share('Check this product: ${product.name} (${product.category}) - Packaging: ${product.packaging}');
                },
                icon: const Icon(Icons.share_outlined),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
