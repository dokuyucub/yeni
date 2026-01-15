import 'package:flutter/material.dart';

/// AppColors - Color system for Day app following Apple Human Interface Guidelines
/// Provides brand colors, semantic colors, adaptive theme colors, and mood palette
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // ============================================================================
  // BRAND COLORS
  // ============================================================================

  /// Main brand color - soft purple
  static const Color accent = Color(0xFF8B5CF6);

  /// Light variant of accent color
  static const Color accentLight = Color(0xFFA78BFA);

  /// Dark variant of accent color
  static const Color accentDark = Color(0xFF7C3AED);

  /// Secondary brand color - warm coral
  static const Color secondary = Color(0xFFFF6B6B);

  /// Tertiary brand color - ocean teal
  static const Color tertiary = Color(0xFF4ECDC4);

  // ============================================================================
  // SEMANTIC COLORS
  // ============================================================================

  /// Success state color
  static const Color success = Color(0xFF34C759);

  /// Warning state color
  static const Color warning = Color(0xFFFF9500);

  /// Error state color
  static const Color error = Color(0xFFFF3B30);

  /// Info state color
  static const Color info = Color(0xFF007AFF);

  // ============================================================================
  // LIGHT MODE COLORS
  // ============================================================================

  /// Primary background color for light mode
  static const Color backgroundPrimaryLight = Color(0xFFFFFFFF);

  /// Secondary background color for light mode
  static const Color backgroundSecondaryLight = Color(0xFFF2F2F7);

  /// Tertiary background color for light mode
  static const Color backgroundTertiaryLight = Color(0xFFE5E5EA);

  /// Primary surface color for light mode
  static const Color surfacePrimaryLight = Color(0xFFFFFFFF);

  /// Secondary surface color for light mode
  static const Color surfaceSecondaryLight = Color(0xFFF9F9F9);

  /// Primary label (text) color for light mode
  static const Color labelPrimaryLight = Color(0xFF000000);

  /// Secondary label (text) color for light mode
  static const Color labelSecondaryLight = Color(0xFF3C3C43);

  /// Tertiary label (text) color for light mode
  static const Color labelTertiaryLight = Color(0xFF48484A);

  /// Separator color for light mode (20% opacity black)
  static const Color separatorLight = Color(0x33000000);

  // ============================================================================
  // DARK MODE COLORS
  // ============================================================================

  /// Primary background color for dark mode
  static const Color backgroundPrimaryDark = Color(0xFF000000);

  /// Secondary background color for dark mode
  static const Color backgroundSecondaryDark = Color(0xFF1C1C1E);

  /// Tertiary background color for dark mode
  static const Color backgroundTertiaryDark = Color(0xFF2C2C2E);

  /// Primary surface color for dark mode
  static const Color surfacePrimaryDark = Color(0xFF1C1C1E);

  /// Secondary surface color for dark mode
  static const Color surfaceSecondaryDark = Color(0xFF2C2C2E);

  /// Primary label (text) color for dark mode
  static const Color labelPrimaryDark = Color(0xFFFFFFFF);

  /// Secondary label (text) color for dark mode
  static const Color labelSecondaryDark = Color(0xFFEBEBF5);

  /// Tertiary label (text) color for dark mode
  static const Color labelTertiaryDark = Color(0xFF8E8E93);

  /// Separator color for dark mode (36% opacity white)
  static const Color separatorDark = Color(0x5C545456);

  // ============================================================================
  // MOOD PALETTE - 24 colors organized in 4 rows of 6
  // ============================================================================

  // Row 1 - Yellows/Oranges (happy, energetic)
  static const Color mood01 = Color(0xFFFFE066);
  static const Color mood02 = Color(0xFFFFD93D);
  static const Color mood03 = Color(0xFFFFC300);
  static const Color mood04 = Color(0xFFFF9500);
  static const Color mood05 = Color(0xFFFF6B35);
  static const Color mood06 = Color(0xFFFF5733);

  // Row 2 - Reds/Pinks (passionate, loving)
  static const Color mood07 = Color(0xFFE74C3C);
  static const Color mood08 = Color(0xFFC0392B);
  static const Color mood09 = Color(0xFFE84393);
  static const Color mood10 = Color(0xFFFD79A8);
  static const Color mood11 = Color(0xFFF8B4D9);
  static const Color mood12 = Color(0xFFDDA0DD);

  // Row 3 - Blues/Purples (calm, thoughtful)
  static const Color mood13 = Color(0xFFA29BFE);
  static const Color mood14 = Color(0xFF6C5CE7);
  static const Color mood15 = Color(0xFF5F27CD);
  static const Color mood16 = Color(0xFF74B9FF);
  static const Color mood17 = Color(0xFF0984E3);
  static const Color mood18 = Color(0xFF0652DD);

  // Row 4 - Greens/Neutrals (balanced, peaceful)
  static const Color mood19 = Color(0xFF00B894);
  static const Color mood20 = Color(0xFF55A630);
  static const Color mood21 = Color(0xFF2D6A4F);
  static const Color mood22 = Color(0xFF87CEEB);
  static const Color mood23 = Color(0xFFB2BEC3);
  static const Color mood24 = Color(0xFF636E72);

  /// Returns all 24 mood colors as a list
  static List<Color> get moodPalette => [
        mood01, mood02, mood03, mood04, mood05, mood06, // Row 1
        mood07, mood08, mood09, mood10, mood11, mood12, // Row 2
        mood13, mood14, mood15, mood16, mood17, mood18, // Row 3
        mood19, mood20, mood21, mood22, mood23, mood24, // Row 4
      ];

  // ============================================================================
  // ADAPTIVE METHODS - Theme-aware color selection
  // ============================================================================

  /// Returns primary background color based on current theme brightness
  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? backgroundPrimaryLight
        : backgroundPrimaryDark;
  }

  /// Returns secondary background color based on current theme brightness
  static Color backgroundSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? backgroundSecondaryLight
        : backgroundSecondaryDark;
  }

  /// Returns primary surface color based on current theme brightness
  static Color surface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? surfacePrimaryLight
        : surfacePrimaryDark;
  }

  /// Returns primary label color based on current theme brightness
  static Color label(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? labelPrimaryLight
        : labelPrimaryDark;
  }

  /// Returns secondary label color based on current theme brightness
  static Color labelSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? labelSecondaryLight
        : labelSecondaryDark;
  }

  /// Returns tertiary label color based on current theme brightness
  static Color labelTertiary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? labelTertiaryLight
        : labelTertiaryDark;
  }

  /// Returns separator color based on current theme brightness
  static Color separator(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? separatorLight
        : separatorDark;
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Returns mood color by index (0-23)
  /// Returns mood01 (Sunshine) if index is out of range
  static Color getMoodColor(int index) {
    if (index < 0 || index >= moodPalette.length) {
      return mood01;
    }
    return moodPalette[index];
  }

  /// Returns a map of color names for mood colors
  static Map<Color, String> getMoodColorName(Color color) {
    final Map<Color, String> colorNames = {
      mood01: 'Sunshine',
      mood02: 'Bright',
      mood03: 'Golden',
      mood04: 'Tangerine',
      mood05: 'Coral',
      mood06: 'Ember',
      mood07: 'Rose',
      mood08: 'Berry',
      mood09: 'Magenta',
      mood10: 'Blush',
      mood11: 'Cotton',
      mood12: 'Plum',
      mood13: 'Lavender',
      mood14: 'Violet',
      mood15: 'Grape',
      mood16: 'Sky',
      mood17: 'Ocean',
      mood18: 'Royal',
      mood19: 'Mint',
      mood20: 'Grass',
      mood21: 'Forest',
      mood22: 'Cloud',
      mood23: 'Mist',
      mood24: 'Stone',
    };
    return colorNames;
  }

  /// Returns the warmth of a color from 0.0 (cold) to 1.0 (warm)
  /// Based on HSL hue analysis:
  /// - Warm colors (reds, oranges, yellows): hue 0-60° and 300-360°
  /// - Cool colors (blues, greens): hue 120-240°
  /// - Transition zones: 60-120° and 240-300°
  static double getColorWarmth(Color color) {
    // Convert RGB to HSL
    final double r = color.red / 255.0;
    final double g = color.green / 255.0;
    final double b = color.blue / 255.0;

    final double max = [r, g, b].reduce((a, b) => a > b ? a : b);
    final double min = [r, g, b].reduce((a, b) => a < b ? a : b);
    final double delta = max - min;

    double hue = 0.0;
    if (delta != 0) {
      if (max == r) {
        hue = 60 * (((g - b) / delta) % 6);
      } else if (max == g) {
        hue = 60 * (((b - r) / delta) + 2);
      } else {
        hue = 60 * (((r - g) / delta) + 4);
      }
    }

    // Normalize hue to 0-360
    if (hue < 0) hue += 360;

    // Calculate warmth based on hue
    // Warm: 0-60° (reds to yellows) and 300-360° (magentas to reds)
    // Cool: 120-240° (greens to blues)
    if (hue >= 0 && hue <= 60) {
      // Red to Yellow - very warm
      return 0.8 + (hue / 60 * 0.2); // 0.8 to 1.0
    } else if (hue > 60 && hue <= 120) {
      // Yellow to Green - warm to neutral
      return 0.5 + ((120 - hue) / 60 * 0.3); // 0.8 to 0.5
    } else if (hue > 120 && hue <= 240) {
      // Green to Blue - cool
      return 0.0 + ((240 - hue) / 120 * 0.5); // 0.5 to 0.0
    } else if (hue > 240 && hue <= 300) {
      // Blue to Magenta - cool to warm
      return 0.0 + ((hue - 240) / 60 * 0.5); // 0.0 to 0.5
    } else {
      // Magenta to Red - very warm
      return 0.5 + ((hue - 300) / 60 * 0.3); // 0.5 to 0.8
    }
  }
}
