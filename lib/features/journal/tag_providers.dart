import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:cultainer/models/tag.dart';
import 'package:cultainer/repositories/tag_repository.dart';
import 'package:cultainer/features/auth/auth_providers.dart';

/// Provider for tag list stream.
final tagsProvider = StreamProvider<List<Tag>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();

  final repository = ref.watch(tagRepositoryProvider);
  return repository.watchTags(user.uid);
});

/// Provider for getting tags by IDs.
final tagsByIdsProvider = FutureProvider.family<List<Tag>, List<String>>((
  ref,
  tagIds,
) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final repository = ref.watch(tagRepositoryProvider);
  return repository.getTagsByIds(user.uid, tagIds);
});

/// Notifier for tag CRUD actions.
final tagActionProvider =
    AutoDisposeAsyncNotifierProvider<TagActionNotifier, void>(
  TagActionNotifier.new,
);

/// Handles tag actions (create, update, delete).
class TagActionNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // No-op: initial state is idle.
  }

  /// Creates a new tag.
  Future<String?> createTag({
    required String name,
    String? color,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      state = AsyncError('Not authenticated', StackTrace.current);
      return null;
    }

    state = const AsyncLoading();

    String? tagId;
    state = await AsyncValue.guard(() async {
      final repository = ref.read(tagRepositoryProvider);
      final tag = Tag(
        id: const Uuid().v4(), // Temporary ID
        name: name,
        color: color,
        createdAt: DateTime.now(),
      );
      tagId = await repository.createTag(user.uid, tag);
    });

    return tagId;
  }

  /// Updates an existing tag.
  Future<void> updateTag(Tag tag) async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      state = AsyncError('Not authenticated', StackTrace.current);
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(tagRepositoryProvider);
      await repository.updateTag(user.uid, tag);
    });
  }

  /// Deletes a tag.
  Future<void> deleteTag(String tagId) async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      state = AsyncError('Not authenticated', StackTrace.current);
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(tagRepositoryProvider);
      await repository.deleteTag(user.uid, tagId);
    });
  }
}
