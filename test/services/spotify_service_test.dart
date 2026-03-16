import 'package:cultainer/services/spotify_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  late MockHttpClient mockClient;

  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  setUp(() {
    mockClient = MockHttpClient();
  });

  group('SpotifyService', () {
    group('isConfigured', () {
      test('returns false when no credentials', () {
        final service = SpotifyService(
          client: mockClient,
          clientId: '',
          clientSecret: '',
        );
        expect(service.isConfigured, isFalse);
      });

      test('returns true when credentials provided', () {
        final service = SpotifyService(
          client: mockClient,
          clientId: 'id',
          clientSecret: 'secret',
        );
        expect(service.isConfigured, isTrue);
      });
    });

    group('searchTracks', () {
      test('returns empty list when query is empty', () async {
        final service = SpotifyService(
          client: mockClient,
          clientId: '',
          clientSecret: '',
        );
        final result = await service.searchTracks('');
        expect(result, isEmpty);
      });

      test('returns empty list when not configured', () async {
        final service = SpotifyService(
          client: mockClient,
          clientId: '',
          clientSecret: '',
        );
        final result = await service.searchTracks('test');
        expect(result, isEmpty);
      });
    });

    group('searchAlbums', () {
      test('returns empty list when query is empty', () async {
        final service = SpotifyService(
          client: mockClient,
          clientId: '',
          clientSecret: '',
        );
        final result = await service.searchAlbums('');
        expect(result, isEmpty);
      });

      test('returns empty list when not configured', () async {
        final service = SpotifyService(
          client: mockClient,
          clientId: '',
          clientSecret: '',
        );
        final result = await service.searchAlbums('test');
        expect(result, isEmpty);
      });
    });

    group('SpotifySearchResult', () {
      test('fromJson parses track correctly', () {
        final json = <String, dynamic>{
          'id': 'track123',
          'name': 'Test Song',
          'artists': [
            {'id': 'artist1', 'name': 'Test Artist'},
          ],
          'album': {
            'name': 'Test Album',
            'release_date': '2024-01-15',
            'images': [
              {'url': 'https://example.com/cover.jpg', 'width': 640},
            ],
          },
        };

        final result = SpotifySearchResult.fromJson(json);
        expect(result.id, 'track123');
        expect(result.name, 'Test Song');
        expect(result.artist, 'Test Artist');
        expect(result.artistId, 'artist1');
        expect(result.albumName, 'Test Album');
        expect(result.coverUrl, 'https://example.com/cover.jpg');
        expect(result.releaseDate, '2024-01-15');
        expect(result.releaseYear, '2024');
        expect(result.isAlbum, isFalse);
      });

      test('fromJson handles missing artists', () {
        final json = <String, dynamic>{
          'id': 'track456',
          'name': 'No Artist Song',
          'artists': <dynamic>[],
        };

        final result = SpotifySearchResult.fromJson(json);
        expect(result.artist, 'Unknown');
        expect(result.artistId, isNull);
      });

      test('fromJson handles missing album', () {
        final json = <String, dynamic>{
          'id': 'track789',
          'name': 'No Album Song',
          'artists': [
            {'id': 'a1', 'name': 'Artist'},
          ],
        };

        final result = SpotifySearchResult.fromJson(json);
        expect(result.albumName, isNull);
        expect(result.coverUrl, isNull);
      });

      test('fromAlbumJson parses album correctly', () {
        final json = <String, dynamic>{
          'id': 'album123',
          'name': 'Test Album',
          'artists': [
            {'id': 'artist2', 'name': 'Album Artist'},
          ],
          'release_date': '2023',
          'images': [
            {'url': 'https://example.com/album.jpg', 'width': 640},
          ],
        };

        final result = SpotifySearchResult.fromAlbumJson(json);
        expect(result.id, 'album123');
        expect(result.name, 'Test Album');
        expect(result.artist, 'Album Artist');
        expect(result.artistId, 'artist2');
        expect(result.coverUrl, 'https://example.com/album.jpg');
        expect(result.releaseYear, '2023');
        expect(result.isAlbum, isTrue);
      });

      test('releaseYear returns null for short date', () {
        const result = SpotifySearchResult(
          id: 'x',
          name: 'x',
          artist: 'x',
          releaseDate: '20',
        );
        expect(result.releaseYear, isNull);
      });

      test('releaseYear returns null when no date', () {
        const result = SpotifySearchResult(
          id: 'x',
          name: 'x',
          artist: 'x',
        );
        expect(result.releaseYear, isNull);
      });
    });

    group('SpotifyException', () {
      test('toString returns formatted message', () {
        const exception = SpotifyException('test error');
        expect(exception.toString(), 'SpotifyException: test error');
      });

      test('message property returns the message', () {
        const exception = SpotifyException('some message');
        expect(exception.message, 'some message');
      });
    });
  });
}
