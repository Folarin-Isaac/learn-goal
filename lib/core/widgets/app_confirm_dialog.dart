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
            LayoutBuilder(
              builder: (context, constraints) {
                final cancel = OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.errorRed,
                    side: const BorderSide(color: AppColors.errorRed),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.r4),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(cancelLabel, textAlign: TextAlign.center),
                );
                final confirm = ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: confirmColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.r4),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(confirmLabel, textAlign: TextAlign.center),
                );
                const gap = AppSpacing.s8;
                final half = (constraints.maxWidth - gap) / 2;
                final fitsSideBySide = [
                  cancelLabel,
                  confirmLabel,
                ].every((label) => _labelWidth(context, label) <= half);
                if (fitsSideBySide) {
                  return Row(
                    children: [
                      Expanded(child: cancel),
                      const Gap(gap),
                      Expanded(child: confirm),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [confirm, const Gap(gap), cancel],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static const double _buttonPadding = 2 * AppSpacing.s24 + 2;

  double _labelWidth(BuildContext context, String label) {
    final theme = Theme.of(context);
    final style =
        theme.elevatedButtonTheme.style?.textStyle?.resolve({}) ??
        theme.textTheme.labelLarge;
    final painter = TextPainter(
      text: TextSpan(text: label, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final width = painter.width + _buttonPadding;
    painter.dispose();
    return width;
  }
}
