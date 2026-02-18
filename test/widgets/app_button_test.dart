import 'package:cultainer/core/theme/app_theme.dart';
import 'package:cultainer/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.darkTheme,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('AppButton', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        _wrap(AppButton(label: 'Click Me', onPressed: () {})),
      );
      expect(find.text('Click Me'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(AppButton(label: 'Tap', onPressed: () => tapped = true)),
      );
      await tester.tap(find.text('Tap'));
      expect(tapped, isTrue);
    });

    testWidgets('does not call onPressed when disabled', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(AppButton(label: 'Disabled', onPressed: null)),
      );
      await tester.tap(find.text('Disabled'), warnIfMissed: false);
      expect(tapped, isFalse);
    });

    testWidgets('shows CircularProgressIndicator when loading', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppButton(
            label: 'Loading',
            onPressed: () {},
            isLoading: true,
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows icon when provided', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppButton(
            label: 'With Icon',
            onPressed: () {},
            icon: Icons.star,
          ),
        ),
      );
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('renders secondary variant as OutlinedButton', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppButton(
            label: 'Secondary',
            onPressed: () {},
            variant: AppButtonVariant.secondary,
          ),
        ),
      );
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('renders ghost variant as TextButton', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppButton(
            label: 'Ghost',
            onPressed: () {},
            variant: AppButtonVariant.ghost,
          ),
        ),
      );
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('renders destructive variant as TextButton', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppButton(
            label: 'Delete',
            onPressed: () {},
            variant: AppButtonVariant.destructive,
          ),
        ),
      );
      expect(find.byType(TextButton), findsOneWidget);
    });
  });

  group('AppIconButton', () {
    testWidgets('renders icon and calls onPressed', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        _wrap(
          AppIconButton(
            icon: Icons.add,
            onPressed: () => pressed = true,
          ),
        ),
      );
      expect(find.byIcon(Icons.add), findsOneWidget);
      await tester.tap(find.byType(AppIconButton));
      expect(pressed, isTrue);
    });
  });
}
