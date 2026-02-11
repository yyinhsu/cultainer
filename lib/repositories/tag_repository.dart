import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cultainer/models/tag.dart';

/// Provider for the [TagRepository].
final tagRepositoryProvider = Provider<TagRepository>((ref) {
  return TagRepository(firestore: FirebaseFirestore.instance);
});

/// Repository handling Tag CRUD operations with Firestore.
class TagRepository {
  TagRepository({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  /// Gets the tags collection reference for a user.
  CollectionReference<Map<String, dynamic>> _tagsRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('tags');
  }

  /// Stream of all tags for a user.
  Stream<List<Tag>> watchTags(String userId) {
    return _tagsRef(userId).orderBy('name').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Tag.fromFirestore(doc.id, doc.data());
      }).toList();
    });
  }

  /// Gets all tags for a user.
  Future<List<Tag>> getTags(String userId) async {
    final snapshot = await _tagsRef(userId).orderBy('name').get();
    return snapshot.docs.map((doc) {
      return Tag.fromFirestore(doc.id, doc.data());
    }).toList();
  }

  /// Gets a single tag.
  Future<Tag?> getTag(String userId, String tagId) async {
    final doc = await _tagsRef(userId).doc(tagId).get();
    if (!doc.exists || doc.data() == null) return null;
    return Tag.fromFirestore(doc.id, doc.data()!);
  }

  /// Creates a new tag and returns its ID.
  Future<String> createTag(String userId, Tag tag) async {
    final docRef = await _tagsRef(userId).add(tag.toFirestore());
    return docRef.id;
  }

  /// Updates an existing tag.
  Future<void> updateTag(String userId, Tag tag) async {
    await _tagsRef(userId).doc(tag.id).update(tag.toFirestore());
  }

  /// Deletes a tag.
  Future<void> deleteTag(String userId, String tagId) async {
    await _tagsRef(userId).doc(tagId).delete();
  }

  /// Gets multiple tags by their IDs.
  Future<List<Tag>> getTagsByIds(String userId, List<String> tagIds) async {
    if (tagIds.isEmpty) return [];

    // Firestore's whereIn is limited to 30 items
    final tags = <Tag>[];
    for (var i = 0; i < tagIds.length; i += 30) {
      final batch = tagIds.skip(i).take(30).toList();
      final snapshot = await _tagsRef(userId)
          .where(FieldPath.documentId, whereIn: batch)
          .get();
      tags.addAll(
        snapshot.docs.map((doc) {
          return Tag.fromFirestore(doc.id, doc.data());
        }),
      );
    }
    return tags;
  }
}
