import 'package:cultainer/models/excerpt.dart';
import 'package:cultainer/repositories/excerpt_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late ExcerptRepository repository;
  const userId = 'test-user';
  const entryId = 'test-entry';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = ExcerptRepository(firestore: fakeFirestore);
  });

  Excerpt createExcerpt({
    String id = '',
    String text = 'Test excerpt text',
    int? pageNumber,
    String? aiAnalysis,
  }) {
    final now = DateTime.now();
    return Excerpt(
      id: id,
      entryId: entryId,
      text: text,
      pageNumber: pageNumber,
      aiAnalysis: aiAnalysis,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('ExcerptRepository', () {
    group('createExcerpt', () {
      test('creates an excerpt and returns its ID', () async {
        final id = await repository.createExcerpt(
          userId,
          entryId,
          createExcerpt(),
        );
        expect(id, isNotEmpty);
      });

      test('created excerpt can be read back', () async {
        final id = await repository.createExcerpt(
          userId,
          entryId,
          createExcerpt(text: 'Important quote', pageNumber: 42),
        );

        final excerpt = await repository.getExcerpt(userId, entryId, id);
        expect(excerpt, isNotNull);
        expect(excerpt!.text, 'Important quote');
        expect(excerpt.pageNumber, 42);
      });
    });

    group('getExcerpt', () {
      test('returns null for non-existent excerpt', () async {
        final result =
            await repository.getExcerpt(userId, entryId, 'nonexistent');
        expect(result, isNull);
      });
    });

    group('getExcerpts', () {
      test('returns empty list when no excerpts', () async {
        final excerpts = await repository.getExcerpts(userId, entryId);
        expect(excerpts, isEmpty);
      });

      test('returns all excerpts for entry', () async {
        await repository.createExcerpt(
          userId,
          entryId,
          createExcerpt(text: 'One'),
        );
        await repository.createExcerpt(
          userId,
          entryId,
          createExcerpt(text: 'Two'),
        );

        final excerpts = await repository.getExcerpts(userId, entryId);
        expect(excerpts, hasLength(2));
      });
    });

    group('updateExcerpt', () {
      test('updates an existing excerpt', () async {
        final id = await repository.createExcerpt(
          userId,
          entryId,
          createExcerpt(text: 'Original'),
        );

        final updated = createExcerpt(text: 'Updated').copyWith(id: id);
        await repository.updateExcerpt(userId, entryId, updated);

        final excerpt = await repository.getExcerpt(userId, entryId, id);
        expect(excerpt!.text, 'Updated');
      });
    });

    group('deleteExcerpt', () {
      test('removes an excerpt', () async {
        final id = await repository.createExcerpt(
          userId,
          entryId,
          createExcerpt(text: 'To Delete'),
        );

        await repository.deleteExcerpt(userId, entryId, id);
        final result = await repository.getExcerpt(userId, entryId, id);
        expect(result, isNull);
      });
    });

    group('getExcerptCount', () {
      test('returns correct count', () async {
        await repository.createExcerpt(
          userId,
          entryId,
          createExcerpt(text: 'A'),
        );
        await repository.createExcerpt(
          userId,
          entryId,
          createExcerpt(text: 'B'),
        );
        await repository.createExcerpt(
          userId,
          entryId,
          createExcerpt(text: 'C'),
        );

        final count = await repository.getExcerptCount(userId, entryId);
        expect(count, 3);
      });

      test('returns zero when no excerpts', () async {
        final count = await repository.getExcerptCount(userId, entryId);
        expect(count, 0);
      });
    });

    group('watchExcerpts', () {
      test('emits excerpts on changes', () async {
        final stream = repository.watchExcerpts(userId, entryId);
        final first = await stream.first;
        expect(first, isEmpty);
      });
    });
  });
}
