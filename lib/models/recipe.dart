import 'package:recipe_app/models/ingredient.dart';

class Recipe {
  final String id;
  final String name;
  final String category;
  final String area;
  final String instructions;
  final  String thumbnail;
  final String? youtubeUrl;
  final List<Ingredient> ingredients;
  Recipe({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.instructions,
    required this.thumbnail,
    this.youtubeUrl,
    required this.ingredients,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    List<Ingredient> ingredients = [];

    for (int i = 1; i<=20; i++) {
      final ingredient = json['stiIngredient$i'];
      final measure = json['strMeasure$i'];

      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        ingredients.add(Ingredient(
          name: ingredient.toString().trim(),
          measure: measure?.toString().trim() ?? '',
        ));
      }
    }
    return Recipe(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? '',
      category: json['strCategory'] ?? '',
      area: json['strArea'] ?? '',
      instructions: json['strInstructions'] ?? '',
      thumbnail: json['strMealThumb'] ?? '',
      youtubeUrl: json['strYoutube'],
      ingredients: ingredients
    );

  }

  Map<String, dynamic> toJson() {
    return {
      'idMeal': id,
      'strMeal': name,
      'strCategory': category,
      'strArea': area,
      'strInstructions': instructions,
      'strMealThumb': thumbnail,
      'strYoutube': youtubeUrl,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
    };
  } 
}