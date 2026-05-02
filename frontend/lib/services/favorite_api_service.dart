import 'package:nutrify/core/data/network/dio/dio_client.dart';
import 'package:nutrify/data/network/constants/endpoints.dart';
import 'package:nutrify/di/service_locator.dart';
import 'package:nutrify/services/food_api_service.dart';

class FavoriteApiService {
  DioClient get _dio => getIt<DioClient>();

  Future<List<FoodItem>> getFavorites({int page = 1}) async {
    final res = await _dio.dio.get(
      Endpoints.foodFavorites,
      queryParameters: {'page': page},
    );
    final List<dynamic> data = res.data['data']['data'] ?? [];
    return data.map((e) => FoodItem.fromJson(e['food'] ?? e as Map<String, dynamic>)).toList();
  }

  Future<void> addFavorite(int foodId) async {
    await _dio.dio.post(Endpoints.foodFavorites, data: {'food_id': foodId});
  }

  Future<void> removeFavorite(int foodId) async {
    await _dio.dio.delete('${Endpoints.foodFavorites}/$foodId');
  }

  Future<List<FoodItem>> getRecommendations({int limit = 10}) async {
    final res = await _dio.dio.get(
      Endpoints.foodRecommendations,
      queryParameters: {'limit': limit},
    );
    final List<dynamic> data = res.data['data'] ?? [];
    return data.map((e) => FoodItem.fromJson(e as Map<String, dynamic>)).toList();
  }
}
