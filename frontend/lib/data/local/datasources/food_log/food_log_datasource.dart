import 'package:nutrify/core/data/local/sembast/sembast_client.dart';
import 'package:nutrify/services/food_log_api_service.dart';
import 'package:sembast/sembast.dart';

class FoodLogDataSource {
  final _summaryStore = stringMapStoreFactory.store('food_log_summary');
  final SembastClient _sembastClient;

  FoodLogDataSource(this._sembastClient);

  Future<void> saveSummary(DateTime date, DailySummary summary) async {
    final dateStr = date.toIso8601String().split('T')[0];
    await _summaryStore.record(dateStr).put(_sembastClient.database, _summaryToMap(summary));
  }

  Future<DailySummary?> getSummary(DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final map = await _summaryStore.record(dateStr).get(_sembastClient.database);
    if (map == null) return null;
    return _mapToSummary(map);
  }

  Map<String, dynamic> _summaryToMap(DailySummary summary) {
    return {
      'target_calories': summary.targetCalories,
      'totals': _nutritionToMap(summary.totals),
      'by_meal': summary.byMeal.map((k, v) => MapEntry(k, _nutritionToMap(v))),
    };
  }

  DailySummary _mapToSummary(Map<String, dynamic> map) {
    final totalsRaw = map['totals'] as Map<String, dynamic>;
    final byMealRaw = map['by_meal'] as Map<String, dynamic>;
    
    return DailySummary(
      targetCalories: map['target_calories'] as int,
      totals: _mapToNutrition(totalsRaw),
      byMeal: byMealRaw.map((k, v) => MapEntry(k, _mapToNutrition(v as Map<String, dynamic>))),
    );
  }

  Map<String, dynamic> _nutritionToMap(MealNutrition nutrition) {
    return {
      'total_calories': nutrition.calories,
      'total_protein': nutrition.protein,
      'total_carbohydrates': nutrition.carbohydrates,
      'total_fat': nutrition.fat,
    };
  }

  MealNutrition _mapToNutrition(Map<String, dynamic> map) {
    return MealNutrition(
      calories: (map['total_calories'] as num).toDouble(),
      protein: (map['total_protein'] as num).toDouble(),
      carbohydrates: (map['total_carbohydrates'] as num).toDouble(),
      fat: (map['total_fat'] as num).toDouble(),
    );
  }
}
