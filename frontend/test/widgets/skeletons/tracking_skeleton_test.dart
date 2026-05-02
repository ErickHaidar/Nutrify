// test/widgets/skeletons/tracking_skeleton_test.dart
// TDD: Verify TrackingScreenSkeleton and AnimatedCircularProgress

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shimmer/shimmer.dart';
import 'package:nutrify/widgets/skeletons/tracking_skeleton.dart';

void main() {
  group('TrackingScreenSkeleton', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TrackingScreenSkeleton())),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('contains Shimmer widgets', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TrackingScreenSkeleton())),
      );
      expect(find.byType(Shimmer), findsWidgets);
    });

    testWidgets('shows circular ring skeleton (large circle)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 800,
              child: TrackingScreenSkeleton(),
            ),
          ),
        ),
      );
      // The circular skeleton is a 200x200 BoxDecoration circle
      final containers = tester.widgetList<Container>(find.byType(Container));
      final circleContainers = containers.where((c) {
        final deco = c.decoration;
        if (deco is BoxDecoration) {
          return deco.shape == BoxShape.circle;
        }
        return false;
      }).toList();
      expect(circleContainers, isNotEmpty);
    });

    testWidgets('shows nutrition tip', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 800,
              child: TrackingScreenSkeleton(),
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.lightbulb_outline), findsAtLeastNWidgets(1));
    });
  });

  group('AnimatedCircularProgress', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCircularProgress(
              progress: 0.5,
              gradient: const SweepGradient(
                colors: [Colors.orange, Colors.red],
                startAngle: 0,
                endAngle: 6.28,
              ),
              backgroundColor: Colors.grey.shade200,
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('contains CustomPaint', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCircularProgress(
              progress: 0.7,
              gradient: const SweepGradient(
                colors: [Colors.orange, Colors.deepOrange],
                startAngle: 0,
                endAngle: 6.28,
              ),
              backgroundColor: Colors.grey.shade200,
            ),
          ),
        ),
      );
      expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
    });

    testWidgets('animates on progress change', (tester) async {
      double progress = 0.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => Column(
                children: [
                  AnimatedCircularProgress(
                    progress: progress,
                    gradient: const SweepGradient(
                      colors: [Colors.orange, Colors.red],
                      startAngle: 0,
                      endAngle: 6.28,
                    ),
                    backgroundColor: Colors.grey.shade200,
                    duration: const Duration(milliseconds: 500),
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => progress = 0.8),
                    child: const Text('Animate'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      // No exception during animation
      expect(tester.takeException(), isNull);

      await tester.pumpAndSettle(const Duration(milliseconds: 600));
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles progress = 0 without painting arc', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCircularProgress(
              progress: 0.0,
              gradient: const SweepGradient(
                colors: [Colors.orange, Colors.red],
                startAngle: 0,
                endAngle: 6.28,
              ),
              backgroundColor: Colors.grey.shade200,
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
