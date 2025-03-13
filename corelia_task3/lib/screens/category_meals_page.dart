import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:corelia_task3/providers/meal_provider.dart';
import 'package:corelia_task3/screens/details_screen.dart';

class CategoryMealsPage extends StatefulWidget {
  final String category;
  const CategoryMealsPage({super.key, required this.category});

  @override
  _CategoryMealsPageState createState() => _CategoryMealsPageState();
}

class _CategoryMealsPageState extends State<CategoryMealsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mealProvider = Provider.of<MealProvider>(context, listen: false);
      mealProvider.fetchMealsByCategory(widget.category);
    });
  }

  Future<void> _refreshMeals() async {
    final mealProvider = Provider.of<MealProvider>(context, listen: false);
    await mealProvider.fetchMealsByCategory(widget.category);
  }

  @override
  Widget build(BuildContext context) {
    final mealProvider = Provider.of<MealProvider>(context);
    final meals = mealProvider.categoryMeals;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} Meals'),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshMeals,
        color: Colors.deepOrange,
        child: mealProvider.isLoadingCategoryMeals
            ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
            : meals.isEmpty
            ? const Center(child: Text('No meals found'))
            : ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: meals.length,
          itemBuilder: (context, index) {
            final meal = meals[index];
            final String mealName = meal['strMeal'] ?? "Unknown Meal";
            final String mealImage = meal['strMealThumb'] ?? "https://via.placeholder.com/80";

            return GestureDetector(
              onTap: () async {
                final fullMealDetails = await mealProvider.fetchMealDetails(meal['idMeal']);
                if (fullMealDetails != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MealDetailsPage(meal: fullMealDetails),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to load meal details'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
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
                        icon: Icon(
                          mealProvider.isFavorite(meal['idMeal'])
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          final fullMealDetails = await mealProvider.fetchMealDetails(meal['idMeal']);
                          if (fullMealDetails != null) {
                            mealProvider.toggleFavorite(fullMealDetails);
                          }
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
      ),
    );
  }
}