import 'package:nutrify/core/data/network/dio/dio_client.dart';
import 'package:nutrify/data/network/constants/endpoints.dart';
import 'package:nutrify/di/service_locator.dart';

class CalorieProgress {
  final DateTime date;
  final double calories;

  CalorieProgress({required this.date, required this.calories});

  factory CalorieProgress.fromJson(Map<String, dynamic> json) => CalorieProgress(
        date: DateTime.parse(json['date'] as String),
        calories: (json['calories'] as num? ?? 0).toDouble(),
      );
}

class WeightProgress {
  final DateTime date;
  final double weight;

  WeightProgress({required this.date, required this.weight});

  factory WeightProgress.fromJson(Map<String, dynamic> json) => WeightProgress(
        date: DateTime.parse(json['date'] as String),
        weight: (json['weight'] as num? ?? 0).toDouble(),
      );
}

class ProgressApiService {
  DioClient get _dio => getIt<DioClient>();

  Future<List<CalorieProgress>> getCalorieProgress() async {
    try {
      final res = await _dio.dio.get(Endpoints.progressCalories);
      final List<dynamic> data = res.data['data'] ?? [];
      return data.map((e) => CalorieProgress.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<WeightProgress>> getWeightProgress() async {
    try {
      final res = await _dio.dio.get(Endpoints.progressWeight);
      final List<dynamic> data = res.data['data'] ?? [];
      return data.map((e) => WeightProgress.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
