import 'package:cultainer/core/constants/enums.dart';
import 'package:cultainer/models/entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 3, 15);
  final later = DateTime(2026, 3, 20);

  Entry createEntry({
    String id = 'entry-1',
    MediaType type = MediaType.book,
    String title = 'Test Book',
    String creator = 'Author Name',
    EntryStatus status = EntryStatus.inProgress,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? creatorId,
    String? coverUrl,
    String? coverStoragePath,
    String? externalId,
    double? rating,
    String? review,
    List<String> tags = const [],
    DateTime? startDate,
    DateTime? endDate,
    Map<String, dynamic> metadata = const {},
  }) {
    return Entry(
      id: id,
      type: type,
      title: title,
      creator: creator,
      status: status,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      creatorId: creatorId,
      coverUrl: coverUrl,
      coverStoragePath: coverStoragePath,
      externalId: externalId,
      rating: rating,
      review: review,
      tags: tags,
      startDate: startDate,
      endDate: endDate,
      metadata: metadata,
    );
  }

  group('Entry', () {
    group('constructor', () {
      test('creates instance with required fields', () {
        final entry = createEntry();

        expect(entry.id, 'entry-1');
        expect(entry.type, MediaType.book);
        expect(entry.title, 'Test Book');
        expect(entry.creator, 'Author Name');
        expect(entry.status, EntryStatus.inProgress);
        expect(entry.createdAt, now);
        expect(entry.updatedAt, now);
      });

      test('optional fields default correctly', () {
        final entry = createEntry();

        expect(entry.creatorId, isNull);
        expect(entry.coverUrl, isNull);
        expect(entry.coverStoragePath, isNull);
        expect(entry.externalId, isNull);
        expect(entry.rating, isNull);
        expect(entry.review, isNull);
        expect(entry.tags, isEmpty);
        expect(entry.startDate, isNull);
        expect(entry.endDate, isNull);
        expect(entry.metadata, isEmpty);
      });

      test('creates instance with all fields', () {
        final entry = createEntry(
          creatorId: 'creator-1',
          coverUrl: 'https://example.com/cover.jpg',
          coverStoragePath: 'covers/entry-1.jpg',
          externalId: 'ext-123',
          rating: 8.5,
          review: 'Great book!',
          tags: ['tag-1', 'tag-2'],
          startDate: now,
          endDate: later,
          metadata: {'pageCount': 300},
        );

        expect(entry.creatorId, 'creator-1');
        expect(entry.coverUrl, 'https://example.com/cover.jpg');
        expect(entry.coverStoragePath, 'covers/entry-1.jpg');
        expect(entry.externalId, 'ext-123');
        expect(entry.rating, 8.5);
        expect(entry.review, 'Great book!');
        expect(entry.tags, ['tag-1', 'tag-2']);
        expect(entry.startDate, now);
        expect(entry.endDate, later);
        expect(entry.metadata, {'pageCount': 300});
      });
    });

    group('copyWith', () {
      test('returns identical copy when no arguments provided', () {
        final entry = createEntry(rating: 7.0, review: 'Good');
        final copy = entry.copyWith();

        expect(copy, equals(entry));
      });

      test('updates only specified fields', () {
        final entry = createEntry();
        final copy = entry.copyWith(
          title: 'Updated Title',
          status: EntryStatus.completed,
          rating: 9.0,
        );

        expect(copy.title, 'Updated Title');
        expect(copy.status, EntryStatus.completed);
        expect(copy.rating, 9.0);
        // Unchanged fields
        expect(copy.id, entry.id);
        expect(copy.type, entry.type);
        expect(copy.creator, entry.creator);
        expect(copy.createdAt, entry.createdAt);
      });
    });

    group('toFirestore', () {
      test('produces correct map', () {
        final entry = createEntry(
          rating: 8.5,
          review: 'Great!',
          tags: ['tag-1'],
          startDate: now,
          endDate: later,
          metadata: {'pageCount': 200},
          coverUrl: 'https://example.com/cover.jpg',
          externalId: 'ext-1',
        );
        final json = entry.toFirestore();

        expect(json['type'], 'book');
        expect(json['title'], 'Test Book');
        expect(json['creator'], 'Author Name');
        expect(json['status'], 'in-progress');
        expect(json['rating'], 8.5);
        expect(json['review'], 'Great!');
        expect(json['tags'], ['tag-1']);
        expect(json['startDate'], now.millisecondsSinceEpoch);
        expect(json['endDate'], later.millisecondsSinceEpoch);
        expect(json['createdAt'], now.millisecondsSinceEpoch);
        expect(json['updatedAt'], now.millisecondsSinceEpoch);
        expect(json['metadata'], {'pageCount': 200});
        expect(json['coverUrl'], 'https://example.com/cover.jpg');
        expect(json['externalId'], 'ext-1');
      });

      test('includes null for optional fields when not set', () {
        final entry = createEntry();
        final json = entry.toFirestore();

        expect(json['rating'], isNull);
        expect(json['review'], isNull);
        expect(json['startDate'], isNull);
        expect(json['endDate'], isNull);
        expect(json['coverUrl'], isNull);
        expect(json['creatorId'], isNull);
      });

      test('does not include id field', () {
        final entry = createEntry();
        final json = entry.toFirestore();

        expect(json.containsKey('id'), isFalse);
      });
    });

    group('fromFirestore', () {
      test('reconstructs entry from complete data', () {
        final data = {
          'type': 'movie',
          'title': 'Test Movie',
          'creator': 'Director Name',
          'creatorId': 'creator-1',
          'coverUrl': 'https://example.com/poster.jpg',
          'coverStoragePath': null,
          'externalId': 'tmdb-123',
          'status': 'completed',
          'rating': 9.0,
          'review': 'Amazing!',
          'tags': ['tag-1', 'tag-2'],
          'startDate': now.millisecondsSinceEpoch,
          'endDate': later.millisecondsSinceEpoch,
          'createdAt': now.millisecondsSinceEpoch,
          'updatedAt': later.millisecondsSinceEpoch,
          'metadata': {'duration': 120},
        };

        final entry = Entry.fromFirestore('entry-1', data);

        expect(entry.id, 'entry-1');
        expect(entry.type, MediaType.movie);
        expect(entry.title, 'Test Movie');
        expect(entry.creator, 'Director Name');
        expect(entry.creatorId, 'creator-1');
        expect(entry.coverUrl, 'https://example.com/poster.jpg');
        expect(entry.externalId, 'tmdb-123');
        expect(entry.status, EntryStatus.completed);
        expect(entry.rating, 9.0);
        expect(entry.review, 'Amazing!');
        expect(entry.tags, ['tag-1', 'tag-2']);
        expect(entry.startDate, now);
        expect(entry.endDate, later);
        expect(entry.createdAt, now);
        expect(entry.updatedAt, later);
        expect(entry.metadata, {'duration': 120});
      });

      test('handles missing optional fields with defaults', () {
        final data = <String, dynamic>{
          'createdAt': now.millisecondsSinceEpoch,
          'updatedAt': now.millisecondsSinceEpoch,
        };

        final entry = Entry.fromFirestore('entry-2', data);

        expect(entry.id, 'entry-2');
        expect(entry.type, MediaType.other);
        expect(entry.title, '');
        expect(entry.creator, '');
        expect(entry.status, EntryStatus.wishlist);
        expect(entry.rating, isNull);
        expect(entry.review, isNull);
        expect(entry.tags, isEmpty);
        expect(entry.startDate, isNull);
        expect(entry.endDate, isNull);
        expect(entry.metadata, isEmpty);
      });

      test('handles unknown type and status values gracefully', () {
        final data = {
          'type': 'unknown-type',
          'status': 'unknown-status',
          'createdAt': now.millisecondsSinceEpoch,
          'updatedAt': now.millisecondsSinceEpoch,
        };

        final entry = Entry.fromFirestore('entry-3', data);

        expect(entry.type, MediaType.other);
        expect(entry.status, EntryStatus.wishlist);
      });
    });

    group('roundtrip', () {
      test('toFirestore -> fromFirestore preserves data', () {
        final original = createEntry(
          rating: 7.5,
          review: 'Nice',
          tags: ['t1'],
          startDate: now,
          endDate: later,
          metadata: {'key': 'value'},
          coverUrl: 'https://example.com/img.jpg',
          externalId: 'ext-42',
        );

        final json = original.toFirestore();
        final restored = Entry.fromFirestore(original.id, json);

        expect(restored, equals(original));
      });
    });

    group('equality', () {
      test('two entries with same values are equal', () {
        final a = createEntry();
        final b = createEntry();

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('entries with different values are not equal', () {
        final a = createEntry(title: 'A');
        final b = createEntry(title: 'B');

        expect(a, isNot(equals(b)));
      });
    });
  });

  group('MediaType', () {
    test('label returns human-readable name', () {
      expect(MediaType.book.label, 'Book');
      expect(MediaType.movie.label, 'Movie');
      expect(MediaType.tv.label, 'TV Show');
      expect(MediaType.music.label, 'Music');
      expect(MediaType.other.label, 'Other');
    });

    test('value returns serializable string', () {
      expect(MediaType.book.value, 'book');
      expect(MediaType.movie.value, 'movie');
      expect(MediaType.tv.value, 'tv');
      expect(MediaType.music.value, 'music');
      expect(MediaType.other.value, 'other');
    });

    test('fromValue returns correct enum', () {
      expect(MediaType.fromValue('book'), MediaType.book);
      expect(MediaType.fromValue('movie'), MediaType.movie);
      expect(MediaType.fromValue('tv'), MediaType.tv);
      expect(MediaType.fromValue('music'), MediaType.music);
      expect(MediaType.fromValue('other'), MediaType.other);
    });

    test('fromValue falls back to other for unknown value', () {
      expect(MediaType.fromValue('podcast'), MediaType.other);
      expect(MediaType.fromValue(''), MediaType.other);
    });
  });

  group('EntryStatus', () {
    test('label returns human-readable name', () {
      expect(EntryStatus.wishlist.label, 'Wishlist');
      expect(EntryStatus.inProgress.label, 'In Progress');
      expect(EntryStatus.completed.label, 'Completed');
      expect(EntryStatus.dropped.label, 'Dropped');
      expect(EntryStatus.recall.label, 'Recall');
    });

    test('value returns serializable string', () {
      expect(EntryStatus.wishlist.value, 'wishlist');
      expect(EntryStatus.inProgress.value, 'in-progress');
      expect(EntryStatus.completed.value, 'completed');
      expect(EntryStatus.dropped.value, 'dropped');
      expect(EntryStatus.recall.value, 'recall');
    });

    test('fromValue returns correct enum', () {
      expect(EntryStatus.fromValue('wishlist'), EntryStatus.wishlist);
      expect(EntryStatus.fromValue('in-progress'), EntryStatus.inProgress);
      expect(EntryStatus.fromValue('completed'), EntryStatus.completed);
      expect(EntryStatus.fromValue('dropped'), EntryStatus.dropped);
      expect(EntryStatus.fromValue('recall'), EntryStatus.recall);
    });

    test('fromValue falls back to wishlist for unknown value', () {
      expect(EntryStatus.fromValue('archived'), EntryStatus.wishlist);
      expect(EntryStatus.fromValue(''), EntryStatus.wishlist);
    });
  });
}
