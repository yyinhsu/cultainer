import 'package:cultainer/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('AppTextField', () {
    testWidgets('displays label when provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppTextField(label: 'Email'),
        ),
      );

      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('displays hint text', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppTextField(hint: 'Enter email'),
        ),
      );

      expect(find.text('Enter email'), findsOneWidget);
    });

    testWidgets('calls onChanged when text changes', (tester) async {
      String? changedValue;
      await tester.pumpWidget(
        buildTestWidget(
          AppTextField(onChanged: (value) => changedValue = value),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'hello');
      expect(changedValue, 'hello');
    });

    testWidgets('shows prefix icon when provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppTextField(prefixIcon: Icons.email),
        ),
      );

      expect(find.byIcon(Icons.email), findsOneWidget);
    });

    testWidgets('is disabled when enabled is false', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppTextField(enabled: false),
        ),
      );

      final field = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(field.enabled, isFalse);
    });
  });

  group('AppSearchField', () {
    testWidgets('displays hint text', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppSearchField(hint: 'Search books...'),
        ),
      );

      expect(find.text('Search books...'), findsOneWidget);
    });

    testWidgets('shows search icon', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppSearchField(),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('calls onChanged when text changes', (tester) async {
      String? changedValue;
      await tester.pumpWidget(
        buildTestWidget(
          AppSearchField(onChanged: (value) => changedValue = value),
        ),
      );

      await tester.enterText(find.byType(TextField), 'test');
      expect(changedValue, 'test');
    });

    testWidgets('shows clear button when controller has text', (tester) async {
      final controller = TextEditingController(text: 'some text');
      await tester.pumpWidget(
        buildTestWidget(
          AppSearchField(controller: controller),
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);

      addTearDown(controller.dispose);
    });

    testWidgets('hides clear button when text is empty', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        buildTestWidget(
          AppSearchField(controller: controller),
        ),
      );

      expect(find.byIcon(Icons.close), findsNothing);

      addTearDown(controller.dispose);
    });
  });
}
