import 'package:cultainer/core/constants/enums.dart';
import 'package:cultainer/features/explore/explore_page.dart';
import 'package:cultainer/services/media_search_service.dart';
import 'package:cultainer/services/recommendation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Use a single recommendation to keep all content on screen.
  const singleRec = [
    Recommendation(
      result: MediaSearchResult(
        externalId: 'tmdb:movie:1',
        title: 'Inception',
        type: MediaType.movie,
        creator: 'Christopher Nolan',
        releaseYear: '2010',
      ),
      reason: 'Because you recorded "Interstellar"',
      creatorName: 'Christopher Nolan',
      sourceEntryTitle: 'Interstellar',
    ),
  ];

  const multiRec = [
    ...singleRec,
    Recommendation(
      result: MediaSearchResult(
        externalId: 'gbooks:vol:abc',
        title: 'Norwegian Wood',
        type: MediaType.book,
        creator: 'Haruki Murakami',
        releaseYear: '1987',
      ),
      reason: 'Because you recorded "Kafka on the Shore"',
      creatorName: 'Haruki Murakami',
      sourceEntryTitle: 'Kafka on the Shore',
    ),
  ];

  Widget buildTestWidget({
    List<Recommendation> recommendations = const [],
  }) {
    return ProviderScope(
      overrides: [
        recommendationsProvider.overrideWith(
          (ref) => Future.value(recommendations),
        ),
      ],
      child: const MaterialApp(
        home: ExplorePage(),
      ),
    );
  }

  group('ExplorePage', () {
    testWidgets('shows Explore title', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(recommendations: singleRec),
      );
      await tester.pumpAndSettle();

      expect(find.text('Explore'), findsOneWidget);
    });

    testWidgets('shows category filter chips', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(recommendations: singleRec),
      );
      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Books'), findsOneWidget);
      expect(find.text('Movies'), findsOneWidget);
      expect(find.text('TV'), findsOneWidget);
      expect(find.text('Music'), findsOneWidget);
    });

    testWidgets('shows recommendation title and creator', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(recommendations: singleRec),
      );
      await tester.pumpAndSettle();

      expect(find.text('Inception'), findsOneWidget);
      // Creator name appears in both section header area and card
      expect(find.text('Christopher Nolan'), findsWidgets);
    });

    testWidgets('shows recommendation reason text', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(recommendations: singleRec),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Because you recorded "Interstellar"'),
        findsOneWidget,
      );
    });

    testWidgets('shows empty state when no recommendations', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Start recording your media experiences\n'
          'to discover related works',
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows media type badge', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(recommendations: singleRec),
      );
      await tester.pumpAndSettle();

      expect(find.text('Movie'), findsOneWidget);
    });

    testWidgets('shows section header', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(recommendations: singleRec),
      );
      await tester.pumpAndSettle();

      expect(find.text('Related to Your Reviews'), findsOneWidget);
    });

    testWidgets('groups recommendations by creator', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(recommendations: multiRec),
      );
      await tester.pumpAndSettle();

      // Two different creators = two section headers
      expect(find.text('Related to Your Reviews'), findsNWidgets(2));
    });
  });
}
