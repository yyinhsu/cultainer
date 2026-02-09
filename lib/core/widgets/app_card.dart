import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// A reusable card component for the Cultainer app.
///
/// Based on the design system with consistent styling.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    super.key,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 16,
            spreadRadius: -4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}

/// A card specifically for displaying entry reviews.
class ReviewCard extends StatelessWidget {
  const ReviewCard({
    required this.title,
    required this.creator,
    super.key,
    this.coverUrl,
    this.rating,
    this.date,
    this.mediaType,
    this.onTap,
  });

  final String title;
  final String creator;
  final String? coverUrl;
  final double? rating;
  final String? date;
  final String? mediaType;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        children: [
          // Cover image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 80,
              height: 110,
              color: AppColors.surfaceVariant,
              child: coverUrl != null
                  ? Image.network(
                      coverUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _PlaceholderCover(),
                    )
                  : const _PlaceholderCover(),
            ),
          ),
          const SizedBox(width: 14),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (mediaType != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getMediaTypeColor(mediaType!).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      mediaType!.toUpperCase(),
                      style: AppTypography.labelSmall.copyWith(
                        color: _getMediaTypeColor(mediaType!),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (mediaType != null) const SizedBox(height: 8),
                Text(
                  title,
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  creator,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (rating != null) ...[
                      _StarRating(rating: rating!),
                      const SizedBox(width: 12),
                    ],
                    if (date != null)
                      Text(
                        date!,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getMediaTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'book':
        return AppColors.bookColor;
      case 'movie':
        return AppColors.movieColor;
      case 'tv':
        return AppColors.tvColor;
      case 'music':
        return AppColors.musicColor;
      default:
        return AppColors.otherColor;
    }
  }
}

class _PlaceholderCover extends StatelessWidget {
  const _PlaceholderCover();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceVariant,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          color: AppColors.textTertiary,
          size: 32,
        ),
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  const _StarRating({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    // Convert 10-point scale to 5 stars
    final starRating = rating / 2;
    final fullStars = starRating.floor();
    final hasHalfStar = (starRating - fullStars) >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        IconData icon;
        if (index < fullStars) {
          icon = Icons.star;
        } else if (index == fullStars && hasHalfStar) {
          icon = Icons.star_half;
        } else {
          icon = Icons.star_border;
        }
        return Icon(
          icon,
          color: AppColors.warning,
          size: 16,
        );
      }),
    );
  }
}
