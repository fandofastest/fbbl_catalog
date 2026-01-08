class Product {
  final int id;
  final String name;
  final String category;
  final String description;
  final String packaging;
  final String image; // asset file name inside assets/images/
  final List<String> tags; // e.g., ["new", "best"]

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.packaging,
    required this.image,
    this.tags = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawTags = json['tags'];
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      packaging: json['packaging'] as String,
      image: json['image'] as String,
      tags: rawTags is List ? rawTags.map((e) => e.toString()).toList() : const [],
    );
  }
}
