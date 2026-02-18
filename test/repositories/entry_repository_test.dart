import 'package:cultainer/core/constants/enums.dart';
import 'package:cultainer/models/entry.dart';
import 'package:cultainer/repositories/entry_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

Entry _makeEntry({
  String id = 'entry-1',
  String title = 'Test Book',
  String creator = 'Test Author',
  MediaType type = MediaType.book,
  EntryStatus status = EntryStatus.wishlist,
  double? rating,
  List<String> tags = const [],
}) {
  final now = DateTime(2024, 1, 15);
  return Entry(
    id: id,
    type: type,
    title: title,
    creator: creator,
    status: status,
    createdAt: now,
    updatedAt: now,
    rating: rating,
    tags: tags,
  );
}

void main() {
  group('EntryRepository', () {
    late FakeFirebaseFirestore fakeFirestore;
    late EntryRepository repo;
    const userId = 'user-123';

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repo = EntryRepository(firestore: fakeFirestore);
    });

    // --------------- createEntry ---------------

    group('createEntry', () {
      test('adds document and returns ID', () async {
        final entry = _makeEntry();
        final id = await repo.createEntry(userId, entry);

        expect(id, isNotEmpty);

        final doc = await fakeFirestore
            .collection('users')
            .doc(userId)
            .collection('entries')
            .doc(id)
            .get();
        expect(doc.exists, isTrue);
        expect(doc.data()!['title'], 'Test Book');
      });
    });

    // --------------- getEntry ---------------

    group('getEntry', () {
      test('returns null for non-existent entry', () async {
        final result = await repo.getEntry(userId, 'nonexistent');
        expect(result, isNull);
      });

      test('returns entry by ID', () async {
        final entry = _makeEntry();
        final id = await repo.createEntry(userId, entry);

        final result = await repo.getEntry(userId, id);
        expect(result, isNotNull);
        expect(result!.title, 'Test Book');
      });
    });

    // --------------- getEntries ---------------

    group('getEntries', () {
      test('returns empty list when no entries', () async {
        final entries = await repo.getEntries(userId);
        expect(entries, isEmpty);
      });

      test('returns all entries sorted by updatedAt desc', () async {
        final older = _makeEntry(id: 'e1', title: 'Older').copyWith(
          updatedAt: DateTime(2024, 1, 1),
        );
        final newer = _makeEntry(id: 'e2', title: 'Newer').copyWith(
          updatedAt: DateTime(2024, 1, 15),
        );
        await repo.createEntry(userId, older);
        await repo.createEntry(userId, newer);

        final entries = await repo.getEntries(userId);
        expect(entries.length, 2);
        expect(entries[0].title, 'Newer');
        expect(entries[1].title, 'Older');
      });
    });

    // --------------- updateEntry ---------------

    group('updateEntry', () {
      test('updates existing entry fields', () async {
        final entry = _makeEntry();
        final id = await repo.createEntry(userId, entry);

        final updated = entry.copyWith(id: id, title: 'Updated Title', rating: 9.0);
        await repo.updateEntry(userId, updated);

        final fetched = await repo.getEntry(userId, id);
        expect(fetched!.title, 'Updated Title');
        expect(fetched.rating, 9.0);
      });
    });

    // --------------- deleteEntry ---------------

    group('deleteEntry', () {
      test('removes document from Firestore', () async {
        final entry = _makeEntry();
        final id = await repo.createEntry(userId, entry);

        await repo.deleteEntry(userId, id);

        final result = await repo.getEntry(userId, id);
        expect(result, isNull);
      });
    });

    // --------------- searchEntries ---------------

    group('searchEntries', () {
      setUp(() async {
        await repo.createEntry(userId, _makeEntry(title: 'The Great Gatsby', creator: 'Fitzgerald'));
        await repo.createEntry(userId, _makeEntry(id: 'e2', title: 'Dune', creator: 'Frank Herbert'));
        await repo.createEntry(userId, _makeEntry(id: 'e3', title: 'Inception', creator: 'Christopher Nolan'));
      });

      test('finds by title (case-insensitive)', () async {
        final results = await repo.searchEntries(userId, 'gatsby');
        expect(results.length, 1);
        expect(results[0].title, 'The Great Gatsby');
      });

      test('finds by creator (case-insensitive)', () async {
        final results = await repo.searchEntries(userId, 'nolan');
        expect(results.length, 1);
        expect(results[0].creator, 'Christopher Nolan');
      });

      test('returns all matching entries', () async {
        final results = await repo.searchEntries(userId, 'the');
        expect(results.length, greaterThanOrEqualTo(1));
      });

      test('returns empty for no matches', () async {
        final results = await repo.searchEntries(userId, 'zxqwerty999');
        expect(results, isEmpty);
      });
    });

    // --------------- getEntriesByStatus ---------------

    group('getEntriesByStatus', () {
      setUp(() async {
        await repo.createEntry(userId, _makeEntry(title: 'A', status: EntryStatus.completed));
        await repo.createEntry(userId, _makeEntry(id: 'e2', title: 'B', status: EntryStatus.completed));
        await repo.createEntry(userId, _makeEntry(id: 'e3', title: 'C', status: EntryStatus.wishlist));
      });

      test('filters by status', () async {
        final completed = await repo.getEntriesByStatus(userId, 'completed');
        expect(completed.length, 2);
        expect(completed.every((e) => e.status == EntryStatus.completed), isTrue);
      });

      test('returns empty for status with no entries', () async {
        final dropped = await repo.getEntriesByStatus(userId, 'dropped');
        expect(dropped, isEmpty);
      });
    });

    // --------------- getEntryCounts ---------------

    group('getEntryCounts', () {
      test('returns zeroed counts with empty collection', () async {
        final counts = await repo.getEntryCounts(userId);
        expect(counts['total'], 0);
        expect(counts['completed'], 0);
        expect(counts['wishlist'], 0);
        expect(counts['in-progress'], 0);
      });

      test('counts entries by status', () async {
        await repo.createEntry(userId, _makeEntry(title: 'A', status: EntryStatus.completed));
        await repo.createEntry(userId, _makeEntry(id: 'e2', title: 'B', status: EntryStatus.completed));
        await repo.createEntry(userId, _makeEntry(id: 'e3', title: 'C', status: EntryStatus.inProgress));

        final counts = await repo.getEntryCounts(userId);
        expect(counts['total'], 3);
        expect(counts['completed'], 2);
        expect(counts['in-progress'], 1);
        expect(counts['wishlist'], 0);
      });
    });

    // --------------- watchEntries ---------------

    group('watchEntries', () {
      test('emits empty list initially', () async {
        final stream = repo.watchEntries(userId);
        expect(await stream.first, isEmpty);
      });

      test('emits updated list after create', () async {
        final stream = repo.watchEntries(userId);

        await repo.createEntry(userId, _makeEntry());

        final entries = await stream.first;
        expect(entries.length, 1);
        expect(entries[0].title, 'Test Book');
      });
    });
  });
}
