import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// A filter chip component for the Cultainer app.
class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
    super.key,
    this.icon,
  });

  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelected(!isSelected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A horizontal scrollable list of filter chips.
class AppFilterChipList extends StatelessWidget {
  const AppFilterChipList({
    required this.filters,
    required this.selectedFilters,
    required this.onFilterChanged,
    super.key,
  });

  final List<String> filters;
  final Set<String> selectedFilters;
  final void Function(String filter, bool selected) onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: filters.map((filter) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AppFilterChip(
              label: filter,
              isSelected: selectedFilters.contains(filter),
              onSelected: (selected) => onFilterChanged(filter, selected),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// A tag chip for displaying entry tags.
class AppTagChip extends StatelessWidget {
  const AppTagChip({
    required this.label,
    super.key,
    this.color,
    this.onTap,
    this.onDelete,
  });

  final String label;
  final Color? color;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: chipColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: chipColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onDelete,
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: chipColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
