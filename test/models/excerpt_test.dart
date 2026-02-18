import 'package:cultainer/models/excerpt.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Excerpt', () {
    final now = DateTime(2024, 1, 15, 10);

    final excerpt = Excerpt(
      id: 'exc-1',
      entryId: 'entry-1',
      text: 'So we beat on, boats against the current.',
      createdAt: now,
      updatedAt: now,
      pageNumber: 180,
      imageUrl: 'https://example.com/scan.jpg',
      aiAnalysis: 'Symbolism of perseverance.',
    );

    test('creates with required fields', () {
      expect(excerpt.id, 'exc-1');
      expect(excerpt.entryId, 'entry-1');
      expect(excerpt.text, 'So we beat on, boats against the current.');
      expect(excerpt.createdAt, now);
      expect(excerpt.updatedAt, now);
    });

    test('optional fields set correctly', () {
      expect(excerpt.pageNumber, 180);
      expect(excerpt.imageUrl, 'https://example.com/scan.jpg');
      expect(excerpt.aiAnalysis, 'Symbolism of perseverance.');
    });

    test('optional fields default to null', () {
      final minimal = Excerpt(
        id: 'e-2',
        entryId: 'entry-1',
        text: 'quote',
        createdAt: now,
        updatedAt: now,
      );
      expect(minimal.pageNumber, isNull);
      expect(minimal.imageUrl, isNull);
      expect(minimal.aiAnalysis, isNull);
    });

    group('copyWith', () {
      test('updates specified fields', () {
        final updated = excerpt.copyWith(
          text: 'New quote',
          pageNumber: 200,
        );
        expect(updated.text, 'New quote');
        expect(updated.pageNumber, 200);
        expect(updated.id, excerpt.id);
        expect(updated.entryId, excerpt.entryId);
        expect(updated.aiAnalysis, excerpt.aiAnalysis);
      });

      test('preserves all fields when no changes', () {
        expect(excerpt.copyWith(), equals(excerpt));
      });
    });

    group('toFirestore', () {
      test('serializes correctly', () {
        final data = excerpt.toFirestore();
        expect(data['text'], 'So we beat on, boats against the current.');
        expect(data['pageNumber'], 180);
        expect(data['imageUrl'], 'https://example.com/scan.jpg');
        expect(data['aiAnalysis'], 'Symbolism of perseverance.');
        expect(data['createdAt'], now.millisecondsSinceEpoch);
        expect(data['updatedAt'], now.millisecondsSinceEpoch);
      });

      test('does not include id or entryId (stored externally)', () {
        final data = excerpt.toFirestore();
        expect(data.containsKey('id'), isFalse);
        expect(data.containsKey('entryId'), isFalse);
      });
    });

    group('fromFirestore', () {
      test('deserializes full document', () {
        final data = {
          'text': 'So we beat on, boats against the current.',
          'pageNumber': 180,
          'imageUrl': 'https://example.com/scan.jpg',
          'aiAnalysis': 'Symbolism of perseverance.',
          'createdAt': now.millisecondsSinceEpoch,
          'updatedAt': now.millisecondsSinceEpoch,
        };

        final result = Excerpt.fromFirestore('exc-1', 'entry-1', data);

        expect(result.id, 'exc-1');
        expect(result.entryId, 'entry-1');
        expect(result.text, 'So we beat on, boats against the current.');
        expect(result.pageNumber, 180);
        expect(result.imageUrl, 'https://example.com/scan.jpg');
        expect(result.aiAnalysis, 'Symbolism of perseverance.');
      });

      test('handles missing optional fields', () {
        final data = {
          'text': 'quote',
          'createdAt': now.millisecondsSinceEpoch,
          'updatedAt': now.millisecondsSinceEpoch,
        };

        final result = Excerpt.fromFirestore('exc-2', 'entry-1', data);
        expect(result.pageNumber, isNull);
        expect(result.imageUrl, isNull);
        expect(result.aiAnalysis, isNull);
      });

      test('defaults missing text to empty string', () {
        final data = {
          'createdAt': now.millisecondsSinceEpoch,
          'updatedAt': now.millisecondsSinceEpoch,
        };
        final result = Excerpt.fromFirestore('exc-3', 'entry-1', data);
        expect(result.text, '');
      });
    });

    group('roundtrip', () {
      test('toFirestore → fromFirestore preserves all fields', () {
        final data = excerpt.toFirestore();
        final restored = Excerpt.fromFirestore(
          excerpt.id,
          excerpt.entryId,
          data,
        );
        expect(restored, equals(excerpt));
      });
    });

    group('Equatable', () {
      test('same content equals', () {
        final a = Excerpt(
          id: 'x',
          entryId: 'e',
          text: 'q',
          createdAt: now,
          updatedAt: now,
        );
        final b = Excerpt(
          id: 'x',
          entryId: 'e',
          text: 'q',
          createdAt: now,
          updatedAt: now,
        );
        expect(a, equals(b));
      });

      test('different text not equal', () {
        final a = Excerpt(
          id: 'x',
          entryId: 'e',
          text: 'q1',
          createdAt: now,
          updatedAt: now,
        );
        final b = a.copyWith(text: 'q2');
        expect(a, isNot(equals(b)));
      });
    });
  });
}
