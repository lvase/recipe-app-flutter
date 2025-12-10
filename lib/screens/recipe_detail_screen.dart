import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/recipe.dart';
import '../services/mealservice.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String recipeId;

  const RecipeDetailScreen({Key? key, required this.recipeId})
      : super(key: key);

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  Recipe? _recipe;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecipe();
  }

  Future<void> _loadRecipe() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final recipe = await MealService.getRecipeById(widget.recipeId);
      if (mounted) {
        setState(() {
          _recipe = recipe;
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

  Future<void> _openYouTube(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open YouTube')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
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
            Text('Error: $_error', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadRecipe, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_recipe == null) {
      return const Center(child: Text('Recipe not found'));
    }

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              _recipe!.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(offset: Offset(0, 1), blurRadius: 3, color: Colors.black45),
                ],
              ),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(_recipe!.thumbnail, fit: BoxFit.cover),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black54],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBadges(),
              if (_recipe!.youtubeUrl != null) _buildYouTubeButton(),
              _buildIngredientsSection(),
              _buildInstructionsSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadges() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          _buildBadge(_recipe!.category, Colors.orange, Icons.restaurant),
          const SizedBox(width: 8),
          _buildBadge(_recipe!.area, Colors.blue, Icons.public),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildYouTubeButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _openYouTube(_recipe!.youtubeUrl!),
          icon: const Icon(Icons.play_circle_filled),
          label: const Text('Watch on YouTube'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientsSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ingredients', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: _recipe!.ingredients.map((ingredient) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle)),
                        const SizedBox(width: 12),
                        Expanded(child: Text('${ingredient.measure} ${ingredient.name}', style: const TextStyle(fontSize: 16))),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Instructions', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(_recipe!.instructions, style: const TextStyle(fontSize: 16, height: 1.6)),
            ),
          ),
        ],
      ),
    );
  }
}
