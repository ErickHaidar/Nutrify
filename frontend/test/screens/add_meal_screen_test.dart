import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutrify/screens/add_meal_screen.dart';
import 'package:nutrify/services/food_api_service.dart';
import 'package:nutrify/services/favorite_api_service.dart';
import 'package:nutrify/domain/repository/food_log/food_log_repository.dart';
import 'package:nutrify/presentation/home/store/language/language_store.dart';
import 'package:nutrify/services/notification_service.dart';
import 'package:nutrify/di/service_locator.dart';

class MockFoodApiService extends Mock implements FoodApiService {}
class MockFavoriteApiService extends Mock implements FavoriteApiService {}
class MockFoodLogRepository extends Mock implements FoodLogRepository {}
class MockLanguageStore extends Mock implements LanguageStore {}
class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late MockFoodApiService mockFoodApi;
  late MockFavoriteApiService mockFavApi;
  late MockFoodLogRepository mockFoodLogApi;
  late MockLanguageStore mockLanguageStore;
  late MockNotificationService mockNotificationService;

  setUpAll(() {
    registerFallbackValue(DateTime.now());
  });

  setUp(() async {
    await getIt.reset();
    
    mockFoodApi = MockFoodApiService();
    mockFavApi = MockFavoriteApiService();
    mockFoodLogApi = MockFoodLogRepository();
    mockLanguageStore = MockLanguageStore();
    mockNotificationService = MockNotificationService();

    getIt.registerSingleton<FoodApiService>(mockFoodApi);
    getIt.registerSingleton<FavoriteApiService>(mockFavApi);
    getIt.registerSingleton<FoodLogRepository>(mockFoodLogApi);
    getIt.registerSingleton<LanguageStore>(mockLanguageStore);
    getIt.registerSingleton<NotificationService>(mockNotificationService);

    when(() => mockLanguageStore.locale).thenReturn('id');
    when(() => mockFoodLogApi.getLogs(any())).thenAnswer((_) async => []);
    when(() => mockFavApi.getFavorites(page: any(named: 'page'))).thenAnswer((_) async => []);
    when(() => mockFavApi.getRecommendations(limit: any(named: 'limit'))).thenAnswer((_) async => []);
    when(() => mockFoodApi.searchFoods(any(), page: any(named: 'page'))).thenAnswer((_) async => []);
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: AddMealScreen(mealType: 'Breakfast', date: null),
    );
  }

  testWidgets('AddMealScreen shows Terakhir Dimakan, Favoritmu, and Makanan Populer sections by default', (WidgetTester tester) async {
    when(() => mockFavApi.getRecommendations(limit: any(named: 'limit'))).thenAnswer((_) async => [
      FoodItem(id: 1, name: 'Nasi Goreng Rec', calories: 200, protein: 10, carbohydrates: 20, fat: 5, servingSize: '1 porsi')
    ]);
    when(() => mockFavApi.getFavorites(page: any(named: 'page'))).thenAnswer((_) async => [
      FoodItem(id: 2, name: 'Ayam Bakar Fav', calories: 300, protein: 20, carbohydrates: 10, fat: 15, servingSize: '1 potong')
    ]);
    when(() => mockFoodApi.searchFoods(any(), page: any(named: 'page'))).thenAnswer((_) async => [
      FoodItem(id: 3, name: 'Tahu Goreng Pop', calories: 100, protein: 5, carbohydrates: 5, fat: 5, servingSize: '1 buah')
    ]);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Terakhir Dimakan'), findsOneWidget);
    expect(find.text('Favoritmu'), findsOneWidget);
    expect(find.text('Makanan Populer'), findsOneWidget);

    // Verify items are displayed
    expect(find.text('Nasi Goreng Rec'), findsOneWidget);
    expect(find.text('Ayam Bakar Fav'), findsOneWidget);
    expect(find.text('Tahu Goreng Pop'), findsOneWidget);
  });
}
