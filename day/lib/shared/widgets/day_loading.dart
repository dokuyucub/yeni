import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/core.dart';
import 'day_card.dart';

/// Simple centered loading spinner
class DayLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const DayLoadingIndicator({
    super.key,
    this.size = 32,
    this.color,
    this.strokeWidth = 3,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.accent,
        ),
        strokeWidth: strokeWidth,
      ),
    );
  }
}

/// Full screen loading overlay with optional message
class DayLoadingOverlay extends StatelessWidget {
  final String? message;
  final bool barrierDismissible;

  const DayLoadingOverlay({
    super.key,
    this.message,
    this.barrierDismissible = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: DayCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const DayLoadingIndicator(),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  style: AppTypography.body(context),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Shimmer loading placeholder effect
class DayShimmer extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  const DayShimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor:
          baseColor ?? (isDark ? Colors.grey[800]! : Colors.grey[300]!),
      highlightColor:
          highlightColor ?? (isDark ? Colors.grey[700]! : Colors.grey[100]!),
      child: child,
    );
  }
}

/// Rectangular shimmer placeholder box
class DayShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const DayShimmerBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return DayShimmer(
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Card-shaped shimmer placeholder
class DayShimmerCard extends StatelessWidget {
  final double height;
  final double? width;

  const DayShimmerCard({
    super.key,
    this.height = 120,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return DayShimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
