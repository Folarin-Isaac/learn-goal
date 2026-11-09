import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lengoal/core/theme/app_colors.dart';
import 'package:lengoal/core/theme/app_spacing.dart';
import 'package:lengoal/core/utils/extensions/context_extensions.dart';
import 'package:lengoal/gen/assets.gen.dart';

class AppStatRow extends StatelessWidget {
  const new({required this.icon, required this.label, super.key});

  final SvgGenImage icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.tagBlueSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          ),
          child: icon.svg(width: 18, height: 18),
        ),
        const Gap(AppSpacing.s16),
        Expanded(child: Text(label, style: context.textTheme.bodyLarge)),
      ],
    );
  }
}
