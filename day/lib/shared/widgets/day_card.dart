import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/core.dart';

/// Reusable card widget following Apple design guidelines
/// Provides consistent styling for content containers
class DayCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final double? borderRadius;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool hasShadow;
  final bool? hasBorder;
  final double? width;
  final double? height;

  const DayCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.onTap,
    this.onLongPress,
    this.hasShadow = false,
    this.hasBorder,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectivePadding = padding ?? AppSpacing.cardPadding;
    final effectiveBorderRadius = borderRadius ?? AppSpacing.radiusLg;
    final effectiveHasBorder = hasBorder ?? isDark;

    Widget content = Container(
      padding: effectivePadding,
      decoration: BoxDecoration(
        border: effectiveHasBorder
            ? Border.all(
                color: AppColors.separator(context),
                width: 0.5,
              )
            : null,
        boxShadow: hasShadow && !isDark
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: child,
    );

    if (onTap != null || onLongPress != null) {
      content = Material(
        color: backgroundColor ?? AppColors.surface(context),
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          child: content,
        ),
      );
    } else {
      content = Material(
        color: backgroundColor ?? AppColors.surface(context),
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        child: content,
      );
    }

    Widget card = Container(
      width: width,
      height: height,
      margin: margin,
      child: content,
    );

    if (onTap != null) {
      card = card
          .animate(
            target: onTap != null ? 1 : 0,
          )
          .fadeIn(duration: 200.ms)
          .scale(
            begin: const Offset(0.98, 0.98),
            end: const Offset(1.0, 1.0),
            duration: 150.ms,
          );
    }

    return card;
  }
}

/// Apple-style list tile for settings and lists
/// Provides consistent styling for list items
class DayListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;
  final Color? backgroundColor;
  final EdgeInsets? padding;

  const DayListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    bool? showChevron,
    this.backgroundColor,
    this.padding,
  }) : showChevron = showChevron ?? (onTap != null);

  @override
  Widget build(BuildContext context) {
    final effectivePadding =
        padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12);

    return DayCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      backgroundColor: backgroundColor,
      child: Padding(
        padding: effectivePadding,
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTypography.body(context),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTypography.footnote(context).copyWith(
                        color: AppColors.labelSecondary(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (showChevron && onTap != null)
              Icon(
                Icons.chevron_right,
                color: AppColors.labelTertiary(context),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

/// Groups content with optional header and footer
/// Following Apple's grouped list design pattern
class DaySection extends StatelessWidget {
  final List<Widget> children;
  final String? header;
  final String? footer;
  final EdgeInsets? padding;

  const DaySection({
    super.key,
    required this.children,
    this.header,
    this.footer,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null)
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 8,
              ),
              child: Text(
                header!.toUpperCase(),
                style: AppTypography.footnote(context).copyWith(
                  color: AppColors.labelSecondary(context),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(
                children: _buildChildrenWithDividers(context),
              ),
            ),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
              ),
              child: Text(
                footer!,
                style: AppTypography.caption1(context).copyWith(
                  color: AppColors.labelTertiary(context),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildChildrenWithDividers(BuildContext context) {
    final List<Widget> widgets = [];

    for (int i = 0; i < children.length; i++) {
      widgets.add(children[i]);

      // Add divider between items (but not after the last one)
      if (i < children.length - 1) {
        widgets.add(
          Divider(
            height: 0.5,
            thickness: 0.5,
            color: AppColors.separator(context),
            indent: 16,
          ),
        );
      }
    }

    return widgets;
  }
}
