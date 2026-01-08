class ProductCategoryRef {
  final String id;
  final String name;
  final String slug;

  const ProductCategoryRef({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory ProductCategoryRef.fromJson(Map<String, dynamic> json) {
    return ProductCategoryRef(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
    );
  }
}

class Product {
  final String id;
  final String name;
  final String sku;
  final String description;
  final String imageUrl;
  final int price;
  final int stock;
  final ProductCategoryRef category;

  const Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.stock,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final categoryJson = json['categoryId'];
    return Product(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      category: categoryJson is Map<String, dynamic> ? ProductCategoryRef.fromJson(categoryJson) : const ProductCategoryRef(id: '', name: '', slug: ''),
    );
  }
}
