import 'package:cultainer/core/theme/app_theme.dart';
import 'package:cultainer/core/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.darkTheme,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('AppCard', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppCard(child: Text('Hello Card')),
        ),
      );
      expect(find.text('Hello Card'), findsOneWidget);
    });

    testWidgets('wraps with GestureDetector when onTap is provided',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          AppCard(
            onTap: () => tapped = true,
            child: const Text('Tappable'),
          ),
        ),
      );
      await tester.tap(find.text('Tappable'));
      expect(tapped, isTrue);
    });

    testWidgets('does not wrap with GestureDetector when onTap is null',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppCard(child: Text('Static')),
        ),
      );
      // GestureDetector not present as ancestor of Text
      expect(find.byType(GestureDetector), findsNothing);
    });

    testWidgets('applies custom padding', (tester) async {
      const customPadding = EdgeInsets.all(32);
      await tester.pumpWidget(
        _wrap(
          const AppCard(
            padding: customPadding,
            child: Text('Padded'),
          ),
        ),
      );
      final paddingWidget = tester.widget<Padding>(
        find.descendant(
          of: find.byType(AppCard),
          matching: find.byType(Padding),
        ),
      );
      expect(paddingWidget.padding, customPadding);
    });
  });

  group('ReviewCard', () {
    testWidgets('renders title and creator', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ReviewCard(
            title: 'The Great Gatsby',
            creator: 'F. Scott Fitzgerald',
          ),
        ),
      );
      expect(find.text('The Great Gatsby'), findsOneWidget);
      expect(find.text('F. Scott Fitzgerald'), findsOneWidget);
    });

    testWidgets('shows media type badge when provided', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ReviewCard(
            title: 'Inception',
            creator: 'Christopher Nolan',
            mediaType: 'movie',
          ),
        ),
      );
      expect(find.text('MOVIE'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          ReviewCard(
            title: 'Dune',
            creator: 'Frank Herbert',
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.tap(find.byType(ReviewCard));
      expect(tapped, isTrue);
    });
  });
}
