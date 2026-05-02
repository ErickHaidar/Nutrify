// test/widgets/skeletons/history_skeleton_test.dart
// TDD: Verify HistoryScreenSkeleton

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shimmer/shimmer.dart';
import 'package:nutrify/widgets/skeletons/history_skeleton.dart';

void main() {
  group('HistoryScreenSkeleton', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HistoryScreenSkeleton(),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('contains Shimmer widgets', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HistoryScreenSkeleton(),
          ),
        ),
      );
      expect(find.byType(Shimmer), findsWidgets);
    });

    testWidgets('shows at least 6 shimmer containers (2 summary + 4 meal sections)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 800,
              child: HistoryScreenSkeleton(),
            ),
          ),
        ),
      );
      final shimmerCount = tester.widgetList(find.byType(Shimmer)).length;
      expect(shimmerCount, greaterThanOrEqualTo(6));
    });

    testWidgets('shows nutrition tip icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 800,
              child: HistoryScreenSkeleton(),
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.lightbulb_outline), findsAtLeastNWidgets(1));
    });
  });
}
