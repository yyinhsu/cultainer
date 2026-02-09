import 'package:flutter/material.dart';

/// Typography constants for the Cultainer app.
///
/// Font configuration:
/// - Fraunces: Headers and display text (fallback to system serif)
/// - DM Sans: Body text and buttons (fallback to system sans)
/// - Inter: System text and numbers (fallback to system sans)
///
/// Note: Custom fonts are commented out in pubspec.yaml until downloaded.
/// Download from Google Fonts and uncomment to enable.
abstract final class AppTypography {
  // Font families (using null for system default until custom fonts added)
  static const String? fontFamilyDisplay = null; // 'Fraunces' when available
  static const String? fontFamilyBody = null; // 'DMSans' when available
  static const String? fontFamilySystem = null; // 'Inter' when available

  // Display styles (Fraunces)
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.3,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.2,
  );

  // Body styles (DM Sans)
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  // Label styles (DM Sans / Inter)
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );

  // System styles (Inter)
  static const TextStyle numberLarge = TextStyle(
    fontFamily: fontFamilySystem,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle numberMedium = TextStyle(
    fontFamily: fontFamilySystem,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  static const TextStyle numberSmall = TextStyle(
    fontFamily: fontFamilySystem,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.2,
  );
}
