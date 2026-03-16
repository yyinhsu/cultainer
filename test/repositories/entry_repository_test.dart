import 'package:cultainer/core/constants/enums.dart';
import 'package:cultainer/models/entry.dart';
import 'package:cultainer/repositories/entry_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late EntryRepository repository;
  const userId = 'test-user';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = EntryRepository(firestore: fakeFirestore);
  });

  Entry createEntry({
    String id = '',
    String title = 'Test Entry',
    MediaType type = MediaType.book,
    EntryStatus status = EntryStatus.wishlist,
    String creator = 'Test Creator',
    double? rating,
  }) {
    final now = DateTime.now();
    return Entry(
      id: id,
      title: title,
      type: type,
      status: status,
      creator: creator,
      rating: rating,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('EntryRepository', () {
    group('createEntry', () {
      test('creates an entry and returns its ID', () async {
        final entry = createEntry();
        final id = await repository.createEntry(userId, entry);
        expect(id, isNotEmpty);
      });

      test('created entry can be read back', () async {
        final entry = createEntry(title: 'My Book');
        final id = await repository.createEntry(userId, entry);

        final retrieved = await repository.getEntry(userId, id);
        expect(retrieved, isNotNull);
        expect(retrieved!.title, 'My Book');
        expect(retrieved.type, MediaType.book);
        expect(retrieved.creator, 'Test Creator');
      });
    });

    group('getEntry', () {
      test('returns null for non-existent entry', () async {
        final result = await repository.getEntry(userId, 'nonexistent');
        expect(result, isNull);
      });
    });

    group('getEntries', () {
      test('returns empty list when no entries', () async {
        final entries = await repository.getEntries(userId);
        expect(entries, isEmpty);
      });

      test('returns all entries for user', () async {
        await repository.createEntry(userId, createEntry(title: 'Entry 1'));
        await repository.createEntry(userId, createEntry(title: 'Entry 2'));
        await repository.createEntry(userId, createEntry(title: 'Entry 3'));

        final entries = await repository.getEntries(userId);
        expect(entries, hasLength(3));
      });
    });

    group('updateEntry', () {
      test('updates an existing entry', () async {
        final entry = createEntry(title: 'Original');
        final id = await repository.createEntry(userId, entry);

        final updated = createEntry(title: 'Updated').copyWith(id: id);
        await repository.updateEntry(userId, updated);

        final retrieved = await repository.getEntry(userId, id);
        expect(retrieved!.title, 'Updated');
      });
    });

    group('deleteEntry', () {
      test('removes an entry', () async {
        final id = await repository.createEntry(
          userId,
          createEntry(title: 'To Delete'),
        );

        await repository.deleteEntry(userId, id);
        final result = await repository.getEntry(userId, id);
        expect(result, isNull);
      });
    });

    group('searchEntries', () {
      test('finds entries by title', () async {
        await repository.createEntry(
          userId,
          createEntry(title: 'Flutter in Action'),
        );
        await repository.createEntry(
          userId,
          createEntry(title: 'Dart Cookbook'),
        );

        final results = await repository.searchEntries(userId, 'flutter');
        expect(results, hasLength(1));
        expect(results.first.title, 'Flutter in Action');
      });

      test('finds entries by creator', () async {
        await repository.createEntry(
          userId,
          createEntry(title: 'Book A', creator: 'John Doe'),
        );
        await repository.createEntry(
          userId,
          createEntry(title: 'Book B', creator: 'Jane Smith'),
        );

        final results = await repository.searchEntries(userId, 'john');
        expect(results, hasLength(1));
        expect(results.first.creator, 'John Doe');
      });

      test('search is case insensitive', () async {
        await repository.createEntry(
          userId,
          createEntry(title: 'UPPERCASE TITLE'),
        );

        final results = await repository.searchEntries(userId, 'uppercase');
        expect(results, hasLength(1));
      });
    });

    group('getEntriesByStatus', () {
      test('filters entries by status', () async {
        await repository.createEntry(
          userId,
          createEntry(title: 'A', status: EntryStatus.completed),
        );
        await repository.createEntry(
          userId,
          createEntry(title: 'B'),
        );
        await repository.createEntry(
          userId,
          createEntry(title: 'C', status: EntryStatus.completed),
        );

        final results = await repository.getEntriesByStatus(
          userId,
          EntryStatus.completed.value,
        );
        expect(results, hasLength(2));
      });
    });

    group('getEntriesByType', () {
      test('filters entries by type', () async {
        await repository.createEntry(
          userId,
          createEntry(title: 'Book'),
        );
        await repository.createEntry(
          userId,
          createEntry(title: 'Movie', type: MediaType.movie),
        );

        final results = await repository.getEntriesByType(
          userId,
          MediaType.book.value,
        );
        expect(results, hasLength(1));
        expect(results.first.title, 'Book');
      });
    });

    group('getEntryCounts', () {
      test('returns correct counts', () async {
        await repository.createEntry(
          userId,
          createEntry(status: EntryStatus.completed),
        );
        await repository.createEntry(
          userId,
          createEntry(status: EntryStatus.completed),
        );
        await repository.createEntry(
          userId,
          createEntry(),
        );
        await repository.createEntry(
          userId,
          createEntry(status: EntryStatus.inProgress),
        );

        final counts = await repository.getEntryCounts(userId);
        expect(counts['total'], 4);
        expect(counts['completed'], 2);
        expect(counts['wishlist'], 1);
        expect(counts['in-progress'], 1);
      });

      test('returns zeros when no entries', () async {
        final counts = await repository.getEntryCounts(userId);
        expect(counts['total'], 0);
        expect(counts['completed'], 0);
      });
    });

    group('watchEntries', () {
      test('emits entries on changes', () async {
        final stream = repository.watchEntries(userId);

        // First emission is empty
        final first = await stream.first;
        expect(first, isEmpty);
      });
    });

    group('watchEntry', () {
      test('emits null for non-existent entry', () async {
        final stream = repository.watchEntry(userId, 'nonexistent');
        final result = await stream.first;
        expect(result, isNull);
      });
    });
  });
}
