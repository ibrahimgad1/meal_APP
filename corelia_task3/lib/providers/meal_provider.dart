import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MealProvider with ChangeNotifier {
  Map<String, dynamic>? randomMeal;
  List<dynamic> categories = [];
  List<dynamic> suggestedMeals = [];
  List<dynamic> categoryMeals = [];
  List<dynamic> searchedMeals = [];
  List<Map<String, dynamic>> favoriteMeals = []; // New list for favorites

  bool isLoadingRandomMeal = false;
  bool isLoadingCategories = false;
  bool isLoadingSuggestedMeals = false;
  bool isLoadingCategoryMeals = false;
  bool isLoadingSearch = false;

  /// Reusable method to fetch data from API
  Future<Map<String, dynamic>?> _fetchData(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching data from $url: $e');
      return null;
    }
  }

  /// Fetch a random meal
  Future<void> fetchRandomMeal() async {
    isLoadingRandomMeal = true;
    notifyListeners();

    final data = await _fetchData("https://www.themealdb.com/api/json/v1/1/random.php");
    if (data != null && data['meals'] != null) {
      randomMeal = data['meals'][0];
    }

    isLoadingRandomMeal = false;
    notifyListeners();
  }

  /// Fetch categories
  Future<void> fetchCategories() async {
    isLoadingCategories = true;
    notifyListeners();

    final data = await _fetchData("https://www.themealdb.com/api/json/v1/1/categories.php");
    if (data != null && data['categories'] != null) {
      categories = data['categories'];
    }

    isLoadingCategories = false;
    notifyListeners();
  }

  /// Fetch suggested meals
  Future<void> fetchSuggestedMeals() async {
    isLoadingSuggestedMeals = true;
    notifyListeners();

    suggestedMeals.clear();
    const url = "https://www.themealdb.com/api/json/v1/1/random.php";
    final requests = List.generate(4, (_) => http.get(Uri.parse(url)));
    final responses = await Future.wait(requests);

    for (var response in responses) {
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null) {
          suggestedMeals.add(data['meals'][0]);
        }
      }
    }

    isLoadingSuggestedMeals = false;
    notifyListeners();
  }

  /// Fetch meals by category
  Future<void> fetchMealsByCategory(String category) async {
    isLoadingCategoryMeals = true;
    notifyListeners();

    final data = await _fetchData("https://www.themealdb.com/api/json/v1/1/filter.php?c=$category");
    categoryMeals = data?['meals'] ?? [];

    isLoadingCategoryMeals = false;
    notifyListeners();
  }

  /// Search meals by name
  Future<void> searchMeals(String query) async {
    isLoadingSearch = true;
    notifyListeners();

    final data = await _fetchData("https://www.themealdb.com/api/json/v1/1/search.php?s=$query");
    searchedMeals = data?['meals'] ?? [];

    isLoadingSearch = false;
    notifyListeners();
  }

  /// Fetch full meal details by ID
  Future<Map<String, dynamic>?> fetchMealDetails(String mealId) async {
    final data = await _fetchData("https://www.themealdb.com/api/json/v1/1/lookup.php?i=$mealId");
    return data?['meals']?.first;
  }

  /// Check if a meal is favorited
  bool isFavorite(String mealId) {
    return favoriteMeals.any((meal) => meal['idMeal'] == mealId);
  }

  ///  favorite status for a meal
  void toggleFavorite(Map<String, dynamic> meal) {
    final mealId = meal['idMeal'];
    if (isFavorite(mealId)) {
      favoriteMeals.removeWhere((m) => m['idMeal'] == mealId);
    } else {
      favoriteMeals.add(meal);
    }
    notifyListeners();
  }
}