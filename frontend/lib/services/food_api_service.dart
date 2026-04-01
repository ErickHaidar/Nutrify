import 'package:nutrify/core/data/network/dio/dio_client.dart';
import 'package:nutrify/data/network/constants/endpoints.dart';
import 'package:nutrify/di/service_locator.dart';

class FoodItem {
  final int id;
  final String name;
  final String servingSize;
  final double calories;
  final double protein;
  final double carbohydrates;
  final double fat;
  final double sugar;
  final double sodium;
  final double fiber;

  FoodItem({
    required this.id,
    required this.name,
    required this.servingSize,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    this.sugar = 0,
    this.sodium = 0,
    this.fiber = 0,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
    id: json['id'] as int,
    name: json['name'] as String,
    servingSize: json['serving_size'] as String? ?? '100g',
    calories: (json['calories'] as num).toDouble(),
    protein: (json['protein'] as num).toDouble(),
    carbohydrates: (json['carbohydrates'] as num).toDouble(),
    fat: (json['fat'] as num).toDouble(),
    sugar: (json['sugar'] as num?)?.toDouble() ?? 0,
    sodium: (json['sodium'] as num?)?.toDouble() ?? 0,
    fiber: (json['fiber'] as num?)?.toDouble() ?? 0,
  );
}

class FoodApiService {
  DioClient get _dio => getIt<DioClient>();

  Future<List<FoodItem>> searchFoods(String search, {int page = 1}) async {
    final res = await _dio.dio.get(
      Endpoints.foods,
      queryParameters: {'search': search, 'page': page},
    );
    final List<dynamic> data = res.data['data']['data'] ?? [];
    return data
        .map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
