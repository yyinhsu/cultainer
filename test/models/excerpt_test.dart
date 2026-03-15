import 'package:cultainer/models/excerpt.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 3, 15);
  final later = DateTime(2026, 3, 20);

  Excerpt createExcerpt({
    String id = 'excerpt-1',
    String entryId = 'entry-1',
    String text = 'This is a highlighted quote.',
    int? pageNumber,
    String? imageUrl,
    String? aiAnalysis,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Excerpt(
      id: id,
      entryId: entryId,
      text: text,
      pageNumber: pageNumber,
      imageUrl: imageUrl,
      aiAnalysis: aiAnalysis,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
    );
  }

  group('Excerpt', () {
    group('constructor', () {
      test('creates instance with required fields', () {
        final excerpt = createExcerpt();

        expect(excerpt.id, 'excerpt-1');
        expect(excerpt.entryId, 'entry-1');
        expect(excerpt.text, 'This is a highlighted quote.');
        expect(excerpt.createdAt, now);
        expect(excerpt.updatedAt, now);
      });

      test('optional fields default to null', () {
        final excerpt = createExcerpt();

        expect(excerpt.pageNumber, isNull);
        expect(excerpt.imageUrl, isNull);
        expect(excerpt.aiAnalysis, isNull);
      });

      test('creates instance with all fields', () {
        final excerpt = createExcerpt(
          pageNumber: 42,
          imageUrl: 'https://example.com/img.jpg',
          aiAnalysis: 'This quote discusses...',
        );

        expect(excerpt.pageNumber, 42);
        expect(excerpt.imageUrl, 'https://example.com/img.jpg');
        expect(excerpt.aiAnalysis, 'This quote discusses...');
      });
    });

    group('copyWith', () {
      test('returns identical copy when no arguments provided', () {
        final excerpt = createExcerpt(pageNumber: 10);
        final copy = excerpt.copyWith();

        expect(copy, equals(excerpt));
      });

      test('updates only specified fields', () {
        final excerpt = createExcerpt();
        final copy = excerpt.copyWith(
          text: 'Updated text',
          pageNumber: 99,
          updatedAt: later,
        );

        expect(copy.text, 'Updated text');
        expect(copy.pageNumber, 99);
        expect(copy.updatedAt, later);
        // Unchanged fields
        expect(copy.id, excerpt.id);
        expect(copy.entryId, excerpt.entryId);
        expect(copy.createdAt, excerpt.createdAt);
      });
    });

    group('toFirestore', () {
      test('produces correct map', () {
        final excerpt = createExcerpt(
          pageNumber: 42,
          imageUrl: 'https://example.com/img.jpg',
          aiAnalysis: 'Analysis text',
        );
        final json = excerpt.toFirestore();

        expect(json['text'], 'This is a highlighted quote.');
        expect(json['pageNumber'], 42);
        expect(json['imageUrl'], 'https://example.com/img.jpg');
        expect(json['aiAnalysis'], 'Analysis text');
        expect(json['createdAt'], now.millisecondsSinceEpoch);
        expect(json['updatedAt'], now.millisecondsSinceEpoch);
      });

      test('includes null for optional fields when not set', () {
        final excerpt = createExcerpt();
        final json = excerpt.toFirestore();

        expect(json['pageNumber'], isNull);
        expect(json['imageUrl'], isNull);
        expect(json['aiAnalysis'], isNull);
      });

      test('does not include id or entryId', () {
        final excerpt = createExcerpt();
        final json = excerpt.toFirestore();

        expect(json.containsKey('id'), isFalse);
        expect(json.containsKey('entryId'), isFalse);
      });
    });

    group('fromFirestore', () {
      test('reconstructs excerpt from complete data', () {
        final data = {
          'text': 'A great quote.',
          'pageNumber': 77,
          'imageUrl': 'https://example.com/photo.png',
          'aiAnalysis': 'Deep insight.',
          'createdAt': now.millisecondsSinceEpoch,
          'updatedAt': later.millisecondsSinceEpoch,
        };

        final excerpt = Excerpt.fromFirestore('excerpt-2', 'entry-5', data);

        expect(excerpt.id, 'excerpt-2');
        expect(excerpt.entryId, 'entry-5');
        expect(excerpt.text, 'A great quote.');
        expect(excerpt.pageNumber, 77);
        expect(excerpt.imageUrl, 'https://example.com/photo.png');
        expect(excerpt.aiAnalysis, 'Deep insight.');
        expect(excerpt.createdAt, now);
        expect(excerpt.updatedAt, later);
      });

      test('handles missing optional fields with defaults', () {
        final data = <String, dynamic>{
          'createdAt': now.millisecondsSinceEpoch,
          'updatedAt': now.millisecondsSinceEpoch,
        };

        final excerpt = Excerpt.fromFirestore('excerpt-3', 'entry-1', data);

        expect(excerpt.text, '');
        expect(excerpt.pageNumber, isNull);
        expect(excerpt.imageUrl, isNull);
        expect(excerpt.aiAnalysis, isNull);
      });
    });

    group('roundtrip', () {
      test('toFirestore -> fromFirestore preserves data', () {
        final original = createExcerpt(
          pageNumber: 55,
          imageUrl: 'https://example.com/snap.jpg',
          aiAnalysis: 'Some analysis',
        );

        final json = original.toFirestore();
        final restored = Excerpt.fromFirestore(
          original.id,
          original.entryId,
          json,
        );

        expect(restored, equals(original));
      });
    });

    group('equality', () {
      test('two excerpts with same values are equal', () {
        final a = createExcerpt();
        final b = createExcerpt();

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('excerpts with different values are not equal', () {
        final a = createExcerpt(text: 'A');
        final b = createExcerpt(text: 'B');

        expect(a, isNot(equals(b)));
      });
    });
  });
}
