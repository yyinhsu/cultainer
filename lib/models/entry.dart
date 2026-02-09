import 'package:equatable/equatable.dart';

import '../core/constants/enums.dart';

/// Represents a media entry in the user's journal.
class Entry extends Equatable {
  const Entry({
    required this.id,
    required this.type,
    required this.title,
    required this.creator,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.creatorId,
    this.coverUrl,
    this.coverStoragePath,
    this.externalId,
    this.rating,
    this.review,
    this.tags = const [],
    this.startDate,
    this.endDate,
    this.metadata = const {},
  });

  /// Unique identifier.
  final String id;

  /// Media type (book, movie, tv, music, other).
  final MediaType type;

  /// Title of the media.
  final String title;

  /// Creator name (author, director, artist).
  final String creator;

  /// Creator ID from external API (for recommendations).
  final String? creatorId;

  /// Cover image URL from external API.
  final String? coverUrl;

  /// Firebase Storage path (only for "other" type with uploaded covers).
  final String? coverStoragePath;

  /// External API ID (Google Books ID, TMDB ID, Spotify ID).
  final String? externalId;

  /// Current status of the entry.
  final EntryStatus status;

  /// Rating on a 10-point scale (0.5 increments).
  final double? rating;

  /// User's review text.
  final String? review;

  /// List of tag IDs.
  final List<String> tags;

  /// Date when user started this media.
  final DateTime? startDate;

  /// Date when user finished this media.
  final DateTime? endDate;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Last update timestamp.
  final DateTime updatedAt;

  /// Additional metadata (page count, duration, episode count, etc.).
  final Map<String, dynamic> metadata;

  /// Creates a copy with updated fields.
  Entry copyWith({
    String? id,
    MediaType? type,
    String? title,
    String? creator,
    String? creatorId,
    String? coverUrl,
    String? coverStoragePath,
    String? externalId,
    EntryStatus? status,
    double? rating,
    String? review,
    List<String>? tags,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Entry(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      creator: creator ?? this.creator,
      creatorId: creatorId ?? this.creatorId,
      coverUrl: coverUrl ?? this.coverUrl,
      coverStoragePath: coverStoragePath ?? this.coverStoragePath,
      externalId: externalId ?? this.externalId,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      tags: tags ?? this.tags,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Converts to Firestore document.
  Map<String, dynamic> toFirestore() {
    return {
      'type': type.value,
      'title': title,
      'creator': creator,
      'creatorId': creatorId,
      'coverUrl': coverUrl,
      'coverStoragePath': coverStoragePath,
      'externalId': externalId,
      'status': status.value,
      'rating': rating,
      'review': review,
      'tags': tags,
      'startDate': startDate?.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'metadata': metadata,
    };
  }

  /// Creates from Firestore document.
  factory Entry.fromFirestore(String id, Map<String, dynamic> data) {
    return Entry(
      id: id,
      type: MediaType.fromValue(data['type'] as String? ?? 'other'),
      title: data['title'] as String? ?? '',
      creator: data['creator'] as String? ?? '',
      creatorId: data['creatorId'] as String?,
      coverUrl: data['coverUrl'] as String?,
      coverStoragePath: data['coverStoragePath'] as String?,
      externalId: data['externalId'] as String?,
      status: EntryStatus.fromValue(data['status'] as String? ?? 'wishlist'),
      rating: (data['rating'] as num?)?.toDouble(),
      review: data['review'] as String?,
      tags: List<String>.from(data['tags'] as List? ?? []),
      startDate: data['startDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['startDate'] as int)
          : null,
      endDate: data['endDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['endDate'] as int)
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        data['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        data['updatedAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      metadata: Map<String, dynamic>.from(data['metadata'] as Map? ?? {}),
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        creator,
        creatorId,
        coverUrl,
        coverStoragePath,
        externalId,
        status,
        rating,
        review,
        tags,
        startDate,
        endDate,
        createdAt,
        updatedAt,
        metadata,
      ];
}
