import 'dart:ui';
import 'package:flutter/material.dart';

/// Extension methods for Color to simplify color operations and conversions
extension ColorExtensions on Color {
  /// Converts color to hex string without # prefix (e.g., "FF5733")
  String get toHex {
    return '${red.toRadixString(16).padLeft(2, '0')}'
        '${green.toRadixString(16).padLeft(2, '0')}'
        '${blue.toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
  }

  /// Converts color to hex string with # prefix (e.g., "#FF5733")
  String get toHexWithHash {
    return '#$toHex';
  }

  /// Returns a new color with the specified lightness (0.0-1.0)
  Color withLightness(double lightness) {
    assert(lightness >= 0.0 && lightness <= 1.0);
    final hslColor = HSLColor.fromColor(this);
    return hslColor.withLightness(lightness).toColor();
  }

  /// Returns a lighter version of this color
  /// [amount] is the amount to increase lightness (default 0.1)
  Color lighter([double amount = 0.1]) {
    assert(amount >= 0.0 && amount <= 1.0);
    final hslColor = HSLColor.fromColor(this);
    final newLightness = (hslColor.lightness + amount).clamp(0.0, 1.0);
    return hslColor.withLightness(newLightness).toColor();
  }

  /// Returns a darker version of this color
  /// [amount] is the amount to decrease lightness (default 0.1)
  Color darker([double amount = 0.1]) {
    assert(amount >= 0.0 && amount <= 1.0);
    final hslColor = HSLColor.fromColor(this);
    final newLightness = (hslColor.lightness - amount).clamp(0.0, 1.0);
    return hslColor.withLightness(newLightness).toColor();
  }

  /// Returns a new color with the specified saturation (0.0-1.0)
  Color withSaturation(double saturation) {
    assert(saturation >= 0.0 && saturation <= 1.0);
    final hslColor = HSLColor.fromColor(this);
    return hslColor.withSaturation(saturation).toColor();
  }

  /// Returns a desaturated version of this color
  /// [amount] is the amount to decrease saturation (default 0.1)
  Color desaturated([double amount = 0.1]) {
    assert(amount >= 0.0 && amount <= 1.0);
    final hslColor = HSLColor.fromColor(this);
    final newSaturation = (hslColor.saturation - amount).clamp(0.0, 1.0);
    return hslColor.withSaturation(newSaturation).toColor();
  }

  /// Returns the relative luminance of this color (0.0-1.0)
  /// Based on WCAG 2.0 formula
  double get luminance {
    return computeLuminance();
  }

  /// Returns true if this color is light (luminance > 0.5)
  bool get isLight {
    return luminance > 0.5;
  }

  /// Returns true if this color is dark (luminance <= 0.5)
  bool get isDark {
    return luminance <= 0.5;
  }

  /// Returns white or black color depending on the luminance
  /// Use this to ensure text is readable on this background color
  Color get contrastingTextColor {
    return isDark ? Colors.white : Colors.black;
  }
}
