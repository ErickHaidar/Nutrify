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

  static const Color nutrifyBackground = Color(0xFFFAF1E8);
  static const Color nutrifyTitle = Color(0xFFF1C28E);
  static const Color nutrifyButton = Color(0xFF322E53);
  static const Color nutrifyButtonText = Colors.white;
  static const Color nutrifyFieldBackground = Color(0xFFFFFFFF);
  static const Color nutrifyAccent = Color(0xFFF1C28E);
  // New Palette Constants
  static const Color cream = Color(0xFFFAF1E8);
  static const Color peach = Color(0xFFFFD1A6);
  static const Color navy = Color(0xFF322E53);
  static const Color amber = Color(0xFFF1C28E);
}

class NutrifyTheme {
  static const Color background = Color(0xFFFAF1E8);
  static const Color darkCard = Color(0xFF322E53);
  static const Color lightCard = Color(0xFFFFD1A6);
  static const Color accentOrange = Color(0xFFF1C28E);
  static const Color dashboardCard = Color(0xFFFFD1A9);
}
