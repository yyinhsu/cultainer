import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Button variants for the Cultainer app.
enum AppButtonVariant {
  primary,
  secondary,
  ghost,
  destructive,
}

/// A styled button component for the Cultainer app.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle();

    Widget child = Row(
      mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getTextColor(),
                ),
              ),
            ),
          )
        else if (icon != null)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(icon, size: 20),
          ),
        Text(label),
      ],
    );

    if (isExpanded) {
      child = SizedBox(
        width: double.infinity,
        child: child,
      );
    }

    switch (variant) {
      case AppButtonVariant.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: child,
        );
      case AppButtonVariant.secondary:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: child,
        );
      case AppButtonVariant.ghost:
      case AppButtonVariant.destructive:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: child,
        );
    }
  }

  ButtonStyle _getButtonStyle() {
    switch (variant) {
      case AppButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTypography.labelLarge,
        );
      case AppButtonVariant.secondary:
        return OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: AppColors.border),
          textStyle: AppTypography.labelLarge,
        );
      case AppButtonVariant.ghost:
        return TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: AppTypography.labelLarge,
        );
      case AppButtonVariant.destructive:
        return TextButton.styleFrom(
          foregroundColor: AppColors.error,
          backgroundColor: AppColors.errorBackground,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTypography.labelLarge,
        );
    }
  }

  Color _getTextColor() {
    switch (variant) {
      case AppButtonVariant.primary:
        return AppColors.textPrimary;
      case AppButtonVariant.secondary:
        return AppColors.textPrimary;
      case AppButtonVariant.ghost:
        return AppColors.primary;
      case AppButtonVariant.destructive:
        return AppColors.error;
    }
  }
}

/// A circular icon button for the Cultainer app.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.onPressed,
    super.key,
    this.size = 44,
    this.backgroundColor,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(size / 2),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(
          icon,
          color: iconColor ?? AppColors.textSecondary,
          size: size * 0.5,
        ),
      ),
    );
  }
}
