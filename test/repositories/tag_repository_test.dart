import 'package:cultainer/models/tag.dart';
import 'package:cultainer/repositories/tag_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late TagRepository repository;
  const userId = 'test-user';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = TagRepository(firestore: fakeFirestore);
  });

  Tag createTag({
    String id = '',
    String name = 'Test Tag',
    String? color,
  }) {
    return Tag(
      id: id,
      name: name,
      color: color,
      createdAt: DateTime.now(),
    );
  }

  group('TagRepository', () {
    group('createTag', () {
      test('creates a tag and returns its ID', () async {
        final id = await repository.createTag(userId, createTag());
        expect(id, isNotEmpty);
      });

      test('created tag can be read back', () async {
        final id = await repository.createTag(
          userId,
          createTag(name: 'Fiction', color: '#FF5733'),
        );

        final tag = await repository.getTag(userId, id);
        expect(tag, isNotNull);
        expect(tag!.name, 'Fiction');
        expect(tag.color, '#FF5733');
      });
    });

    group('getTag', () {
      test('returns null for non-existent tag', () async {
        final result = await repository.getTag(userId, 'nonexistent');
        expect(result, isNull);
      });
    });

    group('getTags', () {
      test('returns empty list when no tags', () async {
        final tags = await repository.getTags(userId);
        expect(tags, isEmpty);
      });

      test('returns all tags for user', () async {
        await repository.createTag(userId, createTag(name: 'A'));
        await repository.createTag(userId, createTag(name: 'B'));

        final tags = await repository.getTags(userId);
        expect(tags, hasLength(2));
      });
    });

    group('updateTag', () {
      test('updates an existing tag', () async {
        final id = await repository.createTag(
          userId,
          createTag(name: 'Old Name'),
        );

        final updated = createTag(name: 'New Name').copyWith(id: id);
        await repository.updateTag(userId, updated);

        final tag = await repository.getTag(userId, id);
        expect(tag!.name, 'New Name');
      });
    });

    group('deleteTag', () {
      test('removes a tag', () async {
        final id = await repository.createTag(
          userId,
          createTag(name: 'To Delete'),
        );

        await repository.deleteTag(userId, id);
        final result = await repository.getTag(userId, id);
        expect(result, isNull);
      });
    });

    group('getTagsByIds', () {
      test('returns matching tags', () async {
        final id1 = await repository.createTag(
          userId,
          createTag(name: 'Tag 1'),
        );
        await repository.createTag(userId, createTag(name: 'Tag 2'));
        final id3 = await repository.createTag(
          userId,
          createTag(name: 'Tag 3'),
        );

        final tags = await repository.getTagsByIds(userId, [id1, id3]);
        expect(tags, hasLength(2));
        final names = tags.map((t) => t.name).toSet();
        expect(names, containsAll(['Tag 1', 'Tag 3']));
      });

      test('returns empty list for empty IDs', () async {
        final tags = await repository.getTagsByIds(userId, []);
        expect(tags, isEmpty);
      });
    });

    group('watchTags', () {
      test('emits tags on changes', () async {
        final stream = repository.watchTags(userId);
        final first = await stream.first;
        expect(first, isEmpty);
      });
    });
  });
}
