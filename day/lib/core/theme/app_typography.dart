import 'package:flutter/material.dart';
import 'app_colors.dart';

/// AppTypography - Typography system for Day app following Apple Human Interface Guidelines
/// Provides consistent text styles across the app with theme-aware colors
class AppTypography {
  // Private constructor to prevent instantiation
  AppTypography._();

  /// System font family - SF Pro Display
  static const String _fontFamily = '.SF Pro Display';

  // ============================================================================
  // STANDARD TEXT STYLES
  // ============================================================================

  /// Large Title - Used for main headings
  /// Size: 34, Weight: Bold
  static TextStyle largeTitle(BuildContext context) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 34,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.37,
      height: 1.2,
      color: AppColors.label(context),
    );
  }

  /// Title 1 - Used for primary page titles
  /// Size: 28, Weight: Bold
  static TextStyle title1(BuildContext context) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.36,
      height: 1.2,
      color: AppColors.label(context),
    );
  }

  /// Title 2 - Used for secondary section titles
  /// Size: 22, Weight: Bold
  static TextStyle title2(BuildContext context) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.35,
      height: 1.25,
      color: AppColors.label(context),
    );
  }

  /// Title 3 - Used for tertiary headings
  /// Size: 20, Weight: Semibold
  static TextStyle title3(BuildContext context) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.38,
      height: 1.25,
      color: AppColors.label(context),
    );
  }

  /// Headline - Used for emphasized text in body content
  /// Size: 17, Weight: Semibold
  static TextStyle headline(BuildContext context) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 17,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.41,
      height: 1.3,
      color: AppColors.label(context),
    );
  }

  /// Body - Default text style for body content
  /// Size: 17, Weight: Regular
  static TextStyle body(BuildContext context) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 17,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.41,
      height: 1.3,
      color: AppColors.label(context),
    );
  }

  /// Callout - Used for highlighted body text
  /// Size: 16, Weight: Regular
  static TextStyle callout(BuildContext context) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.32,
      height: 1.3,
      color: AppColors.label(context),
    );
  }

  /// Subhead - Used for secondary body text
  /// Size: 15, Weight: Regular
  static TextStyle subhead(BuildContext context) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 15,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.24,
      height: 1.35,
      color: AppColors.label(context),
    );
  }

  /// Footnote - Used for supplementary text
  /// Size: 13, Weight: Regular
  static TextStyle footnote(BuildContext context) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 13,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.08,
      height: 1.4,
      color: AppColors.labelSecondary(context),
    );
  }

  /// Caption 1 - Used for captions and labels
  /// Size: 12, Weight: Regular
  static TextStyle caption1(BuildContext context) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.4,
      color: AppColors.labelSecondary(context),
    );
  }

  /// Caption 2 - Used for tertiary captions
  /// Size: 11, Weight: Regular
  static TextStyle caption2(BuildContext context) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 11,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.07,
      height: 1.45,
      color: AppColors.labelTertiary(context),
    );
  }

  // ============================================================================
  // SPECIALIZED STYLES
  // ============================================================================

  /// Display Large - Used for very large numbers or emphasis (e.g., streak count)
  /// Size: 56, Weight: Bold
  static TextStyle displayLarge(BuildContext context) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 56,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      height: 1.1,
      color: AppColors.label(context),
    );
  }

  /// Display Medium - Used for large display text
  /// Size: 44, Weight: Semibold
  static TextStyle displayMedium(BuildContext context) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 44,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
      height: 1.1,
      color: AppColors.label(context),
    );
  }

  /// Button - Used for button text
  /// Size: 17, Weight: Semibold
  static TextStyle button(BuildContext context) {
    return const TextStyle(
      fontFamily: _fontFamily,
      fontSize: 17,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.41,
      height: 1.3,
      color: Colors.white,
    );
  }

  /// Button Small - Used for smaller button text
  /// Size: 15, Weight: Semibold
  static TextStyle buttonSmall(BuildContext context) {
    return const TextStyle(
      fontFamily: _fontFamily,
      fontSize: 15,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.24,
      height: 1.3,
      color: Colors.white,
    );
  }

  /// Link - Used for clickable link text
  /// Size: 17, Weight: Regular
  static TextStyle link(BuildContext context) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 17,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.41,
      height: 1.3,
      color: AppColors.accent,
    );
  }
}
