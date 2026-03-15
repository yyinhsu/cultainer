import 'package:cultainer/models/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 3, 15);

  Tag createTag({
    String id = 'tag-1',
    String name = 'Fiction',
    String? color,
    DateTime? createdAt,
  }) {
    return Tag(
      id: id,
      name: name,
      color: color,
      createdAt: createdAt ?? now,
    );
  }

  group('Tag', () {
    group('constructor', () {
      test('creates instance with required fields', () {
        final tag = createTag();

        expect(tag.id, 'tag-1');
        expect(tag.name, 'Fiction');
        expect(tag.createdAt, now);
      });

      test('color defaults to null', () {
        final tag = createTag();

        expect(tag.color, isNull);
      });

      test('creates instance with color', () {
        final tag = createTag(color: '#FF5733');

        expect(tag.color, '#FF5733');
      });
    });

    group('colorValue', () {
      test('returns null when color is null', () {
        final tag = createTag();

        expect(tag.colorValue, isNull);
      });

      test('parses hex color with hash prefix', () {
        final tag = createTag(color: '#FF5733');

        expect(tag.colorValue, const Color(0xFFFF5733));
      });

      test('parses hex color without hash prefix', () {
        final tag = createTag(color: 'FF5733');

        expect(tag.colorValue, const Color(0xFFFF5733));
      });
    });

    group('copyWith', () {
      test('returns identical copy when no arguments provided', () {
        final tag = createTag(color: '#000000');
        final copy = tag.copyWith();

        expect(copy, equals(tag));
      });

      test('updates only specified fields', () {
        final tag = createTag();
        final copy = tag.copyWith(name: 'Sci-Fi', color: '#00FF00');

        expect(copy.name, 'Sci-Fi');
        expect(copy.color, '#00FF00');
        // Unchanged fields
        expect(copy.id, tag.id);
        expect(copy.createdAt, tag.createdAt);
      });
    });

    group('toFirestore', () {
      test('produces correct map', () {
        final tag = createTag(color: '#AABBCC');
        final json = tag.toFirestore();

        expect(json['name'], 'Fiction');
        expect(json['color'], '#AABBCC');
        expect(json['createdAt'], now.millisecondsSinceEpoch);
      });

      test('includes null for color when not set', () {
        final tag = createTag();
        final json = tag.toFirestore();

        expect(json['color'], isNull);
      });

      test('does not include id', () {
        final tag = createTag();
        final json = tag.toFirestore();

        expect(json.containsKey('id'), isFalse);
      });
    });

    group('fromFirestore', () {
      test('reconstructs tag from complete data', () {
        final data = {
          'name': 'Mystery',
          'color': '#112233',
          'createdAt': now.millisecondsSinceEpoch,
        };

        final tag = Tag.fromFirestore('tag-2', data);

        expect(tag.id, 'tag-2');
        expect(tag.name, 'Mystery');
        expect(tag.color, '#112233');
        expect(tag.createdAt, now);
      });

      test('handles missing optional fields with defaults', () {
        final data = <String, dynamic>{
          'createdAt': now.millisecondsSinceEpoch,
        };

        final tag = Tag.fromFirestore('tag-3', data);

        expect(tag.name, '');
        expect(tag.color, isNull);
      });
    });

    group('roundtrip', () {
      test('toFirestore -> fromFirestore preserves data', () {
        final original = createTag(color: '#ABCDEF');

        final json = original.toFirestore();
        final restored = Tag.fromFirestore(original.id, json);

        expect(restored, equals(original));
      });
    });

    group('equality', () {
      test('two tags with same values are equal', () {
        final a = createTag();
        final b = createTag();

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('tags with different values are not equal', () {
        final a = createTag(name: 'A');
        final b = createTag(name: 'B');

        expect(a, isNot(equals(b)));
      });
    });
  });
}
