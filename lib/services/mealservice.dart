import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/meal.dart';
import '../models/recipe.dart';
import '../models/category.dart';

class MealService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1/';


  static Future<List<Category>> fetchCategories() async {
    final url = Uri.parse('${_baseUrl}categories.php');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final List<dynamic> categoriesJson = data['categories'] ?? [];

        return categoriesJson
            .map((json) => Category.fromJson(json))
            .toList();
      } else {
        throw Exception(
          'Failed to load categories (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

 
  static Future<List<Meal>> getMealsByCategory(String category) async {
    final url = Uri.parse('${_baseUrl}filter.php?c=$category');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> mealsJson = data['meals'] ?? [];

        return mealsJson.map((json) => Meal.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load meals (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Failed to load meals: $e');
    }
  }

  static Future<List<Meal>> searchMeals(String query) async {
    final encoded = Uri.encodeComponent(query);
    final url = Uri.parse('${_baseUrl}search.php?s=$encoded');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> mealsJson = data['meals'] ?? [];

        return mealsJson.map((json) => Meal.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to search meals (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Failed to search meals: $e');
    }
  }
  static Future<Recipe?> getRecipeById(String id) async {
    final url = Uri.parse('${_baseUrl}lookup.php?i=$id');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic>? mealsJson = data['meals'];

        if (mealsJson == null || mealsJson.isEmpty) {
          return null;
        }

        return Recipe.fromJson(mealsJson[0]);
      } else {
        throw Exception(
          'Failed to load recipe (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Error loading recipe: $e');
    }
  }

  static Future<Recipe?> getRandomRecipe() async {
    final url = Uri.parse('${_baseUrl}random.php');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic>? mealsJson = data['meals'];

        if (mealsJson == null || mealsJson.isEmpty) {
          return null;
        }

        return Recipe.fromJson(mealsJson[0]);
      } else {
        throw Exception(
          'Failed to load random recipe (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Error loading random recipe: $e');
    }
  }
}
