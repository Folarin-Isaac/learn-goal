import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lengoal/core/theme/app_colors.dart';
import 'package:lengoal/core/theme/app_spacing.dart';
import 'package:lengoal/core/utils/extensions/context_extensions.dart';

class AppConfirmDialog extends StatelessWidget {
  const new({
    required this.title,
    required this.body,
    required this.cancelLabel,
    required this.confirmLabel,
    super.key,
    this.warning,
    this.bodyColor,
    this.confirmColor,
  });

  final String title;
  final String body;
  final String cancelLabel;
  final String confirmLabel;
  final String? warning;
  final Color? bodyColor;
  final Color? confirmColor;

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String body,
    required String cancelLabel,
    required String confirmLabel,
    String? warning,
    Color? bodyColor,
    Color? confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AppConfirmDialog(
        title: title,
        body: body,
        cancelLabel: cancelLabel,
        confirmLabel: confirmLabel,
        warning: warning,
        bodyColor: bodyColor,
        confirmColor: confirmColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.r8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title, style: context.textTheme.titleLarge),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const Gap(AppSpacing.s8),
            Text(
              body,
              style: context.textTheme.bodyMedium?.copyWith(color: bodyColor),
            ),
            if (warning != null) ...[
              const Gap(AppSpacing.s4),
              Text(
                warning!,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.errorRed,
                ),
              ),
            ],
            const Gap(AppSpacing.s24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.errorRed,
                      side: const BorderSide(color: AppColors.errorRed),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.r4),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(cancelLabel),
                  ),
                ),
                const Gap(AppSpacing.s8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.r4),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(confirmLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
