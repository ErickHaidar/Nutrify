import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutrify/presentation/home/store/home_store.dart';
import 'package:nutrify/services/food_log_api_service.dart';
import 'package:nutrify/services/notification_api_service.dart';
import 'package:nutrify/domain/repository/food_log/food_log_repository.dart';
import 'package:nutrify/domain/repository/profile/profile_repository.dart';

class MockFoodLogRepository extends Mock implements FoodLogRepository {}
class MockProfileRepository extends Mock implements ProfileRepository {}
class MockNotificationApiService extends Mock implements NotificationApiService {}

void main() {
  late HomeStore store;
  late MockFoodLogRepository mockFoodLogRepository;
  late MockProfileRepository mockProfileRepository;
  late MockNotificationApiService mockNotificationApi;

  setUpAll(() {
    registerFallbackValue(DateTime.now());
  });

  setUp(() {
    mockFoodLogRepository = MockFoodLogRepository();
    mockProfileRepository = MockProfileRepository();
    mockNotificationApi = MockNotificationApiService();
    store = HomeStore(
      foodLogRepository: mockFoodLogRepository,
      profileRepository: mockProfileRepository,
      notifApi: mockNotificationApi,
    );
  });

  test('initial values are correct', () {
    expect(store.totalCalories, 0);
    expect(store.isLoadingData, false);
    expect(store.unreadCount, 0);
  });

  test('loadDailyData updates state correctly', () async {
    final summary = DailySummary(
      byMeal: {},
      totals: MealNutrition(calories: 500, protein: 20, carbohydrates: 50, fat: 10),
      targetCalories: 2000,
    );

    when(() => mockFoodLogRepository.getSummary(any(), forceRefresh: any(named: 'forceRefresh')))
        .thenAnswer((_) async => summary);
    when(() => mockProfileRepository.getProfile(forceRefresh: any(named: 'forceRefresh')))
        .thenAnswer((_) async => null);
    when(() => mockNotificationApi.getUnreadCount()).thenAnswer((_) async => 5);

    await store.loadDailyData();

    expect(store.totalCalories, 500);
    expect(store.targetCalories, 2000);
    expect(store.unreadCount, 5);
    expect(store.isLoadingData, false);
  });
}