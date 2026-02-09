import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// A styled text input field for the Cultainer app.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.enabled = true,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          maxLines: maxLines,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          validator: validator,
          enabled: enabled,
          autofocus: autofocus,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.textSecondary)
                : null,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}

/// A search input field for the Cultainer app.
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    this.controller,
    this.hint = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        autofocus: autofocus,
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.textPrimary,
        ),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textSecondary,
          ),
          suffixIcon: controller != null
              ? ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller!,
                  builder: (context, value, child) {
                    if (value.text.isEmpty) return const SizedBox.shrink();
                    return IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () {
                        controller!.clear();
                        onChanged?.call('');
                      },
                    );
                  },
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
