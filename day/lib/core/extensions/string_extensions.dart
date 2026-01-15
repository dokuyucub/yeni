import 'package:flutter/material.dart';

/// Extension methods for String to simplify common string operations
extension StringExtensions on String {
  /// Returns the string with the first letter capitalized
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Returns the string with each word capitalized
  String get capitalizeWords {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Returns true if this string is a valid email address
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    return emailRegex.hasMatch(this);
  }

  /// Returns the string truncated to [maxLength] with "..." appended if necessary
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }

  /// Parses a hex color string and returns a Color
  /// Supports formats: "FF5733", "#FF5733", "AAFF5733", "#AAFF5733"
  /// Returns Colors.black if parsing fails
  Color toColor() {
    try {
      // Remove # if present
      String hexString = replaceAll('#', '');

      // Handle 6-character RGB format (add full opacity)
      if (hexString.length == 6) {
        hexString = 'FF$hexString';
      }

      // Parse as ARGB (8 characters)
      if (hexString.length == 8) {
        final intValue = int.parse(hexString, radix: 16);
        return Color(intValue);
      }

      // Fallback to black if format is invalid
      return Colors.black;
    } catch (e) {
      // Return black as fallback if parsing fails
      return Colors.black;
    }
  }
}
