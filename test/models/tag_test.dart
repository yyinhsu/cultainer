import 'package:cultainer/models/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Tag', () {
    final now = DateTime(2024, 1, 15);

    final tag = Tag(
      id: 'tag-1',
      name: 'Sci-Fi',
      color: 'FF5733',
      createdAt: now,
    );

    test('creates with required fields', () {
      expect(tag.id, 'tag-1');
      expect(tag.name, 'Sci-Fi');
      expect(tag.color, 'FF5733');
      expect(tag.createdAt, now);
    });

    test('color is optional', () {
      final tagNoColor = Tag(id: 't-2', name: 'Drama', createdAt: now);
      expect(tagNoColor.color, isNull);
      expect(tagNoColor.colorValue, isNull);
    });

    group('colorValue', () {
      test('parses hex color correctly', () {
        final color = tag.colorValue;
        expect(color, isNotNull);
        expect(color, isA<Color>());
        // FF5733 → R=0xFF, G=0x57, B=0x33
        expect(color!.r, closeTo(1.0, 0.01)); // FF
        expect(color.g, closeTo(0x57 / 255, 0.01));
        expect(color.b, closeTo(0x33 / 255, 0.01));
      });

      test('handles hash-prefixed hex', () {
        final hashTag = Tag(id: 't-3', name: 'X', color: '#3498DB', createdAt: now);
        final color = hashTag.colorValue;
        expect(color, isNotNull);
      });
    });

    group('copyWith', () {
      test('updates specified fields', () {
        final updated = tag.copyWith(name: 'Fantasy', color: '00FF00');
        expect(updated.name, 'Fantasy');
        expect(updated.color, '00FF00');
        expect(updated.id, tag.id);
        expect(updated.createdAt, tag.createdAt);
      });

      test('preserves all fields when no changes', () {
        expect(tag.copyWith(), equals(tag));
      });
    });

    group('toFirestore', () {
      test('serializes correctly', () {
        final data = tag.toFirestore();
        expect(data['name'], 'Sci-Fi');
        expect(data['color'], 'FF5733');
        expect(data['createdAt'], now.millisecondsSinceEpoch);
      });

      test('includes null color', () {
        final tagNoColor = Tag(id: 't-2', name: 'Drama', createdAt: now);
        final data = tagNoColor.toFirestore();
        expect(data.containsKey('color'), isTrue);
        expect(data['color'], isNull);
      });
    });

    group('fromFirestore', () {
      test('deserializes full document', () {
        final data = {
          'name': 'Sci-Fi',
          'color': 'FF5733',
          'createdAt': now.millisecondsSinceEpoch,
        };
        final result = Tag.fromFirestore('tag-1', data);
        expect(result.id, 'tag-1');
        expect(result.name, 'Sci-Fi');
        expect(result.color, 'FF5733');
        expect(result.createdAt, now);
      });

      test('handles missing color gracefully', () {
        final data = {
          'name': 'Drama',
          'createdAt': now.millisecondsSinceEpoch,
        };
        final result = Tag.fromFirestore('t-2', data);
        expect(result.color, isNull);
      });

      test('defaults missing name to empty string', () {
        final data = {'createdAt': now.millisecondsSinceEpoch};
        final result = Tag.fromFirestore('t-3', data);
        expect(result.name, '');
      });
    });

    group('roundtrip', () {
      test('toFirestore → fromFirestore preserves all fields', () {
        final data = tag.toFirestore();
        final restored = Tag.fromFirestore(tag.id, data);
        expect(restored, equals(tag));
      });
    });

    group('Equatable', () {
      test('same content equals', () {
        final a = Tag(id: 'x', name: 'N', createdAt: now);
        final b = Tag(id: 'x', name: 'N', createdAt: now);
        expect(a, equals(b));
      });

      test('different id not equal', () {
        final a = Tag(id: 'x', name: 'N', createdAt: now);
        final b = a.copyWith(id: 'y');
        expect(a, isNot(equals(b)));
      });
    });
  });
}
