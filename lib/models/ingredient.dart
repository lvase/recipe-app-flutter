class Ingredient {
  final String name;
  final String measure;
  Ingredient({
    required this.name,
    required this.measure,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'measure': measure,
    };
  }
}