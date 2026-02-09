import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_card.dart';

/// The home page of the Cultainer app.
///
/// Displays user stats, recent activity, and quick access to collections.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
                          'User', // TODO(auth): Replace with actual user name
                          style: AppTypography.displayLarge.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    // User avatar placeholder
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: AppColors.textSecondary,
                      ),
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
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: 'Completed',
                            value: '0',
                            icon: Icons.check_circle_outline,
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            label: 'In Progress',
                            value: '0',
                            icon: Icons.play_circle_outline,
                            color: AppColors.warning,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            label: 'Wishlist',
                            value: '0',
                            icon: Icons.bookmark_outline,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // This Week section
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
                          'This Week',
                          style: AppTypography.headlineMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO(nav): Navigate to calendar
                          },
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
                    _EmptyStateCard(
                      icon: Icons.calendar_today_outlined,
                      message: 'No activity this week',
                      action: 'Add your first entry',
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // Recent Reviews section
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
                          'Recent Reviews',
                          style: AppTypography.headlineMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO(nav): Navigate to journal
                          },
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
                    _EmptyStateCard(
                      icon: Icons.rate_review_outlined,
                      message: 'No reviews yet',
                      action: 'Start tracking your media',
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
  });

  final IconData icon;
  final String message;
  final String action;

  @override
  Widget build(BuildContext context) {
    return AppCard(
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
    );
  }
}
