import 'dart:convert';

import 'package:cultainer/services/google_books_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

/// Minimal fake .env so dotenv doesn't throw during tests.
void _setupDotenv() {
  dotenv.testLoad(fileInput: 'GOOGLE_BOOKS_API_KEY=\n');
}

void main() {
  setUpAll(_setupDotenv);

  group('GoogleBooksService', () {
    late MockHttpClient mockClient;
    late GoogleBooksService service;

    setUp(() {
      mockClient = MockHttpClient();
      service = GoogleBooksService(client: mockClient);
      registerFallbackValue(Uri());
    });

    tearDown(() => service.dispose());

    group('searchBooks', () {
      test('returns empty list for empty query', () async {
        final results = await service.searchBooks('');
        expect(results, isEmpty);
        verifyNever(() => mockClient.get(any()));
      });

      test('returns parsed results on success', () async {
        final responseBody = json.encode({
          'items': [
            {
              'id': 'vol-1',
              'volumeInfo': {
                'title': 'The Great Gatsby',
                'authors': ['F. Scott Fitzgerald'],
                'imageLinks': {
                  'thumbnail': 'http://example.com/thumb.jpg',
                },
                'pageCount': 180,
                'publishedDate': '1925-04-10',
                'publisher': 'Scribner',
                'categories': ['Fiction'],
                'industryIdentifiers': [
                  {'type': 'ISBN_13', 'identifier': '9780743273565'},
                ],
              },
            },
          ],
        });

        when(() => mockClient.get(any())).thenAnswer(
          (_) async => http.Response(responseBody, 200),
        );

        final results = await service.searchBooks('gatsby');

        expect(results.length, 1);
        expect(results[0].id, 'vol-1');
        expect(results[0].title, 'The Great Gatsby');
        expect(results[0].primaryAuthor, 'F. Scott Fitzgerald');
        expect(results[0].pageCount, 180);
        expect(results[0].isbn, '9780743273565');
        // HTTP upgraded to HTTPS
        expect(results[0].coverUrl, startsWith('https://'));
      });

      test('returns empty list when no items in response', () async {
        when(() => mockClient.get(any())).thenAnswer(
          (_) async => http.Response(json.encode({'totalItems': 0}), 200),
        );

        final results = await service.searchBooks('zxqwerty');
        expect(results, isEmpty);
      });

      test('throws on non-200 status', () async {
        when(() => mockClient.get(any())).thenAnswer(
          (_) async => http.Response('Not found', 404),
        );

        expect(
          () => service.searchBooks('test'),
          throwsA(isA<Exception>()),
        );
      });

      test('upgrades HTTP cover URL to HTTPS', () async {
        final responseBody = json.encode({
          'items': [
            {
              'id': 'vol-2',
              'volumeInfo': {
                'title': 'Book',
                'authors': ['Author'],
                'imageLinks': {'thumbnail': 'http://example.com/thumb.jpg'},
              },
            },
          ],
        });

        when(() => mockClient.get(any())).thenAnswer(
          (_) async => http.Response(responseBody, 200),
        );

        final results = await service.searchBooks('book');
        expect(results[0].coverUrl, startsWith('https://'));
      });
    });

    group('getBookDetails', () {
      test('returns null on non-200 status', () async {
        when(() => mockClient.get(any())).thenAnswer(
          (_) async => http.Response('Error', 500),
        );

        final result = await service.getBookDetails('bad-id');
        expect(result, isNull);
      });

      test('returns book on success', () async {
        final responseBody = json.encode({
          'id': 'vol-3',
          'volumeInfo': {
            'title': 'Dune',
            'authors': ['Frank Herbert'],
            'pageCount': 412,
          },
        });

        when(() => mockClient.get(any())).thenAnswer(
          (_) async => http.Response(responseBody, 200),
        );

        final result = await service.getBookDetails('vol-3');
        expect(result, isNotNull);
        expect(result!.title, 'Dune');
        expect(result.pageCount, 412);
      });
    });
  });

  group('BookSearchResult', () {
    test('primaryAuthor returns first author', () {
      final result = BookSearchResult.fromJson('id', {
        'title': 'Book',
        'authors': ['Author A', 'Author B'],
      });
      expect(result.primaryAuthor, 'Author A');
    });

    test('primaryAuthor returns Unknown when no authors', () {
      final result = BookSearchResult.fromJson('id', {
        'title': 'Book',
      });
      expect(result.primaryAuthor, 'Unknown');
    });

    test('prefers ISBN_13 over ISBN_10', () {
      final result = BookSearchResult.fromJson('id', {
        'title': 'Book',
        'industryIdentifiers': [
          {'type': 'ISBN_10', 'identifier': '0123456789'},
          {'type': 'ISBN_13', 'identifier': '9780123456789'},
        ],
      });
      expect(result.isbn, '9780123456789');
    });

    test('falls back to ISBN_10 when no ISBN_13', () {
      final result = BookSearchResult.fromJson('id', {
        'title': 'Book',
        'industryIdentifiers': [
          {'type': 'ISBN_10', 'identifier': '0123456789'},
        ],
      });
      expect(result.isbn, '0123456789');
    });

    test('prefers larger cover images', () {
      final result = BookSearchResult.fromJson('id', {
        'title': 'Book',
        'imageLinks': {
          'smallThumbnail': 'http://example.com/small.jpg',
          'thumbnail': 'http://example.com/thumb.jpg',
          'large': 'http://example.com/large.jpg',
        },
      });
      // Should prefer large over thumbnail
      expect(result.coverUrl, contains('large'));
    });
  });
}
