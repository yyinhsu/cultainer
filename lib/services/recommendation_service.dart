import 'dart:convert';

import 'package:cultainer/core/constants/enums.dart';
import 'package:cultainer/features/auth/auth_providers.dart';
import 'package:cultainer/features/journal/entry_providers.dart';
import 'package:cultainer/models/entry.dart';
import 'package:cultainer/services/google_books_service.dart';
import 'package:cultainer/services/media_search_service.dart';
import 'package:cultainer/services/spotify_service.dart';
import 'package:cultainer/services/tmdb_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for the recommendation service.
final recommendationServiceProvider = Provider<RecommendationService>((ref) {
  final service = RecommendationService(
    tmdbService: TmdbService(),
    googleBooksService: GoogleBooksService(),
    spotifyService: SpotifyService(),
  );
  ref.onDispose(service.dispose);
  return service;
});

/// Provider for recommendations based on user's entries.
final recommendationsProvider =
    FutureProvider<List<Recommendation>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final entries = ref.watch(entriesProvider).valueOrNull ?? [];
  if (entries.isEmpty) return [];

  final service = ref.watch(recommendationServiceProvider);
  return service.getRecommendations(entries);
});

/// Provider for filtered recommendations by media type.
final filteredRecommendationsProvider =
    Provider.family<List<Recommendation>, MediaType?>((ref, type) {
  final recommendations = ref.watch(recommendationsProvider).valueOrNull ?? [];
  if (type == null) return recommendations;
  return recommendations.where((r) => r.result.type == type).toList();
});

/// A recommendation item with source info.
class Recommendation {
  const Recommendation({
    required this.result,
    required this.reason,
    required this.creatorName,
    required this.sourceEntryTitle,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    final r = json['result'] as Map<String, dynamic>;
    return Recommendation(
      result: MediaSearchResult(
        externalId: r['externalId'] as String,
        title: r['title'] as String,
        type: MediaType.fromValue(r['type'] as String),
        creator: r['creator'] as String?,
        creatorId: r['creatorId'] as String?,
        coverUrl: r['coverUrl'] as String?,
        releaseYear: r['releaseYear'] as String?,
        extraInfo: r['extraInfo'] as String?,
      ),
      reason: json['reason'] as String,
      creatorName: json['creatorName'] as String,
      sourceEntryTitle: json['sourceEntryTitle'] as String,
    );
  }

  /// The recommended media item.
  final MediaSearchResult result;

  /// Human-readable reason for the recommendation.
  final String reason;

  /// Creator name (director, author, artist).
  final String creatorName;

  /// Title of the entry that triggered this recommendation.
  final String sourceEntryTitle;

  Map<String, dynamic> toJson() => {
        'result': {
          'externalId': result.externalId,
          'title': result.title,
          'type': result.type.value,
          'creator': result.creator,
          'creatorId': result.creatorId,
          'coverUrl': result.coverUrl,
          'releaseYear': result.releaseYear,
          'extraInfo': result.extraInfo,
        },
        'reason': reason,
        'creatorName': creatorName,
        'sourceEntryTitle': sourceEntryTitle,
      };
}

/// Service that generates recommendations based on user's entries.
class RecommendationService {
  RecommendationService({
    required TmdbService tmdbService,
    required GoogleBooksService googleBooksService,
    required SpotifyService spotifyService,
  })  : _tmdbService = tmdbService,
        _googleBooksService = googleBooksService,
        _spotifyService = spotifyService;

  final TmdbService _tmdbService;
  final GoogleBooksService _googleBooksService;
  final SpotifyService _spotifyService;

  static const _cacheKey = 'recommendation_cache';
  static const _cacheTimestampKey = 'recommendation_cache_timestamp';
  static const _cacheDuration = Duration(hours: 1);

  List<Recommendation>? _memoryCache;
  DateTime? _memoryCacheTimestamp;

  /// Gets recommendations based on user's entries.
  ///
  /// Algorithm:
  /// 1. Get recent entries with creatorId (up to 10)
  /// 2. Extract unique creators
  /// 3. Fetch creator's other works from APIs
  /// 4. Filter out works already in user's entries
  /// 5. Merge and sort by release date (newest first)
  Future<List<Recommendation>> getRecommendations(
    List<Entry> entries,
  ) async {
    if (entries.isEmpty) return [];

    // Check memory cache first
    if (_memoryCache != null &&
        _memoryCacheTimestamp != null &&
        DateTime.now().difference(_memoryCacheTimestamp!) < _cacheDuration) {
      return _memoryCache!;
    }

    // Try loading from persistent cache
    final cached = await _loadCache();
    if (cached != null) {
      _memoryCache = cached;
      return cached;
    }

    // Generate fresh recommendations
    final recommendations = await _generateRecommendations(entries);
    _memoryCache = recommendations;
    _memoryCacheTimestamp = DateTime.now();

    // Persist cache
    await _saveCache(recommendations);

    return recommendations;
  }

