import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lengoal/core/utils/extensions/context_extensions.dart';

class AppButton extends StatelessWidget {
  const new({
    required this.label,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.height,
    this.foregroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Widget? icon;
  final double? height;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final foreground =
        foregroundColor ??
        (isOutlined
            ? Theme.of(context).colorScheme.onSurface
            : Theme.of(context).colorScheme.onPrimary);

    final child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[icon!, const Gap(8)],
              Text(label),
            ],
          );

    final minimumSize = height == null ? null : Size.fromHeight(height!);

    final effectiveOnPressed = isLoading || onPressed == null
        ? null
        : () {
            context.unfocus();
            onPressed!();
          };

    if (isOutlined) {
      return OutlinedButton(
        style: OutlinedButton.styleFrom(
          minimumSize: minimumSize,
          foregroundColor: foregroundColor,
          side: foregroundColor == null
              ? null
              : BorderSide(color: foregroundColor!),
        ),
        onPressed: effectiveOnPressed,
        child: child,
      );
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: minimumSize,
        foregroundColor: foregroundColor,
      ),
      onPressed: effectiveOnPressed,
      child: child,
    );
  }
}
