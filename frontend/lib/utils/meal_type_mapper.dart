import 'package:nutrify/utils/locale/app_strings.dart';

class MealTypeMapper {
  static Map<String, String> get _displayToApi => {
    AppStrings.breakfast: 'Breakfast',
    AppStrings.lunch: 'Lunch',
    AppStrings.dinner: 'Dinner',
    AppStrings.snack: 'Snack',
  };

  static Map<String, String> get _apiToDisplay => {
    'Breakfast': AppStrings.breakfast,
    'Lunch': AppStrings.lunch,
    'Dinner': AppStrings.dinner,
    'Snack': AppStrings.snack,
  };

  /// Converts Indonesian display name to English API value.
  /// Returns 'Breakfast' as default if not found.
  static String toApi(String display) {
    return _displayToApi[display] ?? 'Breakfast';
  }

  /// Converts English API value to Indonesian display name.
  /// Returns 'Makan Pagi' as default if not found.
  static String toDisplay(String api) {
    return _apiToDisplay[api] ?? 'Makan Pagi';
  }
}
