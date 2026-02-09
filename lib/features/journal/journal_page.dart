import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/app_text_field.dart';

/// The journal page displaying all user entries.
class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final _searchController = TextEditingController();
  Set<String> _selectedFilters = {'All'};

  static const _filters = ['All', 'Books', 'Movies', 'TV', 'Music', 'Other'];
  static const _statusFilters = [
    'All Status',
    'Wishlist',
    'In Progress',
    'Completed',
    'Dropped',
  ];

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
                      'Journal',
                      style: AppTypography.displayLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppSearchField(
                      controller: _searchController,
                      hint: 'Search your entries...',
                      onChanged: (value) {
                        // TODO(search): Implement search
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Media type filters
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

            // Empty state
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _EmptyJournal(),
              ),
            ),

            // TODO(journal): Replace with actual entry list
            // SliverPadding(
            //   padding: const EdgeInsets.symmetric(horizontal: 20),
            //   sliver: SliverList.separated(
            //     itemCount: entries.length,
            //     separatorBuilder: (_, __) => const SizedBox(height: 12),
            //     itemBuilder: (context, index) {
            //       final entry = entries[index];
            //       return ReviewCard(
            //         title: entry.title,
            //         creator: entry.creator,
            //         coverUrl: entry.coverUrl,
            //         rating: entry.rating,
            //         date: entry.date,
            //         mediaType: entry.type,
            //         onTap: () => _openEntry(entry),
            //       );
            //     },
            //   ),
            // ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
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
