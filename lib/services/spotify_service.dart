import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Service for searching music via Spotify Web API.
class SpotifyService {
  SpotifyService({
    http.Client? client,
    String? clientId,
    String? clientSecret,
  })  : _client = client ?? http.Client(),
        _clientId = clientId,
        _clientSecret = clientSecret;

  final http.Client _client;
  static const _baseUrl = 'https://api.spotify.com/v1';
  static const _authUrl = 'https://accounts.spotify.com/api/token';

  String? _accessToken;
  DateTime? _tokenExpiry;
  final String? _clientId;
  final String? _clientSecret;

  String get _resolvedClientId =>
      _clientId ?? (dotenv.env['SPOTIFY_CLIENT_ID'] ?? '');
  String get _resolvedClientSecret =>
      _clientSecret ?? (dotenv.env['SPOTIFY_CLIENT_SECRET'] ?? '');

  /// Whether the service has valid credentials configured.
  bool get isConfigured =>
      _resolvedClientId.isNotEmpty && _resolvedClientSecret.isNotEmpty;

  /// Authenticates with Spotify using client credentials flow.
  Future<void> _authenticate() async {
    if (_accessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return;
    }

    final credentials = base64.encode(
      utf8.encode('$_resolvedClientId:$_resolvedClientSecret'),
    );

    final response = await _client.post(
      Uri.parse(_authUrl),
      headers: {
        'Authorization': 'Basic $credentials',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: 'grant_type=client_credentials',
    );

    if (response.statusCode != 200) {
      throw SpotifyException(
        'Authentication failed: ${response.statusCode}',
      );
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    _accessToken = data['access_token'] as String;
    final expiresIn = data['expires_in'] as int;
    _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn - 60));
  }

  /// Searches for tracks by query string.
  Future<List<SpotifySearchResult>> searchTracks(
    String query, {
    int limit = 10,
  }) async {
    if (query.isEmpty || !isConfigured) return [];

    await _authenticate();

    final uri = Uri.parse('$_baseUrl/search').replace(
      queryParameters: {
        'q': query,
        'type': 'track',
        'limit': limit.toString(),
      },
    );

    final response = await _client.get(
      uri,
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    if (response.statusCode != 200) {
      throw SpotifyException('Search failed: ${response.statusCode}');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final tracks = data['tracks'] as Map<String, dynamic>?;
    final items = tracks?['items'] as List<dynamic>?;

    if (items == null) return [];

    return items.map((item) {
      return SpotifySearchResult.fromJson(item as Map<String, dynamic>);
    }).toList();
  }

  /// Searches for albums by query string.
  Future<List<SpotifySearchResult>> searchAlbums(
    String query, {
    int limit = 10,
  }) async {
    if (query.isEmpty || !isConfigured) return [];

    await _authenticate();

    final uri = Uri.parse('$_baseUrl/search').replace(
      queryParameters: {
        'q': query,
        'type': 'album',
        'limit': limit.toString(),
      },
    );

    final response = await _client.get(
      uri,
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    if (response.statusCode != 200) {
      throw SpotifyException('Search failed: ${response.statusCode}');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final albums = data['albums'] as Map<String, dynamic>?;
    final items = albums?['items'] as List<dynamic>?;

    if (items == null) return [];

    return items.map((item) {
      return SpotifySearchResult.fromAlbumJson(item as Map<String, dynamic>);
    }).toList();
  }

  void dispose() {
    _client.close();
  }
}

/// A search result from Spotify API.
class SpotifySearchResult {
  const SpotifySearchResult({
    required this.id,
    required this.name,
    required this.artist,
    this.artistId,
    this.albumName,
    this.coverUrl,
    this.releaseDate,
    this.isAlbum = false,
  });

  /// Creates from a Spotify track JSON response.
  factory SpotifySearchResult.fromJson(Map<String, dynamic> json) {
    final artists = json['artists'] as List<dynamic>? ?? [];
    final album = json['album'] as Map<String, dynamic>?;
    final images = album?['images'] as List<dynamic>? ?? [];

    return SpotifySearchResult(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Unknown',
      artist: artists.isNotEmpty
          ? (artists.first as Map<String, dynamic>)['name'] as String? ??
              'Unknown'
          : 'Unknown',
      artistId: artists.isNotEmpty
          ? (artists.first as Map<String, dynamic>)['id'] as String?
          : null,
      albumName: album?['name'] as String?,
      coverUrl: images.isNotEmpty
          ? (images.first as Map<String, dynamic>)['url'] as String?
          : null,
      releaseDate: album?['release_date'] as String?,
    );
  }

  /// Creates from a Spotify album JSON response.
  factory SpotifySearchResult.fromAlbumJson(Map<String, dynamic> json) {
    final artists = json['artists'] as List<dynamic>? ?? [];
    final images = json['images'] as List<dynamic>? ?? [];

    return SpotifySearchResult(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Unknown',
      artist: artists.isNotEmpty
          ? (artists.first as Map<String, dynamic>)['name'] as String? ??
              'Unknown'
          : 'Unknown',
      artistId: artists.isNotEmpty
          ? (artists.first as Map<String, dynamic>)['id'] as String?
          : null,
      coverUrl: images.isNotEmpty
          ? (images.first as Map<String, dynamic>)['url'] as String?
          : null,
      releaseDate: json['release_date'] as String?,
      isAlbum: true,
    );
  }

  /// Spotify ID.
  final String id;

  /// Track or album name.
  final String name;

  /// Primary artist name.
  final String artist;

  /// Spotify artist ID.
  final String? artistId;

  /// Album name (for tracks).
  final String? albumName;

  /// Cover image URL.
  final String? coverUrl;

  /// Release date.
  final String? releaseDate;

  /// Whether this result is an album (vs a track).
  final bool isAlbum;

  /// Release year extracted from date.
  String? get releaseYear {
    if (releaseDate == null || releaseDate!.length < 4) return null;
    return releaseDate!.substring(0, 4);
  }
}

/// Exception thrown by SpotifyService.
class SpotifyException implements Exception {
  const SpotifyException(this.message);

  final String message;

  @override
  String toString() => 'SpotifyException: $message';
}
