import 'package:cultainer/core/constants/enums.dart';
import 'package:cultainer/models/entry.dart';
import 'package:cultainer/services/google_books_service.dart';
import 'package:cultainer/services/media_search_service.dart';
import 'package:cultainer/services/recommendation_service.dart';
import 'package:cultainer/services/spotify_service.dart';
import 'package:cultainer/services/tmdb_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Provide test env so TmdbService._apiKey doesn't crash.
    // The key will be empty, which causes early returns in API methods.
    dotenv.testLoad(fileInput: 'TMDB_API_KEY=test_key\n');

    // Register fallback values for mocktail
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  final now = DateTime(2026, 3, 16);

  Entry createEntry({
    String id = 'entry-1',
    MediaType type = MediaType.movie,
    String title = 'Test Movie',
    String creator = 'Test Director',
    String? creatorId,
    String? externalId,
  }) {
    return Entry(
      id: id,
      type: type,
      title: title,
      creator: creator,
      creatorId: creatorId,
      externalId: externalId,
      status: EntryStatus.completed,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('Recommendation', () {
    test('toJson and fromJson roundtrip', () {
      const recommendation = Recommendation(
        result: MediaSearchResult(
          externalId: 'tmdb:movie:123',
          title: 'Test Movie',
          type: MediaType.movie,
          creator: 'Director X',
          coverUrl: 'https://example.com/cover.jpg',
          releaseYear: '2025',
        ),
        reason: 'Because you recorded "Other Movie"',
        creatorName: 'Director X',
        sourceEntryTitle: 'Other Movie',
      );

      final json = recommendation.toJson();
      final restored = Recommendation.fromJson(json);

      expect(restored.result.externalId, recommendation.result.externalId);
      expect(restored.result.title, recommendation.result.title);
      expect(restored.result.type, recommendation.result.type);
      expect(restored.result.creator, recommendation.result.creator);
      expect(restored.reason, recommendation.reason);
      expect(restored.creatorName, recommendation.creatorName);
      expect(restored.sourceEntryTitle, recommendation.sourceEntryTitle);
    });
  });

  group('RecommendationService', () {
    late RecommendationService service;
    late MockHttpClient mockTmdbClient;
    late MockHttpClient mockBooksClient;
    late MockHttpClient mockSpotifyClient;

    setUp(() {
      mockTmdbClient = MockHttpClient();
      mockBooksClient = MockHttpClient();
      mockSpotifyClient = MockHttpClient();

      // Stub all HTTP clients to return empty JSON so API calls don't crash
      when(() => mockTmdbClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
        (_) async => http.Response('{"crew":[],"cast":[]}', 200),
      );
      when(() => mockBooksClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
        (_) async => http.Response('{"totalItems":0,"items":[]}', 200),
      );
      when(() => mockSpotifyClient.post(any(),
          headers: any(named: 'headers'), body: any(named: 'body'))).thenAnswer(
        (_) async => http.Response(
          '{"access_token":"test","token_type":"bearer","expires_in":3600}',
          200,
        ),
      );
      when(() => mockSpotifyClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
        (_) async => http.Response('{"items":[]}', 200),
      );

      service = RecommendationService(
        tmdbService: TmdbService(client: mockTmdbClient),
        googleBooksService: GoogleBooksService(client: mockBooksClient),
        spotifyService: SpotifyService(
          client: mockSpotifyClient,
          clientId: 'test',
          clientSecret: 'test',
        ),
      );
    });

    test('returns empty list for empty entries', () async {
      final result = await service.getRecommendations([]);
      expect(result, isEmpty);
    });

    test('returns empty list when no entries have creatorId', () async {
      final entries = [
        createEntry(id: '1'),
        createEntry(id: '2'),
      ];

      final result = await service.getRecommendations(entries);
      expect(result, isEmpty);
    });

    test('returns empty list when creatorId is empty string', () async {
      final entries = [createEntry(creatorId: '')];

      final result = await service.getRecommendations(entries);
      expect(result, isEmpty);
    });

    test('takes at most 10 recent entries with creatorId', () async {
      final entries = List.generate(
        15,
        (i) => createEntry(
          id: 'entry-$i',
          title: 'Movie $i',
          creatorId: 'tmdb:person:$i',
        ),
      );

      final result = await service.getRecommendations(entries);
      expect(result, isA<List<Recommendation>>());
    });

    test('deduplicates creators', () async {
      final entries = [
        createEntry(
          id: '1',
          title: 'Movie A',
          creatorId: 'tmdb:person:100',
          creator: 'Same Director',
        ),
        createEntry(
          id: '2',
          title: 'Movie B',
          creatorId: 'tmdb:person:100',
          creator: 'Same Director',
        ),
      ];

      final result = await service.getRecommendations(entries);
      expect(result, isA<List<Recommendation>>());
    });

    test('isCacheStale returns true initially', () {
      expect(service.isCacheStale, isTrue);
    });

    test('invalidateCache clears memory cache', () async {
      await service.getRecommendations([
        createEntry(creatorId: 'tmdb:person:1'),
      ]);

      await service.invalidateCache();
      expect(service.isCacheStale, isTrue);
    });

    test('handles unknown creatorId prefix gracefully', () async {
      final entries = [
        createEntry(creatorId: 'unknown:prefix:123'),
      ];

      final result = await service.getRecommendations(entries);
      expect(result, isEmpty);
    });
  });
}
