import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lengoal/core/theme/app_spacing.dart';
import 'package:lengoal/core/widgets/app_button.dart';

class ErrorView extends StatelessWidget {
  const new({required this.message, super.key, this.onRetry, this.retryLabel});

  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40),
            const Gap(AppSpacing.s8),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null && retryLabel != null) ...[
              const Gap(AppSpacing.s16),
              AppButton(label: retryLabel!, onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}
