import 'package:cultainer/models/tag.dart';
import 'package:cultainer/repositories/tag_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

Tag _makeTag({
  String id = 'tag-1',
  String name = 'Sci-Fi',
  String? color = 'FF5733',
}) {
  return Tag(
    id: id,
    name: name,
    color: color,
    createdAt: DateTime(2024, 1, 15),
  );
}

void main() {
  group('TagRepository', () {
    late FakeFirebaseFirestore fakeFirestore;
    late TagRepository repo;
    const userId = 'user-123';

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repo = TagRepository(firestore: fakeFirestore);
    });

    // --------------- createTag ---------------

    group('createTag', () {
      test('adds document and returns ID', () async {
        final tag = _makeTag();
        final id = await repo.createTag(userId, tag);

        expect(id, isNotEmpty);

        final doc = await fakeFirestore
            .collection('users')
            .doc(userId)
            .collection('tags')
            .doc(id)
            .get();
        expect(doc.exists, isTrue);
        expect(doc.data()!['name'], 'Sci-Fi');
      });
    });

    // --------------- getTag ---------------

    group('getTag', () {
      test('returns null for non-existent tag', () async {
        final result = await repo.getTag(userId, 'nonexistent');
        expect(result, isNull);
      });

      test('returns tag by ID', () async {
        final tag = _makeTag();
        final id = await repo.createTag(userId, tag);

        final result = await repo.getTag(userId, id);
        expect(result, isNotNull);
        expect(result!.name, 'Sci-Fi');
      });
    });

    // --------------- getTags ---------------

    group('getTags', () {
      test('returns empty list with no tags', () async {
        final tags = await repo.getTags(userId);
        expect(tags, isEmpty);
      });

      test('returns all tags sorted by name', () async {
        await repo.createTag(userId, _makeTag(name: 'Thriller'));
        await repo.createTag(userId, _makeTag(id: 't2', name: 'Comedy'));
        await repo.createTag(userId, _makeTag(id: 't3', name: 'Action'));

        final tags = await repo.getTags(userId);
        expect(tags.length, 3);
        expect(tags[0].name, 'Action');
        expect(tags[1].name, 'Comedy');
        expect(tags[2].name, 'Thriller');
      });
    });

    // --------------- updateTag ---------------

    group('updateTag', () {
      test('updates tag name and color', () async {
        final tag = _makeTag();
        final id = await repo.createTag(userId, tag);

        final updated = tag.copyWith(id: id, name: 'Fantasy', color: '00FF00');
        await repo.updateTag(userId, updated);

        final fetched = await repo.getTag(userId, id);
        expect(fetched!.name, 'Fantasy');
        expect(fetched.color, '00FF00');
      });
    });

    // --------------- deleteTag ---------------

    group('deleteTag', () {
      test('removes tag from Firestore', () async {
        final tag = _makeTag();
        final id = await repo.createTag(userId, tag);

        await repo.deleteTag(userId, id);

        final result = await repo.getTag(userId, id);
        expect(result, isNull);
      });
    });

    // --------------- getTagsByIds ---------------

    group('getTagsByIds', () {
      test('returns empty list for empty ids', () async {
        final result = await repo.getTagsByIds(userId, []);
        expect(result, isEmpty);
      });

      test('returns matching tags', () async {
        final id1 = await repo.createTag(userId, _makeTag(name: 'Tag A'));
        final id2 = await repo.createTag(userId, _makeTag(id: 't2', name: 'Tag B'));
        await repo.createTag(userId, _makeTag(id: 't3', name: 'Tag C'));

        final result = await repo.getTagsByIds(userId, [id1, id2]);
        expect(result.length, 2);
        final names = result.map((t) => t.name).toSet();
        expect(names.contains('Tag A'), isTrue);
        expect(names.contains('Tag B'), isTrue);
      });
    });

    // --------------- watchTags ---------------

    group('watchTags', () {
      test('emits empty list initially', () async {
        final stream = repo.watchTags(userId);
        expect(await stream.first, isEmpty);
      });

      test('emits updated list after create', () async {
        final stream = repo.watchTags(userId);

        await repo.createTag(userId, _makeTag());

        final tags = await stream.first;
        expect(tags.length, 1);
        expect(tags[0].name, 'Sci-Fi');
      });
    });
  });
}
