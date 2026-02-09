import 'package:flutter/material.dart';

/// Color constants for the Cultainer app.
///
/// Based on the dark theme design system from mobile.pen.
abstract final class AppColors {
  // Background colors
  static const Color background = Color(0xFF0B0B0E);
  static const Color surface = Color(0xFF16161A);
  static const Color surfaceVariant = Color(0xFF1A1A1E);

  // Border colors
  static const Color border = Color(0xFF2A2A2E);

  // Text colors
  static const Color textPrimary = Color(0xFFFAFAF9);
  static const Color textSecondary = Color(0xFF6B6B70);
  static const Color textTertiary = Color(0xFF4A4A50);

  // Accent colors
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);

  // Status colors
  static const Color error = Color(0xFFDC2626);
  static const Color errorBackground = Color(0x15DC2626);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);

  // Media type colors
  static const Color bookColor = Color(0xFF6366F1);
  static const Color movieColor = Color(0xFFEC4899);
  static const Color tvColor = Color(0xFF8B5CF6);
  static const Color musicColor = Color(0xFF22C55E);
  static const Color otherColor = Color(0xFF6B6B70);

  // Status indicator colors
  static const Color wishlistColor = Color(0xFF3B82F6);
  static const Color inProgressColor = Color(0xFFF59E0B);
  static const Color completedColor = Color(0xFF22C55E);
  static const Color droppedColor = Color(0xFFEF4444);
  static const Color recallColor = Color(0xFF8B5CF6);
}
