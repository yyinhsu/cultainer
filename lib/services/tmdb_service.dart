import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Service for searching movies and TV shows via TMDB API.
class TmdbService {
  TmdbService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _baseUrl = 'https://api.themoviedb.org/3';
  static const _imageBaseUrl = 'https://image.tmdb.org/t/p';

  String get _apiKey => dotenv.env['TMDB_API_KEY'] ?? '';

  /// Searches for movies by query string.
  Future<List<TmdbSearchResult>> searchMovies(
    String query, {
    int page = 1,
  }) async {
    if (query.isEmpty || _apiKey.isEmpty) return [];

    final uri = Uri.parse('$_baseUrl/search/movie').replace(
      queryParameters: {
        'api_key': _apiKey,
        'query': query,
        'page': page.toString(),
        'include_adult': 'false',
      },
    );

    return _performSearch(uri, TmdbMediaType.movie);
  }

  /// Searches for TV shows by query string.
  Future<List<TmdbSearchResult>> searchTvShows(
    String query, {
    int page = 1,
  }) async {
    if (query.isEmpty || _apiKey.isEmpty) return [];

    final uri = Uri.parse('$_baseUrl/search/tv').replace(
      queryParameters: {
        'api_key': _apiKey,
        'query': query,
        'page': page.toString(),
        'include_adult': 'false',
      },
    );

    return _performSearch(uri, TmdbMediaType.tv);
  }

  /// Searches for both movies and TV shows.
  Future<List<TmdbSearchResult>> searchMulti(
    String query, {
    int page = 1,
  }) async {
    if (query.isEmpty || _apiKey.isEmpty) return [];

    final uri = Uri.parse('$_baseUrl/search/multi').replace(
      queryParameters: {
        'api_key': _apiKey,
        'query': query,
        'page': page.toString(),
        'include_adult': 'false',
      },
    );

    try {
      final response = await _client.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Failed to search: ${response.statusCode}');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>?;

      if (results == null) return [];

      return results.where((item) {
        final mediaType = item['media_type'] as String?;
        return mediaType == 'movie' || mediaType == 'tv';
      }).map((item) {
        final mediaType = item['media_type'] as String?;
        return TmdbSearchResult.fromJson(
          item as Map<String, dynamic>,
          mediaType == 'tv' ? TmdbMediaType.tv : TmdbMediaType.movie,
        );
      }).toList();
    } catch (e) {
      throw Exception('Error searching: $e');
    }
  }

  Future<List<TmdbSearchResult>> _performSearch(
    Uri uri,
    TmdbMediaType mediaType,
  ) async {
    try {
      final response = await _client.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Failed to search: ${response.statusCode}');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>?;

      if (results == null) return [];

      return results.map((item) {
        return TmdbSearchResult.fromJson(
          item as Map<String, dynamic>,
          mediaType,
        );
      }).toList();
    } catch (e) {
      throw Exception('Error searching: $e');
    }
  }

  /// Gets detailed information about a movie.
  Future<TmdbSearchResult?> getMovieDetails(int movieId) async {
    if (_apiKey.isEmpty) return null;

    final uri = Uri.parse('$_baseUrl/movie/$movieId').replace(
      queryParameters: {
        'api_key': _apiKey,
        'append_to_response': 'credits',
      },
    );

    return _getDetails(uri, TmdbMediaType.movie);
  }

  /// Gets detailed information about a TV show.
  Future<TmdbSearchResult?> getTvShowDetails(int tvId) async {
    if (_apiKey.isEmpty) return null;

    final uri = Uri.parse('$_baseUrl/tv/$tvId').replace(
      queryParameters: {
        'api_key': _apiKey,
        'append_to_response': 'credits',
      },
    );

    return _getDetails(uri, TmdbMediaType.tv);
  }

