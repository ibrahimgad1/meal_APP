import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:corelia_task3/providers/meal_provider.dart';
import 'package:corelia_task3/screens/details_screen.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  List<String> recentSearches = [];

  void _searchMeals(String query) async {
    if (query.isEmpty) return;
    final provider = Provider.of<MealProvider>(context, listen: false);
    await provider.searchMeals(query);
    if (!recentSearches.contains(query)) {
      setState(() {
        recentSearches.insert(0, query);
        if (recentSearches.length > 5) recentSearches.removeLast();
      });
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchMeals(value);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mealProvider = Provider.of<MealProvider>(context);
    final meals = mealProvider.searchedMeals;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Meals"),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Search for a meal...",
                filled: true,
                fillColor: Colors.white,
                prefixIcon: GestureDetector(
                  onTap: () => _searchMeals(_controller.text),
                  child: const Icon(Icons.search, color: Colors.deepOrange),
                ),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _controller.clear();
                    setState(() {});
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              onChanged: _onSearchChanged,
              onSubmitted: _searchMeals,
            ),
          ),
          if (_controller.text.isEmpty && recentSearches.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Recent Searches",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 8,
                    children: recentSearches.map((search) {
                      return GestureDetector(
                        onTap: () {
                          _controller.text = search;
                          _searchMeals(search);
                        },
                        child: Chip(
                          label: Text(search),
                          backgroundColor: Colors.grey.shade200,
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() {
                              recentSearches.remove(search);
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          if (mealProvider.isLoadingSearch)
            const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
          else if (meals.isEmpty && _controller.text.isNotEmpty)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/no_results.jpeg", width: 150),
                  const SizedBox(height: 5),
                  Text(
                    "Try searching for something else!",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: meals.length,
                itemBuilder: (context, index) {
                  final meal = meals[index];
                  final String mealName = meal['strMeal'] ?? "Unknown Meal";
                  final String mealImage = meal['strMealThumb'] ?? "https://via.placeholder.com/100";

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
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Hero(
                          tag: meal['idMeal'],
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              mealImage,
                              height: 60,
                              width: 60,
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
            ),
        ],
      ),
    );
  }
}