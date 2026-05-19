import 'package:nutrify/data/local/datasources/food_log/food_log_datasource.dart';
import 'package:nutrify/domain/repository/food_log/food_log_repository.dart';
import 'package:nutrify/services/food_log_api_service.dart';

class FoodLogRepositoryImpl implements FoodLogRepository {
  final FoodLogApiService _foodLogApi;
  final FoodLogDataSource _foodLogDataSource;

  FoodLogRepositoryImpl(this._foodLogApi, this._foodLogDataSource);

  @override
  Future<DailySummary> getSummary(DateTime date, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cachedSummary = await _foodLogDataSource.getSummary(date);
      if (cachedSummary != null) return cachedSummary;
    }

    final remoteSummary = await _foodLogApi.getSummary(date);
    await _foodLogDataSource.saveSummary(date, remoteSummary);
    return remoteSummary;
  }

  @override
  Future<void> logFood({
    required int foodId,
    required double servingMultiplier,
    required String mealTime,
    String? unit,
    DateTime? date,
  }) async {
    await _foodLogApi.logFood(
      foodId: foodId,
      servingMultiplier: servingMultiplier,
      mealTime: mealTime,
      unit: unit,
      date: date,
    );
  }

  @override
  Future<void> deleteLog(int id) async {
    await _foodLogApi.deleteLog(id);
  }

  @override
  Future<List<FoodLogEntry>> getLogs(DateTime date) async {
    return await _foodLogApi.getLogs(date);
  }

  @override
  Future<FoodLogEntry> getLogById(int id) async {
    return await _foodLogApi.getLogById(id);
  }

  @override
  Future<void> updateLog(
    int id, {
    required double servingMultiplier,
    required String mealTime,
    String? unit,
  }) async {
    await _foodLogApi.updateLog(
      id,
      servingMultiplier: servingMultiplier,
      mealTime: mealTime,
      unit: unit,
    );
  }

  @override
  Future<void> invalidateCache() async {
    await _foodLogDataSource.clearAll();
  }
}
