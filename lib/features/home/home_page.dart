import 'package:cached_network_image/cached_network_image.dart';
import 'package:cultainer/core/constants/enums.dart';
import 'package:cultainer/core/theme/app_colors.dart';
import 'package:cultainer/core/theme/app_typography.dart';
import 'package:cultainer/core/widgets/app_card.dart';
import 'package:cultainer/features/auth/auth_providers.dart';
import 'package:cultainer/features/journal/entry_providers.dart';
import 'package:cultainer/models/entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The home page of the Cultainer app.
///
/// Displays user stats, recent activity, and quick access to collections.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final countsAsync = ref.watch(entryCountsProvider);
    final entriesAsync = ref.watch(entriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.displayName ?? 'User',
                          style: AppTypography.displayLarge.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => context.push('/calendar'),
                          icon: const Icon(
                            Icons.calendar_month_outlined,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        // User avatar
                        GestureDetector(
                          onTap: () => context.go('/profile'),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppColors.border),
                              image: user?.photoURL != null
                                  ? DecorationImage(
                                      image: CachedNetworkImageProvider(
                                          user!.photoURL!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: user?.photoURL == null
                                ? const Icon(
                                    Icons.person,
                                    color: AppColors.textSecondary,
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Stats section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Stats',
                      style: AppTypography.headlineMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    countsAsync.when(
                      data: (counts) => Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              label: 'Completed',
                              value: '${counts['completed'] ?? 0}',
                              icon: Icons.check_circle_outline,
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              label: 'In Progress',
                              value: '${counts['in-progress'] ?? 0}',
                              icon: Icons.play_circle_outline,
                              color: AppColors.warning,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              label: 'Wishlist',
                              value: '${counts['wishlist'] ?? 0}',
                              icon: Icons.bookmark_outline,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      loading: () => const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                      error: (_, __) => const Text('Error loading stats'),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // Recent Activity section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Activity',
                          style: AppTypography.headlineMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/journal'),
                          child: Text(
                            'See All',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    entriesAsync.when(
                      data: (entries) {
                        // Show most recent 5 entries
                        final recentEntries = entries.take(5).toList();
                        if (recentEntries.isEmpty) {
                          return _EmptyStateCard(
                            icon: Icons.calendar_today_outlined,
                            message: 'No activity yet',
                            action: 'Add your first entry',
                            onTap: () => context.push('/entry/search'),
                          );
                        }
                        return Column(
                          children: recentEntries
                              .map((e) => _RecentEntryCard(entry: e))
                              .toList(),
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                      error: (_, __) => const Text('Error loading entries'),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // In Progress section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Currently Enjoying',
                          style: AppTypography.headlineMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/journal'),
                          child: Text(
                            'See All',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    entriesAsync.when(
                      data: (entries) {
                        final inProgress = entries
                            .where((e) => e.status.value == 'in-progress')
                            .take(3)
                            .toList();
                        if (inProgress.isEmpty) {
                          return _EmptyStateCard(
                            icon: Icons.play_circle_outline,
                            message: 'Nothing in progress',
                            action: 'Start something new',
                            onTap: () => context.push('/entry/search'),
                          );
                        }
                        return SizedBox(
                          height: 180,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: inProgress.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              return _InProgressCard(entry: inProgress[index]);
                            },
                          ),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // Collections section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Collections',
                      style: AppTypography.headlineMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    entriesAsync.when(
                      data: (entries) {
                        if (entries.isEmpty) {
                          return _EmptyStateCard(
                            icon: Icons.collections_bookmark_outlined,
                            message: 'No collections yet',
                            action: 'Add entries to see them here',
                            onTap: () => context.push('/entry/search'),
                          );
                        }
                        return _CollectionsGrid(entries: entries);
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTypography.numberLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({
    required this.icon,
    required this.message,
    required this.action,
    this.onTap,
  });

  final IconData icon;
  final String message;
  final String action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Center(
          child: Column(
            children: [
              Icon(
                icon,
                size: 48,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                action,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentEntryCard extends StatelessWidget {
  const _RecentEntryCard({required this.entry});

  final Entry entry;

  IconData get _typeIcon {
    switch (entry.type) {
      case MediaType.book:
        return Icons.book;
      case MediaType.movie:
        return Icons.movie;
      case MediaType.tv:
        return Icons.tv;
      case MediaType.music:
        return Icons.music_note;
      case MediaType.other:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => context.push('/entry/${entry.id}'),
        child: AppCard(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Cover thumbnail
              Container(
                width: 48,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  image: entry.coverUrl != null
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(entry.coverUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: entry.coverUrl == null
                    ? Icon(_typeIcon, color: AppColors.textTertiary)
                    : null,
              ),
              const SizedBox(width: 12),
              // Entry info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.creator,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Rating if available
              if (entry.rating != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        entry.rating!.toStringAsFixed(1),
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CollectionsGrid extends StatelessWidget {
  const _CollectionsGrid({required this.entries});

  final List<Entry> entries;

  @override
  Widget build(BuildContext context) {
    // Group entries by type and only show types that have entries
    final grouped = <MediaType, int>{};
    for (final entry in entries) {
      grouped[entry.type] = (grouped[entry.type] ?? 0) + 1;
    }

    final types = grouped.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: types.length,
      itemBuilder: (context, index) {
        final type = types[index].key;
        final count = types[index].value;
        return _CollectionCard(type: type, count: count);
      },
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({
    required this.type,
    required this.count,
  });

  final MediaType type;
  final int count;

  Color get _color {
    switch (type) {
      case MediaType.book:
        return AppColors.bookColor;
      case MediaType.movie:
        return AppColors.movieColor;
      case MediaType.tv:
        return AppColors.tvColor;
      case MediaType.music:
        return AppColors.musicColor;
      case MediaType.other:
        return AppColors.otherColor;
    }
  }

  IconData get _icon {
    switch (type) {
      case MediaType.book:
        return Icons.menu_book;
      case MediaType.movie:
        return Icons.movie;
      case MediaType.tv:
        return Icons.tv;
      case MediaType.music:
        return Icons.music_note;
      case MediaType.other:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to journal with type filter
        context.go('/journal');
      },
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_icon, color: _color, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${type.label}s',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '$count ${count == 1 ? 'entry' : 'entries'}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InProgressCard extends StatelessWidget {
  const _InProgressCard({required this.entry});

  final Entry entry;

  IconData get _typeIcon {
    switch (entry.type) {
      case MediaType.book:
        return Icons.book;
      case MediaType.movie:
        return Icons.movie;
      case MediaType.tv:
        return Icons.tv;
      case MediaType.music:
        return Icons.music_note;
      case MediaType.other:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/entry/${entry.id}'),
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                image: entry.coverUrl != null
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(entry.coverUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: entry.coverUrl == null
                  ? Center(
                      child: Icon(
                        _typeIcon,
                        size: 32,
                        color: AppColors.textTertiary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              entry.title,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              entry.type.label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
