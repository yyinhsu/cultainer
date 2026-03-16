import 'package:cultainer/core/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('AppCard', () {
    testWidgets('displays child widget', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppCard(child: Text('Card Content')),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        buildTestWidget(
          AppCard(
            onTap: () => tapped = true,
            child: const Text('Tappable'),
          ),
        ),
      );

      await tester.tap(find.text('Tappable'));
      expect(tapped, isTrue);
    });

    testWidgets('wraps in GestureDetector when onTap is set', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          AppCard(
            onTap: () {},
            child: const Text('Gesture'),
          ),
        ),
      );

      expect(find.byType(GestureDetector), findsOneWidget);
    });
  });

  group('ReviewCard', () {
    testWidgets('displays title and creator', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const ReviewCard(
            title: 'Test Book',
            creator: 'Author Name',
          ),
        ),
      );

      expect(find.text('Test Book'), findsOneWidget);
      expect(find.text('Author Name'), findsOneWidget);
    });

    testWidgets('displays media type badge', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const ReviewCard(
            title: 'Title',
            creator: 'Creator',
            mediaType: 'book',
          ),
        ),
      );

      expect(find.text('BOOK'), findsOneWidget);
    });

    testWidgets('displays date when provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const ReviewCard(
            title: 'Title',
            creator: 'Creator',
            date: '2024-01-15',
          ),
        ),
      );

      expect(find.text('2024-01-15'), findsOneWidget);
    });

    testWidgets('shows star rating when provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const ReviewCard(
            title: 'Title',
            creator: 'Creator',
            rating: 8,
          ),
        ),
      );

      // Rating 8/10 = 4 stars, should have star icons
      expect(find.byIcon(Icons.star), findsWidgets);
    });
  });
}