  Future<TmdbSearchResult?> _getDetails(
    Uri uri,
    TmdbMediaType mediaType,
  ) async {
    try {
      final response = await _client.get(uri);

      if (response.statusCode != 200) {
        return null;
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      return TmdbSearchResult.fromJson(data, mediaType);
    } catch (e) {
      return null;
    }
  }

  /// Gets high quality poster URL.
  static String? getPosterUrl(
    String? posterPath, {
    TmdbImageSize size = TmdbImageSize.w500,
  }) {
    if (posterPath == null) return null;
    return '$_imageBaseUrl/${size.value}$posterPath';
  }

  void dispose() {
    _client.close();
  }
}

/// TMDB media type.
enum TmdbMediaType {
  movie,
  tv,
}

/// TMDB image sizes.
enum TmdbImageSize {
  w92('w92'),
  w154('w154'),
  w185('w185'),
  w342('w342'),
  w500('w500'),
  w780('w780'),
  original('original');

  const TmdbImageSize(this.value);
  final String value;
}

/// A search result from TMDB API.
class TmdbSearchResult {
  const TmdbSearchResult({
    required this.id,
    required this.title,
    required this.mediaType,
    this.posterPath,
    this.overview,
    this.releaseDate,
    this.voteAverage,
    this.director,
    this.genres,
    this.runtime,
    this.numberOfSeasons,
  });

  /// Creates from TMDB API JSON.
  factory TmdbSearchResult.fromJson(
    Map<String, dynamic> json,
    TmdbMediaType mediaType,
  ) {
    // Extract director from credits if available
    String? director;
    final credits = json['credits'] as Map<String, dynamic>?;
    if (credits != null) {
      final crew = credits['crew'] as List<dynamic>?;
      if (crew != null) {
        for (final member in crew) {
          final job = (member as Map<String, dynamic>)['job'] as String?;
          if (job == 'Director') {
            director = member['name'] as String?;
            break;
          }
        }
      }
      // For TV, use created_by or first crew member
      if (director == null && mediaType == TmdbMediaType.tv) {
        final createdBy = json['created_by'] as List<dynamic>?;
        if (createdBy != null && createdBy.isNotEmpty) {
          director =
              (createdBy.first as Map<String, dynamic>)['name'] as String?;
        }
      }
    }

    // Extract genres
    final genresList = json['genres'] as List<dynamic>?;
    final genres = genresList
        ?.map((g) => (g as Map<String, dynamic>)['name'] as String)
        .toList();

    return TmdbSearchResult(
      id: json['id'] as int,
      title: (mediaType == TmdbMediaType.tv
              ? json['name'] as String?
              : json['title'] as String?) ??
          'Unknown',
      mediaType: mediaType,
      posterPath: json['poster_path'] as String?,
      overview: json['overview'] as String?,
      releaseDate: mediaType == TmdbMediaType.tv
          ? json['first_air_date'] as String?
          : json['release_date'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
      director: director,
      genres: genres,
      runtime: json['runtime'] as int?,
      numberOfSeasons: json['number_of_seasons'] as int?,
    );
  }

  /// TMDB ID.
  final int id;

  /// Title (movie) or name (TV).
  final String title;

  /// Media type (movie or tv).
  final TmdbMediaType mediaType;

  /// Poster path (use [TmdbService.getPosterUrl] to get full URL).
  final String? posterPath;

  /// Plot overview.
  final String? overview;

  /// Release date (movie) or first air date (TV).
  final String? releaseDate;

  /// Vote average (0-10).
  final double? voteAverage;

  /// Director (movie) or creator (TV).
  final String? director;

  /// Genre names.
  final List<String>? genres;

  /// Runtime in minutes (movie only).
  final int? runtime;

  /// Number of seasons (TV only).
  final int? numberOfSeasons;

  /// Gets the full poster URL.
  String? get posterUrl => TmdbService.getPosterUrl(posterPath);

  /// Release year extracted from date.
  String? get releaseYear {
    if (releaseDate == null || releaseDate!.length < 4) return null;
    return releaseDate!.substring(0, 4);
  }
}
