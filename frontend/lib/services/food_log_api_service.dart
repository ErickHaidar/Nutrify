import 'package:boilerplate/services/food_api_service.dart';
import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/di/service_locator.dart';

class MealNutrition {
  final double calories;
  final double protein;
  final double carbohydrates;
  final double fat;

  MealNutrition({
    this.calories = 0,
    this.protein = 0,
    this.carbohydrates = 0,
    this.fat = 0,
  });

  factory MealNutrition.fromJson(Map<String, dynamic> json) => MealNutrition(
    calories: (json['total_calories'] as num?)?.toDouble() ?? 0,
    protein: (json['total_protein'] as num?)?.toDouble() ?? 0,
    carbohydrates: (json['total_carbohydrates'] as num?)?.toDouble() ?? 0,
    fat: (json['total_fat'] as num?)?.toDouble() ?? 0,
  );

  static MealNutrition empty() => MealNutrition();
}

class DailySummary {
  final Map<String, MealNutrition> byMeal;
  final MealNutrition totals;
  final int targetCalories;

  DailySummary({
    required this.byMeal,
    required this.totals,
    this.targetCalories = 0,
  });

  int get totalCaloriesInt => totals.calories.round();

  int caloriesForMeal(String mealTime) =>
      (byMeal[mealTime]?.calories ?? 0).round();

  static DailySummary empty() =>
      DailySummary(byMeal: {}, totals: MealNutrition.empty());
}

class FoodLogApiService {
  DioClient get _dio => getIt<DioClient>();

  Future<void> logFood({
    required int foodId,
    required double servingMultiplier,
    required String mealTime, // 'Breakfast' | 'Lunch' | 'Dinner' | 'Snack'
    String? unit,
    DateTime? date,
  }) async {
    final dateStr = (date ?? DateTime.now()).toIso8601String().split('T')[0];
    await _dio.dio.post(
      Endpoints.foodLogs,
      data: {
        'food_id': foodId,
        'serving_multiplier': servingMultiplier,
        'meal_time': mealTime,
        'unit': unit,
        'date': dateStr,
      },
    );
  }

  Future<DailySummary> getSummary(DateTime date) async {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final res = await _dio.dio.get(
      Endpoints.foodLogsSummary,
      queryParameters: {'date': dateStr},
    );
    final Map<String, dynamic> totalsRaw = res.data['totals'] ?? {};
    final byMealData = res.data['by_meal'];
    final Map<String, MealNutrition> byMeal = (byMealData is Map)
        ? (byMealData as Map<String, dynamic>).map(
            (k, v) =>
                MapEntry(k, MealNutrition.fromJson(v as Map<String, dynamic>)),
          )
        : {};

    return DailySummary(
      byMeal: byMeal,
      totals: MealNutrition.fromJson(totalsRaw),
      targetCalories: (res.data['target_calories'] as num?)?.toInt() ?? 0,
    );
  }

  Future<void> deleteLog(int id) async {
    await _dio.dio.delete('${Endpoints.foodLogs}/$id');
  }

  /// Fetches individual food log entries for a given date.
  Future<List<FoodLogEntry>> getLogs(DateTime date) async {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final res = await _dio.dio.get(
      Endpoints.foodLogs,
      queryParameters: {'date': dateStr},
    );
    final List<dynamic> data = res.data['data'] ?? [];
    return data
        .map((e) => FoodLogEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<FoodLogEntry> getLogById(int id) async {
    final res = await _dio.dio.get('${Endpoints.foodLogs}/$id');
    return FoodLogEntry.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<void> updateLog(
    int id, {
    required double servingMultiplier,
    required String mealTime,
    String? unit,
  }) async {
    await _dio.dio.put(
      '${Endpoints.foodLogs}/$id',
      data: {
        'serving_multiplier': servingMultiplier,
        'meal_time': mealTime,
        'unit': unit,
      },
    );
  }
}

class FoodLogEntry {
  final int id;
  final int foodId;
  final String foodName;
  final String servingSize;
  final String mealTime;
  final double servingMultiplier;
  final double calories;
  final double protein;
  final double carbohydrates;
  final double fat;
  final double sugar;
  final double sodium;
  final double fiber;
  final String unit;
  final FoodItem? food;

  FoodLogEntry({
    required this.id,
    required this.foodId,
    required this.foodName,
    required this.servingSize,
    required this.mealTime,
    required this.servingMultiplier,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    this.unit = 'Gram(g)',
    this.sugar = 0,
    this.sodium = 0,
    this.fiber = 0,
    this.food,
  });

  factory FoodLogEntry.fromJson(Map<String, dynamic> json) {
    final foodRaw = json['food'] as Map<String, dynamic>?;
    final foodItem = foodRaw != null ? FoodItem.fromJson(foodRaw) : null;
    final food = foodRaw ?? {};
    final multRaw = json['serving_multiplier'];
    double mult = 1.0;
    if (multRaw is num) {
      mult = multRaw.toDouble();
    } else if (multRaw is String) {
      mult = double.tryParse(multRaw) ?? 1.0;
    }
    
    return FoodLogEntry(
      id: json['id'] as int,
      foodId: food['id'] as int? ?? 0,
      foodName: food['name'] as String? ?? 'Unknown',
      servingSize: food['serving_size'] as String? ?? '100g',
      mealTime: json['meal_time'] as String? ?? 'Breakfast',
      servingMultiplier: mult,
      calories: ((food['calories'] as num?)?.toDouble() ?? 0) * mult,
      protein: ((food['protein'] as num?)?.toDouble() ?? 0) * mult,
      carbohydrates: ((food['carbohydrates'] as num?)?.toDouble() ?? 0) * mult,
      fat: ((food['fat'] as num?)?.toDouble() ?? 0) * mult,
      sugar: ((food['sugar'] as num?)?.toDouble() ?? 0) * mult,
      sodium: ((food['sodium'] as num?)?.toDouble() ?? 0) * mult,
      fiber: ((food['fiber'] as num?)?.toDouble() ?? 0) * mult,
      unit: json['unit'] as String? ?? 'Gram(g)',
      food: foodItem,
    );
  }
}
