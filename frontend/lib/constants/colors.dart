import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // this basically makes it so you can't instantiate this class

  static const Map<int, Color> orange = const <int, Color>{
    50: const Color(0xFFFCF2E7),
    100: const Color(0xFFF8DEC3),
    200: const Color(0xFFF3C89C),
    300: const Color(0xFFEEB274),
    400: const Color(0xFFEAA256),
    500: const Color(0xFFE69138),
    600: const Color(0xFFE38932),
    700: const Color(0xFFDF7E2B),
    800: const Color(0xFFDB7424),
    900: const Color(0xFFD56217)
  };

  static const Color nutrifyBackground = Color(0xFF49426E);
  static const Color nutrifyTitle = Color(0xFFF8C888);
  static const Color nutrifyButton = Color(0xFF35315D);
  static const Color nutrifyButtonText = Color(0xFFF8C888);
  static const Color nutrifyFieldBackground = Color(0xFFFFFFFF);
  static const Color nutrifyAccent = Color(0xFFF8C888);
}

class NutrifyTheme {
  static const Color background = Color(0xFF49426E);
  static const Color darkCard = Color(0xFF2D2B52);
  static const Color lightCard = Color(0xFF4A477B);
  static const Color accentOrange = Color(0xFFFDBA74);
  static const Color dashboardCard = Color(0xFFFFD1A9);
}
