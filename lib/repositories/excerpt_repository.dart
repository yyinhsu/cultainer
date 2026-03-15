import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cultainer/models/excerpt.dart';

/// Provider for the [ExcerptRepository].
final excerptRepositoryProvider = Provider<ExcerptRepository>((ref) {
  return ExcerptRepository(firestore: FirebaseFirestore.instance);
});

/// Repository handling Excerpt CRUD operations with Firestore.
///
/// Excerpts are stored as a subcollection under each entry:
/// `users/{userId}/entries/{entryId}/excerpts/{excerptId}`
class ExcerptRepository {
  ExcerptRepository({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  /// Gets the excerpts collection reference.
  CollectionReference<Map<String, dynamic>> _excerptsRef(
    String userId,
    String entryId,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('entries')
        .doc(entryId)
        .collection('excerpts');
  }

  /// Stream of all excerpts for an entry, ordered by creation date.
  Stream<List<Excerpt>> watchExcerpts(String userId, String entryId) {
    return _excerptsRef(userId, entryId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Excerpt.fromFirestore(doc.id, entryId, doc.data());
      }).toList();
    });
  }

  /// Gets all excerpts for an entry.
  Future<List<Excerpt>> getExcerpts(String userId, String entryId) async {
    final snapshot = await _excerptsRef(userId, entryId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      return Excerpt.fromFirestore(doc.id, entryId, doc.data());
    }).toList();
  }

  /// Gets a single excerpt.
  Future<Excerpt?> getExcerpt(
    String userId,
    String entryId,
    String excerptId,
  ) async {
    final doc = await _excerptsRef(userId, entryId).doc(excerptId).get();
    if (!doc.exists || doc.data() == null) return null;
    return Excerpt.fromFirestore(doc.id, entryId, doc.data()!);
  }

  /// Creates a new excerpt and returns its ID.
  Future<String> createExcerpt(
    String userId,
    String entryId,
    Excerpt excerpt,
  ) async {
    final docRef =
        await _excerptsRef(userId, entryId).add(excerpt.toFirestore());
    return docRef.id;
  }

  /// Updates an existing excerpt.
  Future<void> updateExcerpt(
    String userId,
    String entryId,
    Excerpt excerpt,
  ) async {
    await _excerptsRef(userId, entryId)
        .doc(excerpt.id)
        .update(excerpt.toFirestore());
  }

  /// Deletes an excerpt.
  Future<void> deleteExcerpt(
    String userId,
    String entryId,
    String excerptId,
  ) async {
    await _excerptsRef(userId, entryId).doc(excerptId).delete();
  }

  /// Gets the count of excerpts for an entry.
  Future<int> getExcerptCount(String userId, String entryId) async {
    final snapshot = await _excerptsRef(userId, entryId).count().get();
    return snapshot.count ?? 0;
  }
}
