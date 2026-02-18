import 'package:cultainer/core/constants/enums.dart';
import 'package:cultainer/models/entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Entry', () {
    final now = DateTime(2024, 1, 15, 10);

    final entry = Entry(
      id: 'entry-1',
      type: MediaType.book,
      title: 'The Great Gatsby',
      creator: 'F. Scott Fitzgerald',
      status: EntryStatus.completed,
      createdAt: now,
      updatedAt: now,
      rating: 8.5,
      tags: ['tag-1', 'tag-2'],
    );

    test('creates with required fields', () {
      expect(entry.id, 'entry-1');
      expect(entry.type, MediaType.book);
      expect(entry.title, 'The Great Gatsby');
      expect(entry.creator, 'F. Scott Fitzgerald');
      expect(entry.status, EntryStatus.completed);
      expect(entry.rating, 8.5);
      expect(entry.tags, ['tag-1', 'tag-2']);
    });

    test('optional fields default to null/empty', () {
      expect(entry.creatorId, isNull);
      expect(entry.coverUrl, isNull);
      expect(entry.coverStoragePath, isNull);
      expect(entry.externalId, isNull);
      expect(entry.review, isNull);
      expect(entry.startDate, isNull);
      expect(entry.endDate, isNull);
      expect(entry.metadata, isEmpty);
    });

    group('copyWith', () {
      test('returns new instance with updated fields', () {
        final updated = entry.copyWith(
          title: 'Gatsby',
          rating: 9.0,
          status: EntryStatus.inProgress,
        );

        expect(updated.title, 'Gatsby');
        expect(updated.rating, 9.0);
        expect(updated.status, EntryStatus.inProgress);
        // Unchanged fields preserved
        expect(updated.id, entry.id);
        expect(updated.creator, entry.creator);
        expect(updated.tags, entry.tags);
      });

      test('preserves original when no changes', () {
        final copy = entry.copyWith();
        expect(copy, equals(entry));
      });
    });

    group('toFirestore', () {
      test('serializes all fields correctly', () {
        final data = entry.toFirestore();

        expect(data['type'], 'book');
        expect(data['title'], 'The Great Gatsby');
        expect(data['creator'], 'F. Scott Fitzgerald');
        expect(data['status'], 'completed');
        expect(data['rating'], 8.5);
        expect(data['tags'], ['tag-1', 'tag-2']);
        expect(data['createdAt'], now.millisecondsSinceEpoch);
        expect(data['updatedAt'], now.millisecondsSinceEpoch);
        expect(data['startDate'], isNull);
        expect(data['endDate'], isNull);
      });

      test('serializes dates as milliseconds', () {
        final start = DateTime(2024, 1, 1);
        final end = DateTime(2024, 1, 15);
        final withDates = entry.copyWith(startDate: start, endDate: end);
        final data = withDates.toFirestore();

        expect(data['startDate'], start.millisecondsSinceEpoch);
        expect(data['endDate'], end.millisecondsSinceEpoch);
      });
    });

    group('fromFirestore', () {
      test('deserializes full document', () {
        final data = {
          'type': 'book',
          'title': 'The Great Gatsby',
          'creator': 'F. Scott Fitzgerald',
          'creatorId': 'author-123',
          'coverUrl': 'https://example.com/cover.jpg',
          'externalId': 'book-abc',
          'status': 'completed',
          'rating': 8.5,
          'review': 'Excellent.',
          'tags': ['tag-1'],
          'startDate': DateTime(2024, 1, 1).millisecondsSinceEpoch,
          'endDate': DateTime(2024, 1, 15).millisecondsSinceEpoch,
          'createdAt': now.millisecondsSinceEpoch,
          'updatedAt': now.millisecondsSinceEpoch,
          'metadata': {'pageCount': 180},
        };

        final result = Entry.fromFirestore('entry-1', data);

        expect(result.id, 'entry-1');
        expect(result.type, MediaType.book);
        expect(result.title, 'The Great Gatsby');
        expect(result.creatorId, 'author-123');
        expect(result.rating, 8.5);
        expect(result.review, 'Excellent.');
        expect(result.tags, ['tag-1']);
        expect(result.startDate, DateTime(2024, 1, 1));
        expect(result.endDate, DateTime(2024, 1, 15));
        expect(result.metadata['pageCount'], 180);
      });

      test('handles missing optional fields with defaults', () {
        final data = {
          'type': 'movie',
          'title': 'Inception',
          'creator': 'Christopher Nolan',
          'status': 'wishlist',
          'createdAt': now.millisecondsSinceEpoch,
          'updatedAt': now.millisecondsSinceEpoch,
        };

        final result = Entry.fromFirestore('e-2', data);

        expect(result.creatorId, isNull);
        expect(result.rating, isNull);
        expect(result.review, isNull);
        expect(result.tags, isEmpty);
        expect(result.metadata, isEmpty);
      });

      test('defaults unknown type to other', () {
        final data = {
          'type': 'unknown_type',
          'title': 'X',
          'creator': 'Y',
          'status': 'wishlist',
          'createdAt': now.millisecondsSinceEpoch,
          'updatedAt': now.millisecondsSinceEpoch,
        };

        final result = Entry.fromFirestore('e-3', data);
        expect(result.type, MediaType.other);
      });

      test('defaults unknown status to wishlist', () {
        final data = {
          'type': 'book',
          'title': 'X',
          'creator': 'Y',
          'status': 'unknown_status',
          'createdAt': now.millisecondsSinceEpoch,
          'updatedAt': now.millisecondsSinceEpoch,
        };

        final result = Entry.fromFirestore('e-4', data);
        expect(result.status, EntryStatus.wishlist);
      });
    });

    group('Equatable', () {
      test('equal entries have same props', () {
        final a = Entry(
          id: 'x',
          type: MediaType.book,
          title: 'T',
          creator: 'C',
          status: EntryStatus.wishlist,
          createdAt: now,
          updatedAt: now,
        );
        final b = Entry(
          id: 'x',
          type: MediaType.book,
          title: 'T',
          creator: 'C',
          status: EntryStatus.wishlist,
          createdAt: now,
          updatedAt: now,
        );
        expect(a, equals(b));
      });

      test('different IDs are not equal', () {
        final a = Entry(
          id: 'x',
          type: MediaType.book,
          title: 'T',
          creator: 'C',
          status: EntryStatus.wishlist,
          createdAt: now,
          updatedAt: now,
        );
        final b = a.copyWith(id: 'y');
        expect(a, isNot(equals(b)));
      });
    });

    group('roundtrip', () {
      test('toFirestore → fromFirestore preserves all fields', () {
        final original = Entry(
          id: 'rt-1',
          type: MediaType.movie,
          title: 'Inception',
          creator: 'Christopher Nolan',
          creatorId: 'nolan-42',
          coverUrl: 'https://example.com/poster.jpg',
          externalId: 'tmdb-27205',
          status: EntryStatus.completed,
          rating: 9.0,
          review: 'Mind-bending.',
          tags: ['sci-fi', 'thriller'],
          startDate: DateTime(2024, 1, 10),
          endDate: DateTime(2024, 1, 11),
          createdAt: now,
          updatedAt: now,
          metadata: {'runtime': 148},
        );

        final data = original.toFirestore();
        final restored = Entry.fromFirestore(original.id, data);

        expect(restored, equals(original));
      });
    });
  });
}
