import 'package:cultainer/core/constants/enums.dart';
import 'package:cultainer/models/entry.dart';
import 'package:cultainer/services/google_books_service.dart';
import 'package:cultainer/services/tmdb_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the media search service.
final mediaSearchServiceProvider = Provider<MediaSearchService>((ref) {
  final service = MediaSearchService();
  ref.onDispose(service.dispose);
  return service;
});

/// Unified service for searching media across different APIs.
class MediaSearchService {
  MediaSearchService()
      : _googleBooksService = GoogleBooksService(),
        _tmdbService = TmdbService();

  final GoogleBooksService _googleBooksService;
  final TmdbService _tmdbService;

  /// Searches for media based on type.
  Future<List<MediaSearchResult>> search(
    String query, {
    MediaType? type,
  }) async {
    if (query.isEmpty) return [];

    final results = <MediaSearchResult>[];

    try {
      // Search based on type or all if not specified
      if (type == null || type == MediaType.book) {
        final books = await _googleBooksService.searchBooks(query);
        results.addAll(books.map(MediaSearchResult.fromBook));
      }

      if (type == null || type == MediaType.movie) {
        final movies = await _tmdbService.searchMovies(query);
        results.addAll(movies.map(MediaSearchResult.fromMovie));
      }

      if (type == null || type == MediaType.tv) {
        final tvShows = await _tmdbService.searchTvShows(query);
        results.addAll(tvShows.map(MediaSearchResult.fromTvShow));
      }

      // Note: Spotify integration is lower priority
      // if (type == null || type == MediaType.music) {
      //   final tracks = await _spotifyService.searchTracks(query);
      //   results.addAll(tracks.map(MediaSearchResult.fromTrack));
      // }
      // }
    } catch (e) {
      // Ignore individual search failures, return what we have
    }

    return results;
  }

  /// Searches for books only.
  Future<List<MediaSearchResult>> searchBooks(String query) async {
    try {
      final books = await _googleBooksService.searchBooks(query);
      return books.map(MediaSearchResult.fromBook).toList();
    } catch (e) {
      return [];
    }
  }

  /// Searches for movies only.
  Future<List<MediaSearchResult>> searchMovies(String query) async {
    try {
      final movies = await _tmdbService.searchMovies(query);
      return movies.map(MediaSearchResult.fromMovie).toList();
    } catch (e) {
      return [];
    }
  }

  /// Searches for TV shows only.
  Future<List<MediaSearchResult>> searchTvShows(String query) async {
    try {
      final tvShows = await _tmdbService.searchTvShows(query);
      return tvShows.map(MediaSearchResult.fromTvShow).toList();
    } catch (e) {
      return [];
    }
  }

  void dispose() {
    _googleBooksService.dispose();
    _tmdbService.dispose();
  }
}

/// A unified search result from any media API.
class MediaSearchResult {
  const MediaSearchResult({
    required this.externalId,
    required this.title,
    required this.type,
    this.creator,
    this.coverUrl,
    this.description,
    this.releaseYear,
    this.extraInfo,
  });

  /// Creates from a Google Books result.
  factory MediaSearchResult.fromBook(BookSearchResult book) {
    return MediaSearchResult(
      externalId: 'gbooks:${book.id}',
      title: book.title,
      type: MediaType.book,
      creator: book.authors.join(', '),
      coverUrl: book.coverUrl,
      description: book.description,
      releaseYear:
          book.publishedDate?.length != null && book.publishedDate!.length >= 4
              ? book.publishedDate!.substring(0, 4)
              : null,
      extraInfo: book.pageCount != null ? '${book.pageCount} pages' : null,
    );
  }

  /// Creates from a TMDB movie result.
  factory MediaSearchResult.fromMovie(TmdbSearchResult movie) {
    return MediaSearchResult(
      externalId: 'tmdb:movie:${movie.id}',
      title: movie.title,
      type: MediaType.movie,
      creator: movie.director,
      coverUrl: movie.posterUrl,
      description: movie.overview,
      releaseYear: movie.releaseYear,
      extraInfo: movie.runtime != null ? '${movie.runtime} min' : null,
    );
  }

  /// Creates from a TMDB TV show result.
  factory MediaSearchResult.fromTvShow(TmdbSearchResult tvShow) {
    return MediaSearchResult(
      externalId: 'tmdb:tv:${tvShow.id}',
      title: tvShow.title,
      type: MediaType.tv,
      creator: tvShow.director,
      coverUrl: tvShow.posterUrl,
      description: tvShow.overview,
      releaseYear: tvShow.releaseYear,
      extraInfo: tvShow.numberOfSeasons != null
          ? '${tvShow.numberOfSeasons} seasons'
          : null,
    );
  }

  /// External ID from the source API.
  final String externalId;

  /// Title of the media.
  final String title;

  /// Type of media.
  final MediaType type;

  /// Creator (author, director, artist).
  final String? creator;

  /// Cover image URL.
  final String? coverUrl;

  /// Description or overview.
  final String? description;

  /// Release year.
  final String? releaseYear;

  /// Extra type-specific info (e.g., page count, runtime).
  final String? extraInfo;

  /// Converts to a partially filled Entry.
  Entry toEntry() {
    return Entry(
      id: '',
      title: title,
      type: type,
      status: EntryStatus.wishlist,
      creator: creator ?? '',
      coverUrl: coverUrl,
      review: description,
      externalId: externalId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
