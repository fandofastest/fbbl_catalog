class Category {
  final String id;
  final String name;
  final String slug;
  final String imageUrl;

  const Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.imageUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
    );
  }
}
