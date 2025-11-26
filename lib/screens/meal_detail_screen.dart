import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MealDetailScreen extends StatefulWidget {
  final Map<String, dynamic> mealJson;

  const MealDetailScreen({super.key, required this.mealJson});

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  Map<String, dynamic>? _mealDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMealDetails();
  }

  Future<void> _fetchMealDetails() async {
    final id = widget.mealJson['idMeal'];
    final details = await ApiService.fetchMealDetails(id);
    setState(() {
      _mealDetails = details;
      _isLoading = false;
    });
  }

  List<String> _getIngredients(Map<String, dynamic> meal) {
    final ingredients = <String>[];
    for (int i = 1; i <= 20; i++) {
      final ingredient = meal['strIngredient$i'];
      final measure = meal['strMeasure$i'];
      if (ingredient != null && ingredient.isNotEmpty) {
        ingredients.add('$ingredient - $measure');
      }
    }
    return ingredients;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_mealDetails?['strMeal'] ?? 'Loading...'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CachedNetworkImage(
                      imageUrl: _mealDetails!['strMealThumb'],
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _mealDetails!['strMeal'],
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    const Text('Состојки:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    ..._getIngredients(_mealDetails!).map((e) => Text(e)),
                    const SizedBox(height: 16),
                    const Text('Инструкции:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(_mealDetails!['strInstructions']),
                    const SizedBox(height: 16),
                    if (_mealDetails!['strYoutube'] != null && _mealDetails!['strYoutube'].isNotEmpty)
                      ElevatedButton.icon(
                        onPressed: () async {
                          final url = _mealDetails!['strYoutube'];
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url));
                          }
                        },
                        icon: const Icon(Icons.play_circle_fill),
                        label: const Text('Гледај на YouTube'),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
