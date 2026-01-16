import 'package:flutter/material.dart';
import '../../core/core.dart';
import 'day_button.dart';

/// Empty state widget for when there's no content to display
class DayEmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;
  final Widget? customIcon;

  const DayEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.buttonLabel,
    this.onButtonPressed,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (customIcon != null)
              customIcon!
            else if (icon != null)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary(context),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 40,
                    color: AppColors.labelTertiary(context),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTypography.title3(context),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: AppTypography.body(context).copyWith(
                  color: AppColors.labelSecondary(context),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (buttonLabel != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              DayButton(
                label: buttonLabel!,
                onPressed: onButtonPressed,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error state widget for when something goes wrong
class DayErrorState extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final VoidCallback? onRetry;

  const DayErrorState({
    super.key,
    this.title,
    this.subtitle,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return DayEmptyState(
      icon: Icons.error_outline,
      title: title ?? 'Something went wrong',
      subtitle: subtitle,
      buttonLabel: onRetry != null ? 'Try Again' : null,
      onButtonPressed: onRetry,
    );
  }
}