  /// Invalidates the cache, forcing a refresh on next call.
  Future<void> invalidateCache() async {
    _memoryCache = null;
    _memoryCacheTimestamp = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_cacheTimestampKey);
    } on Exception catch (_) {
      // Ignore cache clear failures
    }
  }

  /// Whether the cache is stale (older than 1 hour).
  bool get isCacheStale {
    if (_memoryCacheTimestamp == null) return true;
    return DateTime.now().difference(_memoryCacheTimestamp!) >= _cacheDuration;
  }

  Future<List<Recommendation>> _generateRecommendations(
    List<Entry> entries,
  ) async {
    // Step 1: Get recent entries with creatorId
    final recentWithCreator = entries
        .where((e) => e.creatorId != null && e.creatorId!.isNotEmpty)
        .take(10)
        .toList();

    if (recentWithCreator.isEmpty) return [];

    // Step 2: Extract unique creators
    final creatorMap = <String, Entry>{};
    for (final entry in recentWithCreator) {
      creatorMap.putIfAbsent(entry.creatorId!, () => entry);
    }

    // Step 3: Fetch creator's other works from APIs
    final existingIds = entries
        .where((e) => e.externalId != null)
        .map((e) => e.externalId!)
        .toSet();
    final existingTitles = entries.map((e) => e.title.toLowerCase()).toSet();

    final recommendations = <Recommendation>[];

    for (final MapEntry(key: creatorId, value: sourceEntry)
        in creatorMap.entries) {
      try {
        final works = await _fetchCreatorWorks(creatorId, sourceEntry);

        // Step 4: Filter out existing entries
        for (final work in works) {
          if (existingIds.contains(work.externalId)) continue;
          if (existingTitles.contains(work.title.toLowerCase())) continue;

          recommendations.add(
            Recommendation(
              result: work,
              reason: 'Because you recorded "${sourceEntry.title}"',
              creatorName: sourceEntry.creator,
              sourceEntryTitle: sourceEntry.title,
            ),
          );
        }
      } on Exception catch (_) {
        // Skip creators whose API calls fail
      }
    }

    // Step 5: Sort by release year (newest first)
    recommendations.sort((a, b) {
      final yearA = a.result.releaseYear ?? '0000';
      final yearB = b.result.releaseYear ?? '0000';
      return yearB.compareTo(yearA);
    });

    return recommendations;
  }

  Future<List<MediaSearchResult>> _fetchCreatorWorks(
    String creatorId,
    Entry sourceEntry,
  ) async {
    if (creatorId.startsWith('tmdb:person:')) {
      return _fetchTmdbPersonWorks(creatorId, sourceEntry);
    } else if (creatorId.startsWith('gbooks:author:')) {
      return _fetchGoogleBooksAuthorWorks(creatorId);
    } else if (creatorId.startsWith('spotify:artist:')) {
      return _fetchSpotifyArtistWorks(creatorId);
    }
    return [];
  }

  Future<List<MediaSearchResult>> _fetchTmdbPersonWorks(
    String creatorId,
    Entry sourceEntry,
  ) async {
    final personId = int.tryParse(creatorId.replaceFirst('tmdb:person:', ''));
    if (personId == null) return [];

    final results = <MediaSearchResult>[];

    if (sourceEntry.type == MediaType.movie ||
        sourceEntry.type == MediaType.tv) {
      final movies = await _tmdbService.getPersonMovieCredits(personId);
      results.addAll(movies.map(MediaSearchResult.fromMovie));

      final tvShows = await _tmdbService.getPersonTvCredits(personId);
      results.addAll(tvShows.map(MediaSearchResult.fromTvShow));
    }

    return results;
  }

  Future<List<MediaSearchResult>> _fetchGoogleBooksAuthorWorks(
    String creatorId,
  ) async {
    final authorName = creatorId.replaceFirst('gbooks:author:', '');
    if (authorName.isEmpty) return [];

    final books = await _googleBooksService.searchBooks('inauthor:$authorName');
    return books.map(MediaSearchResult.fromBook).toList();
  }

  Future<List<MediaSearchResult>> _fetchSpotifyArtistWorks(
    String creatorId,
  ) async {
    final artistId = creatorId.replaceFirst('spotify:artist:', '');
    if (artistId.isEmpty || !_spotifyService.isConfigured) return [];

    final albums = await _spotifyService.getArtistAlbums(artistId);
    return albums.map((album) {
      return MediaSearchResult(
        externalId: 'spotify:album:${album.id}',
        title: album.name,
        type: MediaType.music,
        creator: album.artist,
        creatorId: creatorId,
        coverUrl: album.coverUrl,
        releaseYear: album.releaseYear,
      );
    }).toList();
  }

  Future<void> _saveCache(List<Recommendation> recommendations) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = recommendations.map((r) => r.toJson()).toList();
      await prefs.setString(_cacheKey, json.encode(jsonList));
      await prefs.setInt(
        _cacheTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } on Exception catch (_) {
      // Ignore cache save failures
    }
  }

  Future<List<Recommendation>?> _loadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_cacheTimestampKey);
      if (timestamp == null) return null;

      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      if (DateTime.now().difference(cacheTime) >= _cacheDuration) {
        return null;
      }

      final jsonStr = prefs.getString(_cacheKey);
      if (jsonStr == null) return null;

      final jsonList = json.decode(jsonStr) as List<dynamic>;
      final recommendations = jsonList
          .map(
            (item) => Recommendation.fromJson(item as Map<String, dynamic>),
          )
          .toList();

      _memoryCacheTimestamp = cacheTime;
      return recommendations;
    } on Exception catch (_) {
      return null;
    }
  }

  void dispose() {
    _tmdbService.dispose();
    _googleBooksService.dispose();
    _spotifyService.dispose();
  }
}
