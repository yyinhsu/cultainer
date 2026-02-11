import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Service for searching books via Google Books API.
class GoogleBooksService {
  GoogleBooksService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _baseUrl = 'https://www.googleapis.com/books/v1';

  /// Searches for books by query string.
  ///
  /// Returns a list of [BookSearchResult].
  Future<List<BookSearchResult>> searchBooks(
    String query, {
    int maxResults = 10,
  }) async {
    if (query.isEmpty) return [];

    final apiKey = dotenv.env['GOOGLE_BOOKS_API_KEY'] ?? '';
    final uri = Uri.parse('$_baseUrl/volumes').replace(
      queryParameters: {
        'q': query,
        'maxResults': maxResults.toString(),
        if (apiKey.isNotEmpty) 'key': apiKey,
      },
    );

    try {
      final response = await _client.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Failed to search books: ${response.statusCode}');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>?;

      if (items == null) return [];

      return items.map((item) {
        final volumeInfo = item['volumeInfo'] as Map<String, dynamic>? ?? {};
        return BookSearchResult.fromJson(
          item['id'] as String,
          volumeInfo,
        );
      }).toList();
    } catch (e) {
      throw Exception('Error searching books: $e');
    }
  }

  /// Gets detailed information about a specific book.
  Future<BookSearchResult?> getBookDetails(String bookId) async {
    final apiKey = dotenv.env['GOOGLE_BOOKS_API_KEY'] ?? '';
    final uri = Uri.parse('$_baseUrl/volumes/$bookId').replace(
      queryParameters: {
        if (apiKey.isNotEmpty) 'key': apiKey,
      },
    );

    try {
      final response = await _client.get(uri);

      if (response.statusCode != 200) {
        return null;
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final volumeInfo = data['volumeInfo'] as Map<String, dynamic>? ?? {};

      return BookSearchResult.fromJson(
        data['id'] as String,
        volumeInfo,
      );
    } catch (e) {
      return null;
    }
  }

  void dispose() {
    _client.close();
  }
}

/// A book search result from Google Books API.
class BookSearchResult {
  const BookSearchResult({
    required this.id,
    required this.title,
    required this.authors,
    this.coverUrl,
    this.description,
    this.pageCount,
    this.publishedDate,
    this.publisher,
    this.categories,
    this.isbn,
  });

  /// Creates from Google Books API JSON.
  factory BookSearchResult.fromJson(String id, Map<String, dynamic> json) {
    // Get the best available cover image
    final imageLinks = json['imageLinks'] as Map<String, dynamic>?;
    String? coverUrl;
    if (imageLinks != null) {
      // Prefer larger images
      coverUrl = imageLinks['extraLarge'] as String? ??
          imageLinks['large'] as String? ??
          imageLinks['medium'] as String? ??
          imageLinks['thumbnail'] as String? ??
          imageLinks['smallThumbnail'] as String?;
      // Upgrade HTTP to HTTPS
      if (coverUrl != null && coverUrl.startsWith('http:')) {
        coverUrl = coverUrl.replaceFirst('http:', 'https:');
      }
    }

    // Extract ISBN
    final industryIdentifiers =
        json['industryIdentifiers'] as List<dynamic>? ?? [];
    String? isbn;
    for (final identifier in industryIdentifiers) {
      final type = (identifier as Map<String, dynamic>)['type'] as String?;
      if (type == 'ISBN_13') {
        isbn = identifier['identifier'] as String?;
        break;
      } else if (type == 'ISBN_10' && isbn == null) {
        isbn = identifier['identifier'] as String?;
      }
    }

    return BookSearchResult(
      id: id,
      title: json['title'] as String? ?? 'Unknown Title',
      authors: (json['authors'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      coverUrl: coverUrl,
      description: json['description'] as String?,
      pageCount: json['pageCount'] as int?,
      publishedDate: json['publishedDate'] as String?,
      publisher: json['publisher'] as String?,
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isbn: isbn,
    );
  }

  /// Google Books volume ID.
  final String id;

  /// Book title.
  final String title;

  /// List of authors.
  final List<String> authors;

  /// Cover image URL (high quality).
  final String? coverUrl;

  /// Book description.
  final String? description;

  /// Number of pages.
  final int? pageCount;

  /// Publication date.
  final String? publishedDate;

  /// Publisher name.
  final String? publisher;

  /// Categories/genres.
  final List<String>? categories;

  /// ISBN (13 or 10).
  final String? isbn;

  /// Primary author (first in list).
  String get primaryAuthor => authors.isNotEmpty ? authors.first : 'Unknown';
}
