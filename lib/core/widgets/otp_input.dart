import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lengoal/core/constants/app_constants.dart';
import 'package:lengoal/core/theme/app_colors.dart';

class OtpInput extends StatelessWidget {
  const new({
    required this.value,
    super.key,
    this.length = AppConstants.otpLength,
  });

  final String value;
  final int length;

  static const double _maxBoxSize = 56;
  static const double _gap = 8;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final rawSize = (constraints.maxWidth - _gap * (length - 1)) / length;
        final boxSize = rawSize.clamp(0.0, _maxBoxSize);

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var index = 0; index < length; index++) ...[
              if (index > 0) const Gap(_gap),
              _OtpBox(
                digit: index < value.length ? value[index] : null,
                size: boxSize,
                colorScheme: colorScheme,
                isDark: isDark,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _OtpBox extends StatelessWidget {
  const new({
    required this.digit,
    required this.size,
    required this.colorScheme,
    required this.isDark,
  });

  final String? digit;
  final double size;
  final ColorScheme colorScheme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final filled = digit != null;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        filled ? digit! : '—',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: filled ? FontWeight.w700 : FontWeight.w400,
          fontSize: filled ? 24 : 18,
          color: filled
              ? AppColors.brandPrimary
              : colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
