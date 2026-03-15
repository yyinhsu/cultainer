import 'package:cultainer/models/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 3, 15);
  final later = DateTime(2026, 3, 20);

  UserProfile createProfile({
    String id = 'user-1',
    String email = 'test@example.com',
    String? displayName,
    String? avatarUrl,
    String? geminiApiKey,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id,
      email: email,
      displayName: displayName,
      avatarUrl: avatarUrl,
      geminiApiKey: geminiApiKey,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
    );
  }

  group('UserProfile', () {
    group('constructor', () {
      test('creates instance with required fields', () {
        final profile = createProfile();

        expect(profile.id, 'user-1');
        expect(profile.email, 'test@example.com');
        expect(profile.createdAt, now);
        expect(profile.updatedAt, now);
      });

      test('optional fields default to null', () {
        final profile = createProfile();

        expect(profile.displayName, isNull);
        expect(profile.avatarUrl, isNull);
        expect(profile.geminiApiKey, isNull);
      });

      test('creates instance with all fields', () {
        final profile = createProfile(
          displayName: 'John Doe',
          avatarUrl: 'https://example.com/avatar.jpg',
          geminiApiKey: 'encrypted-key-123',
        );

        expect(profile.displayName, 'John Doe');
        expect(profile.avatarUrl, 'https://example.com/avatar.jpg');
        expect(profile.geminiApiKey, 'encrypted-key-123');
      });
    });

    group('copyWith', () {
      test('returns identical copy when no arguments provided', () {
        final profile = createProfile(displayName: 'Alice');
        final copy = profile.copyWith();

        expect(copy, equals(profile));
      });

      test('updates only specified fields', () {
        final profile = createProfile();
        final copy = profile.copyWith(
          displayName: 'New Name',
          avatarUrl: 'https://example.com/new.jpg',
          updatedAt: later,
        );

        expect(copy.displayName, 'New Name');
        expect(copy.avatarUrl, 'https://example.com/new.jpg');
        expect(copy.updatedAt, later);
        // Unchanged fields
        expect(copy.id, profile.id);
        expect(copy.email, profile.email);
        expect(copy.createdAt, profile.createdAt);
      });
    });

    group('toFirestore', () {
      test('produces correct map', () {
        final profile = createProfile(
          displayName: 'Jane',
          avatarUrl: 'https://example.com/avatar.png',
          geminiApiKey: 'key-abc',
        );
        final json = profile.toFirestore();

        expect(json['displayName'], 'Jane');
        expect(json['email'], 'test@example.com');
        expect(json['avatarUrl'], 'https://example.com/avatar.png');
        expect(json['geminiApiKey'], 'key-abc');
        expect(json['createdAt'], now.millisecondsSinceEpoch);
        expect(json['updatedAt'], now.millisecondsSinceEpoch);
      });

      test('includes null for optional fields when not set', () {
        final profile = createProfile();
        final json = profile.toFirestore();

        expect(json['displayName'], isNull);
        expect(json['avatarUrl'], isNull);
        expect(json['geminiApiKey'], isNull);
      });

      test('does not include id', () {
        final profile = createProfile();
        final json = profile.toFirestore();

        expect(json.containsKey('id'), isFalse);
      });
    });

    group('fromFirestore', () {
      test('reconstructs profile from complete data', () {
        final data = {
          'displayName': 'Bob',
          'email': 'bob@example.com',
          'avatarUrl': 'https://example.com/bob.jpg',
          'geminiApiKey': 'secret-key',
          'createdAt': now.millisecondsSinceEpoch,
          'updatedAt': later.millisecondsSinceEpoch,
        };

        final profile = UserProfile.fromFirestore('user-2', data);

        expect(profile.id, 'user-2');
        expect(profile.displayName, 'Bob');
        expect(profile.email, 'bob@example.com');
        expect(profile.avatarUrl, 'https://example.com/bob.jpg');
        expect(profile.geminiApiKey, 'secret-key');
        expect(profile.createdAt, now);
        expect(profile.updatedAt, later);
      });

      test('handles missing optional fields with defaults', () {
        final data = <String, dynamic>{
          'createdAt': now.millisecondsSinceEpoch,
          'updatedAt': now.millisecondsSinceEpoch,
        };

        final profile = UserProfile.fromFirestore('user-3', data);

        expect(profile.email, '');
        expect(profile.displayName, isNull);
        expect(profile.avatarUrl, isNull);
        expect(profile.geminiApiKey, isNull);
      });
    });

    group('roundtrip', () {
      test('toFirestore -> fromFirestore preserves data', () {
        final original = createProfile(
          displayName: 'Roundtrip User',
          avatarUrl: 'https://example.com/rt.jpg',
          geminiApiKey: 'rt-key',
        );

        final json = original.toFirestore();
        final restored = UserProfile.fromFirestore(original.id, json);

        expect(restored, equals(original));
      });
    });

    group('equality', () {
      test('two profiles with same values are equal', () {
        final a = createProfile();
        final b = createProfile();

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('profiles with different values are not equal', () {
        final a = createProfile(email: 'a@example.com');
        final b = createProfile(email: 'b@example.com');

        expect(a, isNot(equals(b)));
      });
    });
  });
}
