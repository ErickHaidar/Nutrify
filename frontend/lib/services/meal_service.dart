import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MealData {
  final String name;
  final int calories;
  final String type;
  final DateTime timestamp;

  MealData({
    required this.name,
    required this.calories,
    required this.type,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'calories': calories,
        'type': type,
        'timestamp': timestamp.toIso8601String(),
      };

  factory MealData.fromJson(Map<String, dynamic> json) => MealData(
        name: json['name'],
        calories: json['calories'],
        type: json['type'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}

class MealService {
  static const String _key = 'meal_history';

  Future<void> saveMeal(MealData meal) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList(_key) ?? [];
    history.add(jsonEncode(meal.toJson()));
    await prefs.setStringList(_key, history);
  }

  Future<List<MealData>> getDailyMeals(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList(_key) ?? [];

    return history.map((e) => MealData.fromJson(jsonDecode(e))).where((meal) {
      return meal.timestamp.year == date.year &&
          meal.timestamp.month == date.month &&
          meal.timestamp.day == date.day;
    }).toList();
  }

  Future<int> getTotalDailyCalories(DateTime date) async {
    final meals = await getDailyMeals(date);
    return meals.fold<int>(0, (sum, meal) => sum + meal.calories);
  }

  Future<int> getCaloriesByType(DateTime date, String type) async {
    final meals = await getDailyMeals(date);
    return meals
        .where((m) => m.type == type)
        .fold<int>(0, (sum, meal) => sum + meal.calories);
  }
}
