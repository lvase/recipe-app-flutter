class Category {
  final String id;
  final String name;
  final String description;
  final String thumbnailUrl;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.thumbnailUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['idCategory'],
      name: json['strCategory'],
      description: json['strCategoryDescription'],
      thumbnailUrl: json['strCategoryThumb'],
    );
  }
}