import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/core.dart';

/// Button variant types following Apple design guidelines
enum DayButtonVariant {
  /// Filled button with accent color (primary actions)
  primary,

  /// Outlined button (secondary actions)
  secondary,

  /// Text-only button (tertiary actions)
  text,

  /// Destructive button in red (delete/remove actions)
  destructive,
}

/// Reusable button widget following Apple design guidelines
/// Supports multiple variants, loading states, and icons
class DayButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final DayButtonVariant variant;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool isExpanded;
  final double? width;
  final EdgeInsets? padding;

  const DayButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = DayButtonVariant.primary,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isExpanded = false,
    this.width,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final buttonChild = _buildButtonChild(context);
    final effectiveWidth = isExpanded ? double.infinity : width;
    final effectivePadding =
        padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16);

    Widget button;

    switch (variant) {
      case DayButtonVariant.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.accent.withOpacity(0.5),
            disabledForegroundColor: Colors.white.withOpacity(0.5),
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: effectivePadding,
            minimumSize: Size(effectiveWidth ?? 0, 52),
          ),
          child: buttonChild,
        );
        break;

      case DayButtonVariant.secondary:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.accent,
            disabledForegroundColor: AppColors.accent.withOpacity(0.5),
            side: BorderSide(
              color: onPressed == null
                  ? AppColors.accent.withOpacity(0.5)
                  : AppColors.accent,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: effectivePadding,
            minimumSize: Size(effectiveWidth ?? 0, 52),
          ),
          child: buttonChild,
        );
        break;

      case DayButtonVariant.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.accent,
            disabledForegroundColor: AppColors.accent.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: effectivePadding,
            minimumSize: Size(effectiveWidth ?? 0, 52),
          ),
          child: buttonChild,
        );
        break;

      case DayButtonVariant.destructive:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.error.withOpacity(0.5),
            disabledForegroundColor: Colors.white.withOpacity(0.5),
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: effectivePadding,
            minimumSize: Size(effectiveWidth ?? 0, 52),
          ),
          child: buttonChild,
        );
        break;
    }

    if (effectiveWidth != null) {
      button = SizedBox(width: effectiveWidth, child: button);
    }

    return button
        .animate(target: onPressed != null ? 1 : 0)
        .fadeIn(duration: 200.ms);
  }

  Widget _buildButtonChild(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            variant == DayButtonVariant.secondary ||
                    variant == DayButtonVariant.text
                ? AppColors.accent
                : Colors.white,
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon != null) ...[
          Icon(leadingIcon, size: 20),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: AppTypography.button(context),
        ),
        if (trailingIcon != null) ...[
          const SizedBox(width: 8),
          Icon(trailingIcon, size: 20),
        ],
      ],
    );
  }
}

/// Circular icon button following Apple design guidelines
/// Ideal for toolbar actions and floating buttons
class DayIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final double iconSize;
  final String? tooltip;
  final bool showBadge;
  final Color? badgeColor;

  const DayIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 44,
    this.iconSize = 24,
    this.tooltip,
    this.showBadge = false,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor =
        iconColor ?? AppColors.labelPrimary(context);

    Widget button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface(context),
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Center(
            child: Icon(
              icon,
              size: iconSize,
              color: onPressed != null
                  ? effectiveIconColor
                  : effectiveIconColor.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );

    if (showBadge) {
      button = Stack(
        clipBehavior: Clip.none,
        children: [
          button,
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: badgeColor ?? AppColors.error,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.background(context),
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button.animate().fadeIn(duration: 200.ms).scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1.0, 1.0),
          duration: 200.ms,
        );
  }
}

/// Simple text button for inline actions
/// Minimal style for less prominent actions
class DayTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final bool underline;

  const DayTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.underline = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.accent;

    return GestureDetector(
      onTap: onPressed,
      child: Text(
        label,
        style: AppTypography.link(context).copyWith(
          color: onPressed != null
              ? effectiveColor
              : effectiveColor.withOpacity(0.5),
          decoration: underline ? TextDecoration.underline : null,
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}
