import 'package:mobx/mobx.dart';
import 'package:nutrify/domain/repository/food_log/food_log_repository.dart';
import 'package:nutrify/domain/repository/profile/profile_repository.dart';
import 'package:nutrify/services/food_log_api_service.dart';
import 'package:nutrify/services/profile_api_service.dart';
import 'package:nutrify/services/notification_api_service.dart';
import 'package:nutrify/di/service_locator.dart';
import 'package:nutrify/utils/locale/app_strings.dart';

part 'home_store.g.dart';

class HomeStore extends _HomeStore with _$HomeStore {
  HomeStore({
    super.foodLogRepository,
    super.profileRepository,
    super.notifApi,
  });
}

abstract class _HomeStore with Store {
  final FoodLogRepository _foodLogApi;
  final ProfileRepository _profileApi;
  final NotificationApiService _notifApi;

  _HomeStore({
    FoodLogRepository? foodLogRepository,
    ProfileRepository? profileRepository,
    NotificationApiService? notifApi,
  })  : _foodLogApi = foodLogRepository ?? getIt<FoodLogRepository>(),
        _profileApi = profileRepository ?? getIt<ProfileRepository>(),
        _notifApi = notifApi ?? getIt<NotificationApiService>();

  @observable
  int totalCalories = 0;

  @observable
  int targetCalories = 0;

  @observable
  bool isLoadingData = false;

  @observable
  ApiProfileData? profile;

  @observable
  int unreadCount = 0;

  @observable
  double totalProtein = 0;

  @observable
  double totalCarbs = 0;

  @observable
  double totalFat = 0;

  @observable
  ObservableMap<String, int> caloriesByType = ObservableMap.of({
    AppStrings.breakfast: 0,
    AppStrings.lunch: 0,
    AppStrings.dinner: 0,
    AppStrings.snack: 0,
  });

  @action
  Future<void> loadDailyData({bool forceRefresh = false}) async {
    if (isLoadingData) return;
    isLoadingData = true;
    final now = DateTime.now();

    try {
      final results = await Future.wait([
        _foodLogApi.getSummary(now).catchError((_) => DailySummary.empty()),
        _profileApi.getProfile(forceRefresh: forceRefresh).catchError((_) => null),
        _notifApi.getUnreadCount().catchError((_) => 0),
      ]);

      final summary = results[0] as DailySummary?;
      final profileData = results[1] as ApiProfileData?;
      final unread = results[2] as int;

      unreadCount = unread;
      if (profileData != null) {
        profile = profileData;
      }

      if (summary != null) {
        totalCalories = summary.totalCaloriesInt;
        totalProtein = summary.totals.protein;
        totalCarbs = summary.totals.carbohydrates;
        totalFat = summary.totals.fat;
        targetCalories = (summary.targetCalories > 0)
            ? summary.targetCalories
            : (profileData?.targetCalories ?? 0);
        
        caloriesByType.addAll({
          AppStrings.breakfast: summary.caloriesForMeal('Breakfast'),
          AppStrings.lunch: summary.caloriesForMeal('Lunch'),
          AppStrings.dinner: summary.caloriesForMeal('Dinner'),
          AppStrings.snack: summary.caloriesForMeal('Snack'),
        });
      } else if (profileData != null) {
        targetCalories = profileData.targetCalories;
      }
    } finally {
      isLoadingData = false;
    }
  }

  @action
  void setUnreadCount(int count) {
    unreadCount = count;
  }

  @action
  void reset() {
    totalCalories = 0;
    targetCalories = 0;
    isLoadingData = false;
    profile = null;
    unreadCount = 0;
    totalProtein = 0;
    totalCarbs = 0;
    totalFat = 0;
    caloriesByType = ObservableMap.of({
      AppStrings.breakfast: 0,
      AppStrings.lunch: 0,
      AppStrings.dinner: 0,
      AppStrings.snack: 0,
    });
  }
}
