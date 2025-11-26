import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import '../widgets/category_card.dart';
import 'category_meals_screen.dart';
import 'meal_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Category>> _categories;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _categories = ApiService.fetchCategories(); // Fetch categories from API
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Категории на јадења'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: () async {
              // Fetch a random meal and navigate to details
              final randomMeal = await ApiService.fetchRandomMeal();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MealDetailScreen(mealJson: randomMeal),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔹 Search field
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Пребарувај категории...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
          ),

          // 🔹 List of categories
          Expanded(
            child: FutureBuilder<List<Category>>(
              future: _categories,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Грешка: ${snapshot.error}'));
                } else {
                  // Filter categories based on search query
                  final categories = snapshot.data!
                      .where((c) => c.name.toLowerCase().contains(searchQuery.toLowerCase()))
                      .toList();

                  return ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      return CategoryCard(
                        category: cat,
                        onTap: () {
                          // Navigate to meals in this category
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CategoryMealsScreen(categoryName: cat.name),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
