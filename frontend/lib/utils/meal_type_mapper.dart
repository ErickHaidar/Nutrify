// lib/utils/meal_type_mapper.dart

class MealTypeMapper {
  static const Map<String, String> _displayToApi = {
    'Makan Pagi': 'Breakfast',
    'Makan Siang': 'Lunch',
    'Makan Malam': 'Dinner',
    'Cemilan': 'Snack',
  };

  static const Map<String, String> _apiToDisplay = {
    'Breakfast': 'Makan Pagi',
    'Lunch': 'Makan Siang',
    'Dinner': 'Makan Malam',
    'Snack': 'Cemilan',
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
