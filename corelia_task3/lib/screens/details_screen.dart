import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:corelia_task3/providers/meal_provider.dart';

class MealDetailsPage extends StatelessWidget {
  final Map<String, dynamic> meal;

  const MealDetailsPage({super.key, required this.meal});

  List<String> _getIngredients() {
    List<String> ingredients = [];
    for (int i = 1; i <= 20; i++) {
      String? ingredient = meal['strIngredient$i'];
      String? measure = meal['strMeasure$i'];
      if (ingredient != null && ingredient.isNotEmpty) {
        ingredients.add('${measure ?? ''} $ingredient'.trim());
      } else {
        break;
      }
    }
    return ingredients;
  }

  @override
  Widget build(BuildContext context) {
    final mealProvider = Provider.of<MealProvider>(context);
    final ingredients = _getIngredients();

    return Scaffold(
      appBar: AppBar(
        title: Text(meal['strMeal'] ?? "Meal Details"),
        backgroundColor: Colors.deepOrangeAccent,
        actions: [
          IconButton(
            icon: Icon(
              mealProvider.isFavorite(meal['idMeal']) ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: () {
              mealProvider.toggleFavorite(meal);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                meal['strMealThumb'] ?? "https://via.placeholder.com/250",
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              meal['strMeal'] ?? "Unknown Meal",
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              "Category: ${meal['strCategory']}",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            Text(
              "Origin: ${meal['strArea']}",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 10),
            _buildSectionTitle("Ingredients"),
            if (ingredients.isNotEmpty)
              Column(
                children: ingredients.map((ingredient) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, size: 16, color: Colors.deepOrange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ingredient,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              )
            else
              const Text("No ingredients available.", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            _buildSectionTitle("Instructions"),
            Text(
              meal['strInstructions'] ?? "No instructions available.",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.deepOrange,
        ),
      ),
    );
  }
}