import 'package:flutter/material.dart';
import 'package:lengoal/core/theme/app_colors.dart';
import 'package:lengoal/core/theme/app_spacing.dart';
import 'package:lengoal/core/theme/app_text_styles.dart';

class AppTabBar extends StatelessWidget implements PreferredSizeWidget {
  const new({
    required this.labels,
    super.key,
    this.controller,
    this.isScrollable = false,
  });

  final List<String> labels;
  final TabController? controller;
  final bool isScrollable;

  static const double _height = 46;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      isScrollable: isScrollable,
      tabAlignment: isScrollable ? TabAlignment.start : TabAlignment.fill,
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorColor: AppColors.accentBlue,
      dividerColor: AppColors.borderGray200,
      dividerHeight: AppSpacing.s1,
      labelColor: AppColors.accentBlue,
      unselectedLabelColor: AppColors.borderGray200,
      labelStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
      unselectedLabelStyle: AppTextStyles.body,
      labelPadding: EdgeInsets.symmetric(
        horizontal: isScrollable ? AppSpacing.s16 : AppSpacing.s4,
      ),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      splashFactory: NoSplash.splashFactory,
      tabs: [
        for (final label in labels)
          Tab(
            height: _height - AppSpacing.s2,
            child: isScrollable
                ? Text(label, maxLines: 1)
                : FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(label, maxLines: 1),
                  ),
          ),
      ],
    );
  }
}
