import 'package:nutrify/services/food_log_api_service.dart';

abstract class FoodLogRepository {
  Future<DailySummary> getSummary(DateTime date, {bool forceRefresh = false});
  Future<void> logFood({
    required int foodId,
    required double servingMultiplier,
    required String mealTime,
    String? unit,
    DateTime? date,
  });
  Future<void> deleteLog(int id);
  Future<List<FoodLogEntry>> getLogs(DateTime date);
  Future<FoodLogEntry> getLogById(int id);
  Future<void> updateLog(
    int id, {
    required double servingMultiplier,
    required String mealTime,
    String? unit,
  });
  Future<void> invalidateCache();
}
