// test/widgets/skeletons/food_search_skeleton_test.dart
// TDD: Verify FoodSearchSkeleton

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shimmer/shimmer.dart';
import 'package:nutrify/widgets/skeletons/food_search_skeleton.dart';

void main() {
  group('FoodSearchSkeleton', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FoodSearchSkeleton(),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('contains Shimmer widgets', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FoodSearchSkeleton(),
          ),
        ),
      );
      expect(find.byType(Shimmer), findsWidgets);
    });

    testWidgets('renders default 6 skeleton items', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FoodSearchSkeleton(itemCount: 6),
          ),
        ),
      );
      expect(find.byType(Shimmer), findsNWidgets(6));
    });

    testWidgets('renders custom itemCount', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FoodSearchSkeleton(itemCount: 3),
          ),
        ),
      );
      expect(find.byType(Shimmer), findsNWidgets(3));
    });

    testWidgets('skeleton tiles have correct structure', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FoodSearchSkeleton(itemCount: 1),
          ),
        ),
      );
      // Each tile has a Row with icon, text columns, checkbox
      expect(find.byType(Row), findsWidgets);
    });
  });
}
