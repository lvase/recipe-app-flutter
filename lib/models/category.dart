

class Category {
  final String id;
  final String name;
  final String description;
  final String thumbnail;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.thumbnail,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['idCategory'] ?? '',
      name: json['strCategory'] ?? '',
      description: json['strCategoryDescription'] ?? '',
      thumbnail: json['strCategoryThumb'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idCategory': id,
      'strCategory': name,
      'strCategoryDescription': description,
      'strCategoryThumb': thumbnail,
    };
  }
}
