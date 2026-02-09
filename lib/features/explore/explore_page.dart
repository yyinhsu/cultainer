import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/app_text_field.dart';

/// The explore page for discovering new media.
class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final _searchController = TextEditingController();
  Set<String> _selectedFilters = {'All'};

  static const _filters = ['All', 'Books', 'Movies', 'TV', 'Music'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      'Explore',
                      style: AppTypography.displayLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppSearchField(
                      controller: _searchController,
                      hint: 'Search books, movies, music...',
                      onChanged: (value) {
                        // TODO(search): Implement search
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Filter chips
            SliverToBoxAdapter(
              child: AppFilterChipList(
                filters: _filters,
                selectedFilters: _selectedFilters,
                onFilterChanged: (filter, selected) {
                  setState(() {
                    if (filter == 'All') {
                      _selectedFilters = {'All'};
                    } else {
                      _selectedFilters.remove('All');
                      if (selected) {
                        _selectedFilters.add(filter);
                      } else {
                        _selectedFilters.remove(filter);
                      }
                      if (_selectedFilters.isEmpty) {
                        _selectedFilters = {'All'};
                      }
                    }
                  });
                },
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Trending section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trending',
                      style: AppTypography.headlineMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          return _TrendingCard(
                            title: 'Title ${index + 1}',
                            subtitle: 'Creator ${index + 1}',
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // Recommended section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recommended For You',
                      style: AppTypography.headlineMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _EmptyRecommendations(),
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

class _TrendingCard extends StatelessWidget {
  const _TrendingCard({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover placeholder
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.image_outlined,
                color: AppColors.textTertiary,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _EmptyRecommendations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
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
              'Add more entries to get\npersonalized recommendations',
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
