import 'package:cultainer/core/constants/enums.dart';
import 'package:cultainer/core/theme/app_colors.dart';
import 'package:cultainer/core/theme/app_typography.dart';
import 'package:cultainer/core/widgets/app_card.dart';
import 'package:cultainer/core/widgets/app_chip.dart';
import 'package:cultainer/core/widgets/app_text_field.dart';
import 'package:cultainer/features/journal/entry_providers.dart';
import 'package:cultainer/models/entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// The journal page displaying all user entries.
class JournalPage extends ConsumerStatefulWidget {
  const JournalPage({super.key});

  @override
  ConsumerState<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends ConsumerState<JournalPage> {
  final _searchController = TextEditingController();

  static const _filters = ['All', 'Books', 'Movies', 'TV', 'Music', 'Other'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    ref.read(entrySearchQueryProvider.notifier).state = _searchController.text;
  }

  MediaType? _filterToMediaType(String filter) {
    switch (filter) {
      case 'Books':
        return MediaType.book;
      case 'Movies':
        return MediaType.movie;
      case 'TV':
        return MediaType.tv;
      case 'Music':
        return MediaType.music;
      case 'Other':
        return MediaType.other;
      default:
        return null;
    }
  }

  String _mediaTypeToFilter(MediaType? type) {
    if (type == null) return 'All';
    switch (type) {
      case MediaType.book:
        return 'Books';
      case MediaType.movie:
        return 'Movies';
      case MediaType.tv:
        return 'TV';
      case MediaType.music:
        return 'Music';
      case MediaType.other:
        return 'Other';
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeFilter = ref.watch(entryTypeFilterProvider);
    final filteredEntries = ref.watch(filteredEntriesProvider);
    final entriesAsync = ref.watch(entriesProvider);

    final selectedFilter = _mediaTypeToFilter(typeFilter);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Journal',
                      style: AppTypography.displayLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppSearchField(
                      controller: _searchController,
                      hint: 'Search your entries...',
                    ),
                  ],
                ),
              ),
            ),

            // Media type filters
            SliverToBoxAdapter(
              child: AppFilterChipList(
                filters: _filters,
                selectedFilters: {selectedFilter},
                onFilterChanged: (filter, selected) {
                  if (filter == 'All') {
                    ref.read(entryTypeFilterProvider.notifier).state = null;
                  } else if (selected) {
                    ref.read(entryTypeFilterProvider.notifier).state =
                        _filterToMediaType(filter);
                  } else {
                    ref.read(entryTypeFilterProvider.notifier).state = null;
                  }
                },
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Content based on state
            entriesAsync.when(
              data: (allEntries) {
                if (allEntries.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _EmptyJournal(),
                    ),
                  );
                }

                if (filteredEntries.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _NoResults(),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList.separated(
                    itemCount: filteredEntries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final entry = filteredEntries[index];
                      return _EntryCard(
                        entry: entry,
                        onTap: () => context.push('/entry/${entry.id}'),
                      );
                    },
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              ),
              error: (error, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'Error loading entries: $error',
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.entry,
    required this.onTap,
  });

  final Entry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ReviewCard(
      title: entry.title,
      creator: entry.creator,
      coverUrl: entry.coverUrl,
      rating: entry.rating,
      date: _formatDate(entry.updatedAt),
      mediaType: entry.type.label,
      onTap: onTap,
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }
}

class _EmptyJournal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.menu_book_outlined,
                size: 40,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your journal is empty',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking books, movies, and more\nby tapping the + button below',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.search_off,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No matching entries',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
