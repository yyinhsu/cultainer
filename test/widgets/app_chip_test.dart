import 'package:cultainer/core/widgets/app_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('AppFilterChip', () {
    testWidgets('displays label', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          AppFilterChip(
            label: 'Books',
            isSelected: false,
            onSelected: (_) {},
          ),
        ),
      );

      expect(find.text('Books'), findsOneWidget);
    });

    testWidgets('calls onSelected when tapped', (tester) async {
      bool? selectedValue;
      await tester.pumpWidget(
        buildTestWidget(
          AppFilterChip(
            label: 'Books',
            isSelected: false,
            onSelected: (value) => selectedValue = value,
          ),
        ),
      );

      await tester.tap(find.text('Books'));
      expect(selectedValue, isTrue);
    });

    testWidgets('toggles selected state', (tester) async {
      bool? selectedValue;
      await tester.pumpWidget(
        buildTestWidget(
          AppFilterChip(
            label: 'Books',
            isSelected: true,
            onSelected: (value) => selectedValue = value,
          ),
        ),
      );

      await tester.tap(find.text('Books'));
      expect(selectedValue, isFalse);
    });

    testWidgets('shows icon when provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          AppFilterChip(
            label: 'Books',
            isSelected: false,
            onSelected: (_) {},
            icon: Icons.book,
          ),
        ),
      );

      expect(find.byIcon(Icons.book), findsOneWidget);
    });
  });

  group('AppFilterChipList', () {
    testWidgets('displays all filter chips', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          AppFilterChipList(
            filters: const ['All', 'Books', 'Movies'],
            selectedFilters: const {},
            onFilterChanged: (_, __) {},
          ),
        ),
      );

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Books'), findsOneWidget);
      expect(find.text('Movies'), findsOneWidget);
    });
  });

  group('AppTagChip', () {
    testWidgets('displays label', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppTagChip(label: 'Fiction'),
        ),
      );

      expect(find.text('Fiction'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        buildTestWidget(
          AppTagChip(label: 'Fiction', onTap: () => tapped = true),
        ),
      );

      await tester.tap(find.text('Fiction'));
      expect(tapped, isTrue);
    });

    testWidgets('shows delete icon when onDelete provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          AppTagChip(label: 'Fiction', onDelete: () {}),
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('hides delete icon when onDelete is null', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppTagChip(label: 'Fiction'),
        ),
      );

      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('calls onDelete when delete icon tapped', (tester) async {
      var deleted = false;
      await tester.pumpWidget(
        buildTestWidget(
          AppTagChip(label: 'Fiction', onDelete: () => deleted = true),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      expect(deleted, isTrue);
    });
  });
}
