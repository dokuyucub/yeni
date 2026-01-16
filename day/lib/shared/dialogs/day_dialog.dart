import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../widgets/day_button.dart';

/// Shows a custom dialog following Apple design guidelines
Future<T?> showDayDialog<T>({
  required BuildContext context,
  required String title,
  String? message,
  String? confirmLabel,
  String? cancelLabel,
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
  bool isDestructive = false,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => DayAlertDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel ?? 'OK',
      cancelLabel: cancelLabel,
      onConfirm: onConfirm,
      onCancel: onCancel,
      isDestructive: isDestructive,
    ),
  );
}

/// Custom alert dialog following Apple design guidelines
class DayAlertDialog extends StatelessWidget {
  final String title;
  final String? message;
  final String confirmLabel;
  final String? cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;

  const DayAlertDialog({
    super.key,
    required this.title,
    this.message,
    required this.confirmLabel,
    this.cancelLabel,
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: AppTypography.title3(context),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(
                message!,
                style: AppTypography.body(context).copyWith(
                  color: AppColors.labelSecondary(context),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            if (cancelLabel != null)
              Row(
                children: [
                  Expanded(
                    child: DayButton(
                      label: cancelLabel!,
                      onPressed: () {
                        Navigator.of(context).pop();
                        onCancel?.call();
                      },
                      variant: DayButtonVariant.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DayButton(
                      label: confirmLabel,
                      onPressed: () {
                        Navigator.of(context).pop();
                        onConfirm?.call();
                      },
                      variant: isDestructive
                          ? DayButtonVariant.destructive
                          : DayButtonVariant.primary,
                    ),
                  ),
                ],
              )
            else
              DayButton(
                label: confirmLabel,
                onPressed: () {
                  Navigator.of(context).pop();
                  onConfirm?.call();
                },
                isExpanded: true,
                variant: isDestructive
                    ? DayButtonVariant.destructive
                    : DayButtonVariant.primary,
              ),
          ],
        ),
      ),
    );
  }
}

/// Shows a confirmation dialog and returns true if confirmed, false otherwise
Future<bool> showDayConfirmDialog({
  required BuildContext context,
  required String title,
  String? message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool isDestructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (context) => DayAlertDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      onConfirm: () => Navigator.of(context).pop(true),
      onCancel: () => Navigator.of(context).pop(false),
      isDestructive: isDestructive,
    ),
  );

  return result ?? false;
}
