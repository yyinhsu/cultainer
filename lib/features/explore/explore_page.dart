import 'package:cached_network_image/cached_network_image.dart';
import 'package:cultainer/core/constants/enums.dart';
import 'package:cultainer/core/theme/app_colors.dart';
import 'package:cultainer/core/theme/app_typography.dart';
import 'package:cultainer/core/widgets/app_button.dart';
import 'package:cultainer/core/widgets/app_card.dart';
import 'package:cultainer/core/widgets/app_chip.dart';
import 'package:cultainer/features/journal/entry_providers.dart';
import 'package:cultainer/services/recommendation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The explore page for discovering new media based on recommendations.
class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  MediaType? _selectedType;

  static const _filters = <(String, MediaType?)>[
    ('All', null),
    ('Books', MediaType.book),
    ('Movies', MediaType.movie),
    ('TV', MediaType.tv),
    ('Music', MediaType.music),
  ];

  @override
  Widget build(BuildContext context) {
    final recommendationsAsync = ref.watch(recommendationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Explore',
                  style: AppTypography.displayLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),

            // Category filter chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final (label, type) = _filters[index];
                    final isSelected = _selectedType == type;
                    return AppFilterChip(
                      label: label,
                      isSelected: isSelected,
                      onSelected: (_) => setState(() => _selectedType = type),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Recommendations content
            recommendationsAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(48),
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              error: (error, _) => SliverToBoxAdapter(
                child: _buildErrorState(error.toString()),
              ),
              data: (recommendations) {
                final filtered = _selectedType == null
                    ? recommendations
                    : recommendations
                        .where((r) => r.result.type == _selectedType)
                        .toList();

                if (filtered.isEmpty) {
                  return SliverToBoxAdapter(
                    child: _buildEmptyState(recommendations.isEmpty),
                  );
                }

                // Group recommendations by creator
                final grouped = <String, List<Recommendation>>{};
                for (final rec in filtered) {
                  final key = rec.creatorName;
                  grouped.putIfAbsent(key, () => []).add(rec);
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final creatorName = grouped.keys.elementAt(index);
                      final items = grouped[creatorName]!;
                      return _RecommendationSection(
                        creatorName: creatorName,
                        reason: items.first.reason,
                        recommendations: items,
                      );
                    },
                    childCount: grouped.length,
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool noEntries) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.auto_awesome_outlined,
                size: 48,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                noEntries
                    ? 'Start recording your media experiences\n'
                        'to discover related works'
                    : 'No recommendations for this category.\n'
                        'Try another filter!',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load recommendations',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecommendationSection extends ConsumerWidget {
  const _RecommendationSection({
    required this.creatorName,
    required this.reason,
    required this.recommendations,
  });

  final String creatorName;
  final String reason;
  final List<Recommendation> recommendations;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with creator name and reason
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Related to Your Reviews',
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reason,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Horizontal card list
          SizedBox(
            height: 240,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: recommendations.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return _RecommendationCard(
                  recommendation: recommendations[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends ConsumerWidget {
  const _RecommendationCard({required this.recommendation});

  final Recommendation recommendation;

  Color _mediaTypeColor(MediaType type) {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = recommendation.result;
    final typeColor = _mediaTypeColor(result.type);

    return GestureDetector(
      onTap: () => _showDetailSheet(context, ref),
      child: SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 160,
                width: 150,
                child: result.coverUrl != null
                    ? CachedNetworkImage(
                        imageUrl: result.coverUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: AppColors.surfaceVariant,
                          child: const Center(
                            child: Icon(
                              Icons.image_outlined,
                              color: AppColors.textTertiary,
                              size: 32,
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.surfaceVariant,
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: AppColors.textTertiary,
                              size: 32,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.surfaceVariant,
                        child: const Center(
                          child: Icon(
                            Icons.image_outlined,
                            color: AppColors.textTertiary,
                            size: 32,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),

            // Title
            Text(
              result.title,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // Creator name
            Text(
              recommendation.creatorName,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Media type badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                result.type.label,
                style: AppTypography.labelSmall.copyWith(
                  color: typeColor,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailSheet(BuildContext context, WidgetRef ref) {
    final result = recommendation.result;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title and creator
              Text(
                result.title,
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              if (result.creator != null)
                Text(
                  result.creator!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                recommendation.reason,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
              if (result.releaseYear != null) ...[
                const SizedBox(height: 4),
                Text(
                  result.releaseYear!,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Add to wishlist button
              AppButton(
                label: 'Add to Wishlist',
                icon: Icons.add,
                isExpanded: true,
                onPressed: () => _addToWishlist(context, ref),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addToWishlist(BuildContext context, WidgetRef ref) async {
    final result = recommendation.result;

    await ref.read(entryActionProvider.notifier).createEntry(
          type: result.type,
          title: result.title,
          creator: result.creator ?? '',
          status: EntryStatus.wishlist,
          creatorId: result.creatorId,
          coverUrl: result.coverUrl,
          externalId: result.externalId,
        );

    if (context.mounted) {
      Navigator.of(context).pop(); // Close bottom sheet
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added "${result.title}" to wishlist'),
          action: SnackBarAction(
            label: 'View',
            onPressed: () => context.go('/journal'),
          ),
        ),
      );
    }
  }
}
