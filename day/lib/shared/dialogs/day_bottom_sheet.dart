import 'package:flutter/material.dart';
import '../../core/core.dart';

/// Shows a custom bottom sheet following Apple design guidelines
Future<T?> showDayBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  String? title,
  bool showDragHandle = true,
  bool isScrollControlled = false,
  bool isDismissible = true,
  double? maxHeight,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    backgroundColor: Colors.transparent,
    builder: (context) => DayBottomSheetContainer(
      title: title,
      showDragHandle: showDragHandle,
      maxHeight: maxHeight,
      child: child,
    ),
  );
}

/// Container for bottom sheet content
class DayBottomSheetContainer extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool showDragHandle;
  final double? maxHeight;

  const DayBottomSheetContainer({
    super.key,
    required this.child,
    this.title,
    this.showDragHandle = true,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: maxHeight != null
          ? BoxConstraints(maxHeight: maxHeight!)
          : null,
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDragHandle)
            Center(
              child: Container(
                margin: const EdgeInsets.all(12),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.labelTertiary(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                title!,
                style: AppTypography.headline(context),
                textAlign: TextAlign.center,
              ),
            ),
            Divider(
              height: 0.5,
              color: AppColors.separator(context),
            ),
          ],
          Flexible(child: child),
        ],
      ),
    );
  }
}

/// Data class for action sheet items
class DayActionSheetItem {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isDestructive;
  final bool isDefault;

  const DayActionSheetItem({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isDestructive = false,
    this.isDefault = false,
  });
}

/// Shows an iOS-style action sheet
Future<T?> showDayActionSheet<T>({
  required BuildContext context,
  required List<DayActionSheetItem> actions,
  String? title,
  String? message,
  String cancelLabel = 'Cancel',
}) {
  return showDayBottomSheet<T>(
    context: context,
    showDragHandle: false,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null || message != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (title != null)
                  Text(
                    title,
                    style: AppTypography.headline(context),
                    textAlign: TextAlign.center,
                  ),
                if (message != null) ...[
                  if (title != null) const SizedBox(height: 8),
                  Text(
                    message,
                    style: AppTypography.footnote(context).copyWith(
                      color: AppColors.labelSecondary(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        if (title != null || message != null)
          Divider(
            height: 0.5,
            color: AppColors.separator(context),
          ),
        ...actions.map(
          (action) => ListTile(
            leading: action.icon != null
                ? Icon(
                    action.icon,
                    color: action.isDestructive
                        ? AppColors.error
                        : AppColors.accent,
                  )
                : null,
            title: Text(
              action.label,
              style: AppTypography.body(context).copyWith(
                color: action.isDestructive
                    ? AppColors.error
                    : AppColors.accent,
                fontWeight:
                    action.isDefault ? FontWeight.w600 : FontWeight.w400,
              ),
              textAlign: action.icon != null ? TextAlign.start : TextAlign.center,
            ),
            onTap: () {
              Navigator.of(context).pop();
              action.onPressed();
            },
          ),
        ),
        Container(
          height: 8,
          color: AppColors.separator(context),
        ),
        ListTile(
          title: Text(
            cancelLabel,
            style: AppTypography.body(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          onTap: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}
