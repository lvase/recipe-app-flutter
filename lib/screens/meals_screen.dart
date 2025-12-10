import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/meal.dart';
import '../services/mealservice.dart';
import 'recipe_detail_screen.dart';

class MealsScreen extends StatefulWidget {
  final Category category;

  const MealsScreen({Key? key, required this.category}) : super(key: key);

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  List<Meal> _meals = [];
  List<Meal> _filteredMeals = [];
  bool _isLoading = true;
  String? _error;
  bool _isSearching = false;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMeals() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final meals = await MealService.getMealsByCategory(widget.category.name);
      if (mounted) {
        setState(() {
          _meals = meals;
          _filteredMeals = meals;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _searchMeals(String query) async {
    if (query.isEmpty) {
      setState(() {
        _filteredMeals = _meals;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _isSearching = true;
      _error = null;
    });

    try {
      final results = await MealService.searchMeals(query);
      if (mounted) {
        setState(() {
          _filteredMeals = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _filteredMeals = _meals;
      _isSearching = false;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search meals...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _isSearching
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        onChanged: _searchMeals,
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: $_error',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMeals,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredMeals.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _isSearching ? 'No meals found' : 'No meals in this category',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            if (_isSearching) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: _clearSearch,
                child: const Text('Clear search'),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMeals,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _filteredMeals.length,
        itemBuilder: (context, index) {
          final meal = _filteredMeals[index];
          return _buildMealCard(meal);
        },
      ),
    );
  }

  Widget _buildMealCard(Meal meal) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RecipeDetailScreen(recipeId: meal.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  meal.thumbnail,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Icon(Icons.broken_image, size: 48));
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                meal.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
