import 'package:flutter/widgets.dart';

/// Responsive layout breakpoints.
abstract final class Breakpoints {
  /// Width below which compact/mobile layout is used.
  static const double mobile = 600;

  /// Width at or above which tablet layout is used.
  static const double tablet = 800;

  /// Width at or above which desktop layout is used (sidebar nav).
  static const double desktop = 800;

  /// Width at or above which wide desktop layout is used.
  static const double wideDesktop = 1200;
}

/// Layout category for responsive design.
enum LayoutSize { mobile, tablet, desktop }

/// Extension to get the current layout size from BuildContext.
extension ResponsiveLayout on BuildContext {
  /// Returns the current layout size based on screen width.
  LayoutSize get layoutSize {
    final width = MediaQuery.sizeOf(this).width;
    if (width >= Breakpoints.desktop) return LayoutSize.desktop;
    if (width >= Breakpoints.tablet) return LayoutSize.tablet;
    return LayoutSize.mobile;
  }

  /// Whether the current layout uses a sidebar (desktop/tablet).
  bool get isDesktopLayout =>
      MediaQuery.sizeOf(this).width >= Breakpoints.desktop;
}
