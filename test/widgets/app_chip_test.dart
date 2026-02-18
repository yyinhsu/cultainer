import 'package:cultainer/core/theme/app_theme.dart';
import 'package:cultainer/core/widgets/app_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.darkTheme,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('AppFilterChip', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppFilterChip(
            label: 'Fiction',
            isSelected: false,
            onSelected: (_) {},
          ),
        ),
      );
      expect(find.text('Fiction'), findsOneWidget);
    });

    testWidgets('calls onSelected when tapped', (tester) async {
      bool? lastValue;
      await tester.pumpWidget(
        _wrap(
          AppFilterChip(
            label: 'Fiction',
            isSelected: false,
            onSelected: (v) => lastValue = v,
          ),
        ),
      );
      await tester.tap(find.text('Fiction'));
      expect(lastValue, isTrue);
    });

    testWidgets('toggles selection value on tap', (tester) async {
      bool? lastValue;
      await tester.pumpWidget(
        _wrap(
          AppFilterChip(
            label: 'Selected',
            isSelected: true,
            onSelected: (v) => lastValue = v,
          ),
        ),
      );
      await tester.tap(find.text('Selected'));
      // Was true, tapped → should pass false
      expect(lastValue, isFalse);
    });

    testWidgets('renders icon when provided', (tester) async {
      await tester.pumpWidget(
        _wrap(
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
    testWidgets('renders all filter chips', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppFilterChipList(
            filters: ['All', 'Books', 'Movies'],
            selectedFilters: const {'Books'},
            onFilterChanged: (_, __) {},
          ),
        ),
      );
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Books'), findsOneWidget);
      expect(find.text('Movies'), findsOneWidget);
    });

    testWidgets('calls onFilterChanged with correct args', (tester) async {
      String? changedFilter;
      bool? changedValue;

      await tester.pumpWidget(
        _wrap(
          AppFilterChipList(
            filters: ['Action', 'Comedy'],
            selectedFilters: const {},
            onFilterChanged: (f, v) {
              changedFilter = f;
              changedValue = v;
            },
          ),
        ),
      );

      await tester.tap(find.text('Action'));
      expect(changedFilter, 'Action');
      expect(changedValue, isTrue);
    });
  });

  group('AppTagChip', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppTagChip(label: 'Sci-Fi')),
      );
      expect(find.text('Sci-Fi'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(AppTagChip(label: 'Tag', onTap: () => tapped = true)),
      );
      await tester.tap(find.text('Tag'));
      expect(tapped, isTrue);
    });

    testWidgets('shows delete icon when onDelete is provided', (tester) async {
      await tester.pumpWidget(
        _wrap(AppTagChip(label: 'Removable', onDelete: () {})),
      );
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('does not show delete icon without onDelete', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppTagChip(label: 'Static')),
      );
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('calls onDelete when X icon tapped', (tester) async {
      var deleted = false;
      await tester.pumpWidget(
        _wrap(AppTagChip(label: 'Delete Me', onDelete: () => deleted = true)),
      );
      await tester.tap(find.byIcon(Icons.close));
      expect(deleted, isTrue);
    });
  });
}
