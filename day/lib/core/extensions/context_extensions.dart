import 'package:flutter/material.dart';

/// Extension methods for BuildContext to simplify access to theme and media query data
extension ContextExtensions on BuildContext {
  /// Returns the current theme
  ThemeData get theme => Theme.of(this);

  /// Returns the current color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Returns true if the app is in dark mode
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Returns the screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Returns the screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Returns the safe area padding (notches, status bar, etc.)
  EdgeInsets get padding => MediaQuery.of(this).padding;

  /// Returns the bottom inset (typically keyboard height when visible)
  double get bottomInset => MediaQuery.of(this).viewInsets.bottom;
}
