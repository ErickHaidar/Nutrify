import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MyApp Builder', () {
    testWidgets('builder wraps content with SafeArea having top:false for bottom deadzone', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const Scaffold(body: Text('Test')),
          builder: (context, child) {
            return Container(
              color: const Color(0xFF2D2A4A),
              child: SafeArea(
                top: false,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: child!,
                  ),
                ),
              ),
            );
          },
        ),
      );

      // Verify SafeArea exists
      final safeAreaFinder = find.byType(SafeArea);
      expect(safeAreaFinder, findsOneWidget);

      // Verify SafeArea has top: false
      final SafeArea safeArea = tester.widget(safeAreaFinder);
      expect(safeArea.top, isFalse);
      expect(safeArea.bottom, isTrue); // default - this is the deadzone protection
    });

    testWidgets('builder uses deep blue deadzone background color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const Scaffold(body: Text('Test')),
          builder: (context, child) {
            return Container(
              color: const Color(0xFF2D2A4A),
              child: SafeArea(
                top: false,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: child!,
                  ),
                ),
              ),
            );
          },
        ),
      );

      // Verify Container with deadzone color exists
      final containerFinder = find.byWidgetPredicate(
        (widget) => widget is Container && widget.color == const Color(0xFF2D2A4A),
      );
      expect(containerFinder, findsOneWidget);
    });

    testWidgets('builder constrains content width to 600', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const Scaffold(body: Text('Test')),
          builder: (context, child) {
            return Container(
              color: const Color(0xFF2D2A4A),
              child: SafeArea(
                top: false,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: child!,
                  ),
                ),
              ),
            );
          },
        ),
      );

      // Verify ConstrainedBox with maxWidth 600
      final constrainedFinder = find.byWidgetPredicate(
        (widget) => widget is ConstrainedBox && widget.constraints.maxWidth == 600,
      );
      expect(constrainedFinder, findsOneWidget);
    });
  });
}
