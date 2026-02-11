import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:cultainer/core/constants/enums.dart';
import 'package:cultainer/models/entry.dart';
import 'package:cultainer/repositories/entry_repository.dart';
import 'package:cultainer/features/auth/auth_providers.dart';

/// Provider for entry list stream.
final entriesProvider = StreamProvider<List<Entry>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();

  final repository = ref.watch(entryRepositoryProvider);
  return repository.watchEntries(user.uid);
});

/// Provider for a single entry stream.
final entryProvider = StreamProvider.family<Entry?, String>((ref, entryId) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();

  final repository = ref.watch(entryRepositoryProvider);
  return repository.watchEntry(user.uid, entryId);
});

/// Provider for entry counts by status.
final entryCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return {};

  final repository = ref.watch(entryRepositoryProvider);
  return repository.getEntryCounts(user.uid);
});

/// Provider for filtered entries.
final filteredEntriesProvider = Provider<List<Entry>>((ref) {
  final entries = ref.watch(entriesProvider).valueOrNull ?? [];
  final typeFilter = ref.watch(entryTypeFilterProvider);
  final statusFilter = ref.watch(entryStatusFilterProvider);
  final searchQuery = ref.watch(entrySearchQueryProvider);

  var filtered = entries;

  // Apply type filter
  if (typeFilter != null) {
    filtered = filtered.where((e) => e.type == typeFilter).toList();
  }

  // Apply status filter
  if (statusFilter != null) {
    filtered = filtered.where((e) => e.status == statusFilter).toList();
  }

  // Apply search filter
  if (searchQuery.isNotEmpty) {
    final query = searchQuery.toLowerCase();
    filtered = filtered.where((e) {
      return e.title.toLowerCase().contains(query) ||
          e.creator.toLowerCase().contains(query);
    }).toList();
  }

  return filtered;
});

/// State provider for media type filter.
final entryTypeFilterProvider = StateProvider<MediaType?>((ref) => null);

/// State provider for status filter.
final entryStatusFilterProvider = StateProvider<EntryStatus?>((ref) => null);

/// State provider for search query.
final entrySearchQueryProvider = StateProvider<String>((ref) => '');

/// Notifier for entry CRUD actions.
final entryActionProvider =
    AutoDisposeAsyncNotifierProvider<EntryActionNotifier, void>(
  EntryActionNotifier.new,
);

/// Handles entry actions (create, update, delete).
class EntryActionNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // No-op: initial state is idle.
  }

  /// Creates a new entry.
  Future<String?> createEntry({
    required MediaType type,
    required String title,
    required String creator,
    required EntryStatus status,
    String? creatorId,
    String? coverUrl,
    String? externalId,
    double? rating,
    String? review,
    List<String>? tags,
    DateTime? startDate,
    DateTime? endDate,
    Map<String, dynamic>? metadata,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      state = AsyncError('Not authenticated', StackTrace.current);
      return null;
    }

    state = const AsyncLoading();

    String? entryId;
    state = await AsyncValue.guard(() async {
      final repository = ref.read(entryRepositoryProvider);
      final now = DateTime.now();
      final entry = Entry(
        id: const Uuid().v4(), // Temporary ID, will be replaced by Firestore
        type: type,
        title: title,
        creator: creator,
        creatorId: creatorId,
        coverUrl: coverUrl,
        externalId: externalId,
        status: status,
        rating: rating,
        review: review,
        tags: tags ?? [],
        startDate: startDate,
        endDate: endDate,
        createdAt: now,
        updatedAt: now,
        metadata: metadata ?? {},
      );
      entryId = await repository.createEntry(user.uid, entry);
    });

    return entryId;
  }

  /// Updates an existing entry.
  Future<void> updateEntry(Entry entry) async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      state = AsyncError('Not authenticated', StackTrace.current);
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(entryRepositoryProvider);
      final updated = entry.copyWith(updatedAt: DateTime.now());
      await repository.updateEntry(user.uid, updated);
    });
  }

  /// Deletes an entry.
  Future<void> deleteEntry(String entryId) async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      state = AsyncError('Not authenticated', StackTrace.current);
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(entryRepositoryProvider);
      await repository.deleteEntry(user.uid, entryId);
    });
  }
}
