// Basic Flutter widget test for Cultainer app.

import 'package:cultainer/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App renders without error', (WidgetTester tester) async {
    // Build our app wrapped in ProviderScope and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: CultainerApp(),
      ),
    );

    // Verify that the app renders (will show sign-in since no auth).
    expect(find.text('Cultainer'), findsOneWidget);
  });
}
