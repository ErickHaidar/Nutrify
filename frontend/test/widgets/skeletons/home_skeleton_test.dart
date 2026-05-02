// test/widgets/skeletons/home_skeleton_test.dart
// TDD: Verify HomeScreenSkeleton and AnimatedProgressBar

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shimmer/shimmer.dart';
import 'package:nutrify/widgets/skeletons/home_skeleton.dart';

void main() {
  group('HomeScreenSkeleton', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: HomeScreenSkeleton())),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('contains Shimmer widgets', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: HomeScreenSkeleton())),
      );
      expect(find.byType(Shimmer), findsWidgets);
    });

    testWidgets('shows at least 4 shimmer meal tile placeholders', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: HomeScreenSkeleton())),
      );
      // The grid has 4 _SkeletonMealTile which each contain a Shimmer
      final shimmerCount = tester.widgetList(find.byType(Shimmer)).length;
      expect(shimmerCount, greaterThanOrEqualTo(4));
    });

    testWidgets('shows a nutrition tip', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: HomeScreenSkeleton())),
      );
      // The tip widget contains an Icon and Text
      expect(find.byIcon(Icons.lightbulb_outline), findsAtLeastNWidgets(1));
    });
  });

  group('AnimatedProgressBar', () {
    testWidgets('renders without throwing with value 0', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedProgressBar(value: 0.0),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without throwing with value 1.0', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedProgressBar(value: 1.0),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('contains LinearProgressIndicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: AnimatedProgressBar(value: 0.5),
            ),
          ),
        ),
      );
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('animates from 0 toward target value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: AnimatedProgressBar(
                value: 0.8,
                duration: Duration(milliseconds: 600),
              ),
            ),
          ),
        ),
      );

      // At t=0 the bar starts at 0 (or near 0)
      LinearProgressIndicator indicator = tester.widget(find.byType(LinearProgressIndicator));
      expect(indicator.value, lessThan(0.5)); // Still animating toward 0.8

      // After full animation
      await tester.pumpAndSettle(const Duration(milliseconds: 700));
      indicator = tester.widget(find.byType(LinearProgressIndicator));
      expect(indicator.value, closeTo(0.8, 0.01));
    });

    testWidgets('clamps value to 0.0–1.0', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: AnimatedProgressBar(value: 1.5), // over 100%
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final indicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator));
      expect(indicator.value, lessThanOrEqualTo(1.0));
    });

    testWidgets('updates animation when value changes', (tester) async {
      double progressValue = 0.3;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => Column(
                children: [
                  SizedBox(
                    width: 300,
                    child: AnimatedProgressBar(value: progressValue),
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => progressValue = 0.9),
                    child: const Text('Update'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Update value
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(); // Start animation
      
      // Bar should be animating (not yet at 0.9)
      final indicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator));
      expect(indicator.value, isNotNull);
      
      await tester.pumpAndSettle(const Duration(milliseconds: 700));
      final finalIndicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator));
      expect(finalIndicator.value, closeTo(0.9, 0.01));
    });
  });
}
