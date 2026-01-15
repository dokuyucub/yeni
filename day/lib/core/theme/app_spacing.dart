import 'package:flutter/material.dart';

/// AppSpacing - Spacing and layout constants for Day app
/// Uses 8pt grid system following design best practices
class AppSpacing {
  // Private constructor to prevent instantiation
  AppSpacing._();

  // ============================================================================
  // SPACING VALUES - 8pt Grid System
  // ============================================================================

  /// Extra extra extra small spacing - 2pt
  static const double xxxs = 2.0;

  /// Extra extra small spacing - 4pt
  static const double xxs = 4.0;

  /// Extra small spacing - 8pt
  static const double xs = 8.0;

  /// Small spacing - 12pt
  static const double sm = 12.0;

  /// Medium spacing - 16pt (base unit)
  static const double md = 16.0;

  /// Large spacing - 20pt
  static const double lg = 20.0;

  /// Extra large spacing - 24pt
  static const double xl = 24.0;

  /// Extra extra large spacing - 32pt
  static const double xxl = 32.0;

  /// Extra extra extra large spacing - 48pt
  static const double xxxl = 48.0;

  /// Huge spacing - 64pt
  static const double huge = 64.0;

  // ============================================================================
  // EDGE INSETS
  // ============================================================================

  /// Standard page horizontal padding - 16pt
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: 16);

  /// Large page horizontal padding - 20pt
  static const EdgeInsets pagePaddingLarge = EdgeInsets.symmetric(horizontal: 20);

  /// Page insets on all sides - 16pt
  static const EdgeInsets pageInsets = EdgeInsets.all(16);

  /// Card padding on all sides - 16pt
  static const EdgeInsets cardPadding = EdgeInsets.all(16);

  /// Small card padding on all sides - 12pt
  static const EdgeInsets cardPaddingSmall = EdgeInsets.all(12);

  /// List item padding - horizontal 16pt, vertical 12pt
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  );

  // ============================================================================
  // BORDER RADIUS VALUES
  // ============================================================================

  /// Extra small radius - 4pt
  static const double radiusXs = 4.0;

  /// Small radius - 8pt
  static const double radiusSm = 8.0;

  /// Medium radius - 12pt
  static const double radiusMd = 12.0;

  /// Large radius - 16pt
  static const double radiusLg = 16.0;

  /// Extra large radius - 20pt
  static const double radiusXl = 20.0;

  /// Extra extra large radius - 24pt
  static const double radiusXxl = 24.0;

  /// Full radius - 999pt (creates circular shape)
  static const double radiusFull = 999.0;

  // ============================================================================
  // BORDER RADIUS OBJECTS
  // ============================================================================

  /// Small border radius - 8pt on all corners
  static final BorderRadius borderRadiusSm = BorderRadius.circular(8);

  /// Medium border radius - 12pt on all corners
  static final BorderRadius borderRadiusMd = BorderRadius.circular(12);

  /// Large border radius - 16pt on all corners
  static final BorderRadius borderRadiusLg = BorderRadius.circular(16);

  /// Extra large border radius - 20pt on all corners
  static final BorderRadius borderRadiusXl = BorderRadius.circular(20);

  /// Card border radius - 16pt on all corners
  static final BorderRadius borderRadiusCard = BorderRadius.circular(16);

  /// Bottom sheet border radius - 20pt on top corners only
  static const BorderRadius borderRadiusSheet = BorderRadius.only(
    topLeft: Radius.circular(20),
    topRight: Radius.circular(20),
  );

  // ============================================================================
  // ANIMATION DURATIONS
  // ============================================================================

  /// Fast animation duration - 150ms
  static const Duration durationFast = Duration(milliseconds: 150);

  /// Normal animation duration - 250ms
  static const Duration durationNormal = Duration(milliseconds: 250);

  /// Slow animation duration - 400ms
  static const Duration durationSlow = Duration(milliseconds: 400);

  /// Very slow animation duration - 600ms
  static const Duration durationVerySlow = Duration(milliseconds: 600);

  // ============================================================================
  // SIZES
  // ============================================================================

  /// Small icon size - 20pt
  static const double iconSm = 20.0;

  /// Medium icon size - 24pt
  static const double iconMd = 24.0;

  /// Large icon size - 28pt
  static const double iconLg = 28.0;

  /// Extra large icon size - 32pt
  static const double iconXl = 32.0;

  /// Minimum touch target size per Apple HIG - 44pt
  static const double touchTarget = 44.0;

  /// Color picker dot size - 48pt
  static const double colorPickerDot = 48.0;

  /// Bottom navigation bar height - 84pt
  static const double bottomNavHeight = 84.0;
}
