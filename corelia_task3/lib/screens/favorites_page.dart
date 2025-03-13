import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:corelia_task3/providers/meal_provider.dart';
import 'package:corelia_task3/screens/details_screen.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mealProvider = Provider.of<MealProvider>(context);
    final favoriteMeals = mealProvider.favoriteMeals;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorite Meals"),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
      ),
      body: favoriteMeals.isEmpty
          ? const Center(
        child: Text(
          "No favorite meals yet!",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: favoriteMeals.length,
        itemBuilder: (context, index) {
          final meal = favoriteMeals[index];
          final String mealName = meal['strMeal'] ?? "Unknown Meal";
          final String mealImage = meal['strMealThumb'] ?? "https://via.placeholder.com/80";

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MealDetailsPage(meal: meal),
                ),
              );
            },
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Hero(
                  tag: meal['idMeal'],
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      mealImage,
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                title: Text(
                  mealName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "Tap for details",
                  style: TextStyle(color: Colors.grey[600]),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () {
                        mealProvider.toggleFavorite(meal);
                      },
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.deepOrange),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}