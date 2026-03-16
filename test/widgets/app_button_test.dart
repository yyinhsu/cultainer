import 'package:cultainer/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('AppButton', () {
    testWidgets('displays label text', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          AppButton(label: 'Click Me', onPressed: () {}),
        ),
      );

      expect(find.text('Click Me'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        buildTestWidget(
          AppButton(label: 'Tap', onPressed: () => pressed = true),
        ),
      );

      await tester.tap(find.text('Tap'));
      expect(pressed, isTrue);
    });

    testWidgets('shows loading indicator when isLoading', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          AppButton(label: 'Loading', onPressed: () {}, isLoading: true),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('disables button when isLoading', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        buildTestWidget(
          AppButton(
            label: 'Loading',
            onPressed: () => pressed = true,
            isLoading: true,
          ),
        ),
      );

      await tester.tap(find.text('Loading'));
      expect(pressed, isFalse);
    });

    testWidgets('shows icon when provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          AppButton(
            label: 'With Icon',
            onPressed: () {},
            icon: Icons.add,
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('renders primary variant as ElevatedButton', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          AppButton(label: 'Primary', onPressed: () {}),
        ),
      );

      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('renders secondary variant as OutlinedButton', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
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
        buildTestWidget(
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
        buildTestWidget(
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
    testWidgets('displays icon', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          AppIconButton(icon: Icons.settings, onPressed: () {}),
        ),
      );

      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        buildTestWidget(
          AppIconButton(
            icon: Icons.settings,
            onPressed: () => pressed = true,
          ),
        ),
      );

      await tester.tap(find.byType(AppIconButton));
      expect(pressed, isTrue);
    });
  });
}
