import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cultainer/models/entry.dart';

/// Provider for the [EntryRepository].
final entryRepositoryProvider = Provider<EntryRepository>((ref) {
  return EntryRepository(firestore: FirebaseFirestore.instance);
});

/// Repository handling Entry CRUD operations with Firestore.
class EntryRepository {
  EntryRepository({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  /// Gets the entries collection reference for a user.
  CollectionReference<Map<String, dynamic>> _entriesRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('entries');
  }

  /// Stream of all entries for a user, ordered by updated date.
  Stream<List<Entry>> watchEntries(String userId) {
    return _entriesRef(userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Entry.fromFirestore(doc.id, doc.data());
      }).toList();
    });
  }

  /// Stream of a single entry.
  Stream<Entry?> watchEntry(String userId, String entryId) {
    return _entriesRef(userId).doc(entryId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return Entry.fromFirestore(doc.id, doc.data()!);
    });
  }

  /// Gets a single entry.
  Future<Entry?> getEntry(String userId, String entryId) async {
    final doc = await _entriesRef(userId).doc(entryId).get();
    if (!doc.exists || doc.data() == null) return null;
    return Entry.fromFirestore(doc.id, doc.data()!);
  }

  /// Gets all entries for a user.
  Future<List<Entry>> getEntries(String userId) async {
    final snapshot =
        await _entriesRef(userId).orderBy('updatedAt', descending: true).get();
    return snapshot.docs.map((doc) {
      return Entry.fromFirestore(doc.id, doc.data());
    }).toList();
  }

  /// Creates a new entry and returns its ID.
  Future<String> createEntry(String userId, Entry entry) async {
    final docRef = await _entriesRef(userId).add(entry.toFirestore());
    return docRef.id;
  }

  /// Updates an existing entry.
  Future<void> updateEntry(String userId, Entry entry) async {
    await _entriesRef(userId).doc(entry.id).update(entry.toFirestore());
  }

  /// Deletes an entry.
  Future<void> deleteEntry(String userId, String entryId) async {
    await _entriesRef(userId).doc(entryId).delete();
  }

  /// Searches entries by title or creator.
  Future<List<Entry>> searchEntries(String userId, String query) async {
    // Firestore doesn't support full-text search, so we fetch all and filter
    // For production, consider using Algolia or Typesense
    final entries = await getEntries(userId);
    final lowerQuery = query.toLowerCase();
    return entries.where((entry) {
      return entry.title.toLowerCase().contains(lowerQuery) ||
          entry.creator.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Gets entries by status.
  Future<List<Entry>> getEntriesByStatus(
    String userId,
    String status,
  ) async {
    final snapshot = await _entriesRef(userId)
        .where('status', isEqualTo: status)
        .orderBy('updatedAt', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      return Entry.fromFirestore(doc.id, doc.data());
    }).toList();
  }

  /// Gets entries by type.
  Future<List<Entry>> getEntriesByType(
    String userId,
    String type,
  ) async {
    final snapshot = await _entriesRef(userId)
        .where('type', isEqualTo: type)
        .orderBy('updatedAt', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      return Entry.fromFirestore(doc.id, doc.data());
    }).toList();
  }

  /// Gets entry counts by status.
  Future<Map<String, int>> getEntryCounts(String userId) async {
    final entries = await getEntries(userId);
    final counts = <String, int>{
      'completed': 0,
      'in-progress': 0,
      'wishlist': 0,
      'dropped': 0,
      'recall': 0,
      'total': entries.length,
    };
    for (final entry in entries) {
      counts[entry.status.value] = (counts[entry.status.value] ?? 0) + 1;
    }
    return counts;
  }
}
