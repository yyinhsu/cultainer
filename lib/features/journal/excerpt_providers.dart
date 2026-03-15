import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:cultainer/features/auth/auth_providers.dart';
import 'package:cultainer/models/excerpt.dart';
import 'package:cultainer/repositories/excerpt_repository.dart';

/// Provider for excerpt list stream, keyed by entry ID.
final excerptsProvider =
    StreamProvider.family<List<Excerpt>, String>((ref, entryId) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();

  final repository = ref.watch(excerptRepositoryProvider);
  return repository.watchExcerpts(user.uid, entryId);
});

/// Notifier for excerpt CRUD actions.
final excerptActionProvider =
    AutoDisposeAsyncNotifierProvider<ExcerptActionNotifier, void>(
  ExcerptActionNotifier.new,
);

/// Handles excerpt actions (create, update, delete).
class ExcerptActionNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // No-op: initial state is idle.
  }

  /// Creates a new excerpt.
  Future<String?> createExcerpt({
    required String entryId,
    required String text,
    int? pageNumber,
    String? imageUrl,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      state = AsyncError('Not authenticated', StackTrace.current);
      return null;
    }

    state = const AsyncLoading();

    String? excerptId;
    state = await AsyncValue.guard(() async {
      final repository = ref.read(excerptRepositoryProvider);
      final now = DateTime.now();
      final excerpt = Excerpt(
        id: const Uuid().v4(),
        entryId: entryId,
        text: text,
        pageNumber: pageNumber,
        imageUrl: imageUrl,
        createdAt: now,
        updatedAt: now,
      );
      excerptId = await repository.createExcerpt(user.uid, entryId, excerpt);
    });

    return excerptId;
  }

  /// Updates an existing excerpt.
  Future<void> updateExcerpt(Excerpt excerpt) async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      state = AsyncError('Not authenticated', StackTrace.current);
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(excerptRepositoryProvider);
      final updated = excerpt.copyWith(updatedAt: DateTime.now());
      await repository.updateExcerpt(user.uid, excerpt.entryId, updated);
    });
  }

  /// Deletes an excerpt.
  Future<void> deleteExcerpt({
    required String entryId,
    required String excerptId,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      state = AsyncError('Not authenticated', StackTrace.current);
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(excerptRepositoryProvider);
      await repository.deleteExcerpt(user.uid, entryId, excerptId);
    });
  }
}
