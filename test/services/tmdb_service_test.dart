import 'dart:convert';

import 'package:cultainer/services/tmdb_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

void _setupDotenv() {
  // Provide a non-empty key so the service does not short-circuit.
  dotenv.testLoad(fileInput: 'TMDB_API_KEY=test-key\n');
}

void main() {
  setUpAll(_setupDotenv);

  group('TmdbService', () {
    late MockHttpClient mockClient;
    late TmdbService service;

    setUp(() {
      mockClient = MockHttpClient();
      service = TmdbService(client: mockClient);
      registerFallbackValue(Uri());
    });

    tearDown(() => service.dispose());

    // --------------- searchMovies ---------------

    group('searchMovies', () {
      test('returns empty list for empty query', () async {
        final results = await service.searchMovies('');
        expect(results, isEmpty);
        verifyNever(() => mockClient.get(any()));
      });

      test('returns parsed movie results', () async {
        final responseBody = json.encode({
          'results': [
            {
              'id': 27205,
              'title': 'Inception',
              'poster_path': '/poster.jpg',
              'overview': 'A thief who steals corporate secrets.',
              'release_date': '2010-07-16',
              'vote_average': 8.4,
            },
          ],
        });

        when(() => mockClient.get(any())).thenAnswer(
          (_) async => http.Response(responseBody, 200),
        );

        final results = await service.searchMovies('inception');

        expect(results.length, 1);
        expect(results[0].id, 27205);
        expect(results[0].title, 'Inception');
        expect(results[0].mediaType, TmdbMediaType.movie);
        expect(results[0].releaseYear, '2010');
        expect(results[0].voteAverage, 8.4);
      });

      test('throws on non-200 status', () async {
        when(() => mockClient.get(any())).thenAnswer(
          (_) async => http.Response('Error', 500),
        );

        expect(
          () => service.searchMovies('test'),
          throwsA(isA<Exception>()),
        );
      });

      test('returns empty list when results is null', () async {
        when(() => mockClient.get(any())).thenAnswer(
          (_) async => http.Response(json.encode({'page': 1}), 200),
        );

        final results = await service.searchMovies('test');
        expect(results, isEmpty);
      });
    });

    // --------------- searchTvShows ---------------

    group('searchTvShows', () {
      test('returns parsed TV results with name field', () async {
        final responseBody = json.encode({
          'results': [
            {
              'id': 1399,
              'name': 'Game of Thrones',
              'poster_path': '/poster.jpg',
              'overview': 'Nine noble families fight for control.',
              'first_air_date': '2011-04-17',
              'vote_average': 9.3,
            },
          ],
        });

        when(() => mockClient.get(any())).thenAnswer(
          (_) async => http.Response(responseBody, 200),
        );

        final results = await service.searchTvShows('game of thrones');

        expect(results.length, 1);
        expect(results[0].id, 1399);
        expect(results[0].title, 'Game of Thrones');
        expect(results[0].mediaType, TmdbMediaType.tv);
        expect(results[0].releaseYear, '2011');
      });
    });

    // --------------- searchMulti ---------------

    group('searchMulti', () {
      test('filters to movie and tv only', () async {
        final responseBody = json.encode({
          'results': [
            {'id': 1, 'title': 'Movie A', 'media_type': 'movie'},
            {'id': 2, 'name': 'TV Show B', 'media_type': 'tv'},
            {'id': 3, 'name': 'Person C', 'media_type': 'person'},
          ],
        });

        when(() => mockClient.get(any())).thenAnswer(
          (_) async => http.Response(responseBody, 200),
        );

        final results = await service.searchMulti('test');
        expect(results.length, 2);
        expect(results.any((r) => r.mediaType == TmdbMediaType.movie), isTrue);
        expect(results.any((r) => r.mediaType == TmdbMediaType.tv), isTrue);
      });
    });

    // --------------- getMovieDetails ---------------

    group('getMovieDetails', () {
      test('returns null on error', () async {
        when(() => mockClient.get(any())).thenAnswer(
          (_) async => http.Response('Error', 404),
        );

        final result = await service.getMovieDetails(99999);
        expect(result, isNull);
      });

      test('extracts director from credits', () async {
        final responseBody = json.encode({
          'id': 27205,
          'title': 'Inception',
          'credits': {
            'crew': [
              {'job': 'Director', 'name': 'Christopher Nolan'},
              {'job': 'Producer', 'name': 'Emma Thomas'},
            ],
          },
        });

        when(() => mockClient.get(any())).thenAnswer(
          (_) async => http.Response(responseBody, 200),
        );

        final result = await service.getMovieDetails(27205);
        expect(result?.director, 'Christopher Nolan');
      });
    });

    // --------------- getTvShowDetails ---------------

    group('getTvShowDetails', () {
      test('extracts creator from created_by', () async {
        final responseBody = json.encode({
          'id': 1399,
          'name': 'Game of Thrones',
          'created_by': [
            {'name': 'David Benioff'},
          ],
          'credits': {'crew': []},
        });

        when(() => mockClient.get(any())).thenAnswer(
          (_) async => http.Response(responseBody, 200),
        );

        final result = await service.getTvShowDetails(1399);
        expect(result?.director, 'David Benioff');
      });
    });
  });

  // --------------- TmdbSearchResult ---------------

  group('TmdbSearchResult', () {
    test('releaseYear extracts year from date', () {
      final result = TmdbSearchResult.fromJson(
        {'id': 1, 'title': 'X', 'release_date': '2010-07-16'},
        TmdbMediaType.movie,
      );
      expect(result.releaseYear, '2010');
    });

    test('releaseYear is null for missing date', () {
      final result = TmdbSearchResult.fromJson(
        {'id': 1, 'title': 'X'},
        TmdbMediaType.movie,
      );
      expect(result.releaseYear, isNull);
    });

    test('posterUrl builds full URL from path', () {
      final result = TmdbSearchResult.fromJson(
        {'id': 1, 'title': 'X', 'poster_path': '/abc.jpg'},
        TmdbMediaType.movie,
      );
      expect(result.posterUrl, contains('/abc.jpg'));
      expect(result.posterUrl, startsWith('https://'));
    });

    test('posterUrl is null when no path', () {
      final result = TmdbSearchResult.fromJson(
        {'id': 1, 'title': 'X'},
        TmdbMediaType.movie,
      );
      expect(result.posterUrl, isNull);
    });

    test('TV show uses name field', () {
      final result = TmdbSearchResult.fromJson(
        {'id': 1, 'name': 'Breaking Bad', 'first_air_date': '2008-01-20'},
        TmdbMediaType.tv,
      );
      expect(result.title, 'Breaking Bad');
      expect(result.releaseYear, '2008');
    });
  });

  // --------------- TmdbService.getPosterUrl ---------------

  group('TmdbService.getPosterUrl', () {
    test('returns null for null path', () {
      expect(TmdbService.getPosterUrl(null), isNull);
    });

    test('builds URL with default size w500', () {
      final url = TmdbService.getPosterUrl('/poster.jpg');
      expect(url, 'https://image.tmdb.org/t/p/w500/poster.jpg');
    });

    test('builds URL with specified size', () {
      final url = TmdbService.getPosterUrl(
        '/poster.jpg',
        size: TmdbImageSize.original,
      );
      expect(url, 'https://image.tmdb.org/t/p/original/poster.jpg');
    });
  });
}
