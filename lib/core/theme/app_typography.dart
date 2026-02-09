import 'package:flutter/material.dart';

/// Typography constants for the Cultainer app.
///
/// Font configuration:
/// - Fraunces: Headers and display text
/// - DM Sans: Body text and buttons
/// - Inter: System text and numbers
abstract final class AppTypography {
  // Font families
  static const String fontFamilyDisplay = 'Fraunces';
  static const String fontFamilyBody = 'DMSans';
  static const String fontFamilySystem = 'Inter';

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
