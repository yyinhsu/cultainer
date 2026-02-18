import 'package:cultainer/models/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserProfile', () {
    final now = DateTime(2024, 1, 15, 10);

    final profile = UserProfile(
      id: 'uid-123',
      email: 'user@example.com',
      displayName: 'Test User',
      avatarUrl: 'https://example.com/avatar.jpg',
      geminiApiKey: 'secret-key',
      createdAt: now,
      updatedAt: now,
    );

    test('creates with all fields', () {
      expect(profile.id, 'uid-123');
      expect(profile.email, 'user@example.com');
      expect(profile.displayName, 'Test User');
      expect(profile.avatarUrl, 'https://example.com/avatar.jpg');
      expect(profile.geminiApiKey, 'secret-key');
      expect(profile.createdAt, now);
      expect(profile.updatedAt, now);
    });

    test('optional fields default to null', () {
      final minimal = UserProfile(
        id: 'uid-1',
        email: 'a@b.com',
        createdAt: now,
        updatedAt: now,
      );
      expect(minimal.displayName, isNull);
      expect(minimal.avatarUrl, isNull);
      expect(minimal.geminiApiKey, isNull);
    });

    group('copyWith', () {
      test('updates specified fields', () {
        final updated = profile.copyWith(
          displayName: 'New Name',
          geminiApiKey: 'new-key',
        );
        expect(updated.displayName, 'New Name');
        expect(updated.geminiApiKey, 'new-key');
        expect(updated.id, profile.id);
        expect(updated.email, profile.email);
      });

      test('preserves all fields when no changes', () {
        expect(profile.copyWith(), equals(profile));
      });
    });

    group('toFirestore', () {
      test('serializes correctly', () {
        final data = profile.toFirestore();
        expect(data['email'], 'user@example.com');
        expect(data['displayName'], 'Test User');
        expect(data['avatarUrl'], 'https://example.com/avatar.jpg');
        expect(data['geminiApiKey'], 'secret-key');
        expect(data['createdAt'], now.millisecondsSinceEpoch);
        expect(data['updatedAt'], now.millisecondsSinceEpoch);
      });

      test('does not include id (stored as document ID)', () {
        final data = profile.toFirestore();
        expect(data.containsKey('id'), isFalse);
      });
    });

    group('fromFirestore', () {
      test('deserializes full document', () {
        final data = {
          'email': 'user@example.com',
          'displayName': 'Test User',
          'avatarUrl': 'https://example.com/avatar.jpg',
          'geminiApiKey': 'secret-key',
          'createdAt': now.millisecondsSinceEpoch,
          'updatedAt': now.millisecondsSinceEpoch,
        };

        final result = UserProfile.fromFirestore('uid-123', data);

        expect(result.id, 'uid-123');
        expect(result.email, 'user@example.com');
        expect(result.displayName, 'Test User');
        expect(result.geminiApiKey, 'secret-key');
      });

      test('handles missing optional fields', () {
        final data = {
          'email': 'a@b.com',
          'createdAt': now.millisecondsSinceEpoch,
          'updatedAt': now.millisecondsSinceEpoch,
        };

        final result = UserProfile.fromFirestore('uid-1', data);
        expect(result.displayName, isNull);
        expect(result.avatarUrl, isNull);
        expect(result.geminiApiKey, isNull);
      });

      test('defaults missing email to empty string', () {
        final data = {
          'createdAt': now.millisecondsSinceEpoch,
          'updatedAt': now.millisecondsSinceEpoch,
        };
        final result = UserProfile.fromFirestore('uid-2', data);
        expect(result.email, '');
      });
    });

    group('roundtrip', () {
      test('toFirestore → fromFirestore preserves all fields', () {
        final data = profile.toFirestore();
        final restored = UserProfile.fromFirestore(profile.id, data);
        expect(restored, equals(profile));
      });
    });

    group('Equatable', () {
      test('same content equals', () {
        final a = UserProfile(
          id: 'x',
          email: 'a@b.com',
          createdAt: now,
          updatedAt: now,
        );
        final b = UserProfile(
          id: 'x',
          email: 'a@b.com',
          createdAt: now,
          updatedAt: now,
        );
        expect(a, equals(b));
      });

      test('different id not equal', () {
        final a = UserProfile(
          id: 'x',
          email: 'a@b.com',
          createdAt: now,
          updatedAt: now,
        );
        final b = a.copyWith(id: 'y');
        expect(a, isNot(equals(b)));
      });
    });
  });
}
