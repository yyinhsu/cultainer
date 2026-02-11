import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:cultainer/core/constants/enums.dart';
import 'package:cultainer/core/theme/app_colors.dart';
import 'package:cultainer/core/theme/app_typography.dart';
import 'package:cultainer/core/widgets/app_button.dart';
import 'package:cultainer/models/entry.dart';
import 'package:cultainer/features/journal/entry_providers.dart';

/// Entry detail page displaying full information about a media entry.
class EntryDetailPage extends ConsumerWidget {
  const EntryDetailPage({
    required this.entryId,
    super.key,
  });

  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entryAsync = ref.watch(entryProvider(entryId));

    return entryAsync.when(
      data: (entry) {
        if (entry == null) {
          return _buildNotFound(context);
        }
        return _EntryDetailContent(entry: entry);
      },
      loading: () => _buildLoading(context),
      error: (error, _) => _buildError(context, error),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }

  Widget _buildNotFound(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Entry not found',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading entry',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryDetailContent extends ConsumerWidget {
  const _EntryDetailContent({required this.entry});

  final Entry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Cover image app bar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.surface,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              ),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: AppColors.textPrimary),
                ),
                onPressed: () => context.push('/entry/${entry.id}/edit'),
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete, color: AppColors.error),
                ),
                onPressed: () => _showDeleteDialog(context, ref),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildCoverImage(),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and type badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          entry.title,
                          style: AppTypography.displayLarge.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildTypeBadge(),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Creator
                  Text(
                    entry.creator,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Status and rating row
                  Row(
                    children: [
                      _buildStatusBadge(),
                      const SizedBox(width: 16),
                      if (entry.rating != null) _buildRating(),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Dates
                  if (entry.startDate != null || entry.endDate != null) ...[
                    _buildDates(),
                    const SizedBox(height: 24),
                  ],

                  // Review
                  if (entry.review != null && entry.review!.isNotEmpty) ...[
                    Text(
                      'Review',
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      entry.review!,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Metadata
                  if (entry.metadata.isNotEmpty) ...[
                    Text(
                      'Details',
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMetadata(),
                    const SizedBox(height: 24),
                  ],

                  // Timestamps
                  _buildTimestamps(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverImage() {
    if (entry.coverUrl != null) {
      return Image.network(
        entry.coverUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholderCover(),
      );
    }
    return _buildPlaceholderCover();
  }

  Widget _buildPlaceholderCover() {
    return ColoredBox(
      color: AppColors.surfaceVariant,
      child: Center(
        child: Icon(
          _getMediaTypeIcon(),
          size: 80,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }

  IconData _getMediaTypeIcon() {
    switch (entry.type) {
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

  Widget _buildTypeBadge() {
    final color = _getTypeColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getMediaTypeIcon(), size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            entry.type.label,
            style: AppTypography.labelMedium.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor() {
    switch (entry.type) {
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

  Widget _buildStatusBadge() {
    final color = _getStatusColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        entry.status.label,
        style: AppTypography.labelMedium.copyWith(color: color),
      ),
    );
  }

  Color _getStatusColor() {
    switch (entry.status) {
      case EntryStatus.wishlist:
        return AppColors.wishlistColor;
      case EntryStatus.inProgress:
        return AppColors.inProgressColor;
      case EntryStatus.completed:
        return AppColors.completedColor;
      case EntryStatus.dropped:
        return AppColors.droppedColor;
      case EntryStatus.recall:
        return AppColors.recallColor;
    }
  }

  Widget _buildRating() {
    return Row(
      children: [
        const Icon(Icons.star, color: Colors.amber, size: 20),
        const SizedBox(width: 4),
        Text(
          '${entry.rating!.toStringAsFixed(1)} / 10',
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDates() {
    final dateFormat = DateFormat('MMM d, yyyy');
    return Row(
      children: [
        if (entry.startDate != null) ...[
          const Icon(Icons.play_arrow,
              size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            dateFormat.format(entry.startDate!),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
        if (entry.startDate != null && entry.endDate != null) ...[
          const SizedBox(width: 12),
          const Text('→', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(width: 12),
        ],
        if (entry.endDate != null) ...[
          const Icon(Icons.check_circle_outline,
              size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            dateFormat.format(entry.endDate!),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMetadata() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: entry.metadata.entries.map((e) {
        return _MetadataItem(label: e.key, value: e.value.toString());
      }).toList(),
    );
  }

  Widget _buildTimestamps() {
    final dateFormat = DateFormat('MMM d, yyyy');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Added on ${dateFormat.format(entry.createdAt)}',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        if (entry.updatedAt != entry.createdAt) ...[
          const SizedBox(height: 4),
          Text(
            'Updated on ${dateFormat.format(entry.updatedAt)}',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Delete Entry',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${entry.title}"? This action cannot be undone.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          AppButton(
            label: 'Delete',
            variant: AppButtonVariant.destructive,
            onPressed: () async {
              Navigator.of(context).pop();
              await ref
                  .read(entryActionProvider.notifier)
                  .deleteEntry(entry.id);
              if (context.mounted) {
                context.go('/journal');
              }
            },
          ),
        ],
      ),
    );
  }
}

class _MetadataItem extends StatelessWidget {
  const _MetadataItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
