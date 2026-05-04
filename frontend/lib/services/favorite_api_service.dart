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
    try {
      final res = await _dio.dio.get(
        Endpoints.foodRecommendations,
        queryParameters: {'limit': limit},
      );
      
      if (res.data == null || res.data is! Map) {
        return [];
      }

      final List<dynamic> data = res.data['data'] is List ? res.data['data'] : [];
      return data
          .map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Return empty list on error to handle new users or API failures gracefully
      return [];
    }
  }

}
