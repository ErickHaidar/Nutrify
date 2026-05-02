// test/utils/nutrition_tips_test.dart
// TDD: Verify NutritionTips utility

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrify/utils/nutrition_tips.dart';

void main() {
  group('NutritionTips', () {
    test('getRandomTip returns a non-empty string', () {
      final tip = NutritionTips.getRandomTip();
      expect(tip, isNotEmpty);
    });

    test('getRandomTip returns a string from the tips list', () {
      final tip = NutritionTips.getRandomTip();
      expect(NutritionTips.all, contains(tip));
    });

    test('getRandomTips returns exactly count items by default', () {
      final tips = NutritionTips.getRandomTips(count: 3);
      expect(tips.length, 3);
    });

    test('getRandomTips returns unique tips', () {
      final tips = NutritionTips.getRandomTips(count: 5);
      final unique = tips.toSet();
      expect(unique.length, tips.length);
    });

    test('all tips list is not empty', () {
      expect(NutritionTips.all, isNotEmpty);
    });

    test('all tips list has at least 10 entries', () {
      expect(NutritionTips.all.length, greaterThanOrEqualTo(10));
    });

    test('getRandomTips with count=1 returns single tip', () {
      final tips = NutritionTips.getRandomTips(count: 1);
      expect(tips.length, 1);
      expect(tips.first, isNotEmpty);
    });

    test('all tips are non-empty strings', () {
      for (final tip in NutritionTips.all) {
        expect(tip, isNotEmpty);
      }
    });

    test('all list is unmodifiable', () {
      expect(
        () => NutritionTips.all.add('fake tip'),
        throwsUnsupportedError,
      );
    });
  });
}
