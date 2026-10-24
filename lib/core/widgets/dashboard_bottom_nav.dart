import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lengoal/core/router/route_names.dart';
import 'package:lengoal/core/theme/app_colors.dart';
import 'package:lengoal/core/theme/app_spacing.dart';
import 'package:lengoal/core/utils/extensions/context_extensions.dart';
import 'package:lengoal/core/utils/haptics.dart';
import 'package:lengoal/core/widgets/app_snackbar.dart';
import 'package:lengoal/gen/assets.gen.dart';
import 'package:lengoal/l10n/l10n.dart';

class _NavItem {
  const new(this.icon, this.label);

  final SvgGenImage icon;
  final String Function(BuildContext context) label;
}

final _items = [
  _NavItem(
    Assets.icons.dashboardIcon,
    (context) => context.l10n.dashboardNavDashboard,
  ),
  _NavItem(
    Assets.icons.classesIcon,
    (context) => context.l10n.dashboardNavClasses,
  ),
  _NavItem(
    Assets.icons.practiceIcon,
    (context) => context.l10n.dashboardNavPractice,
  ),
  _NavItem(
    Assets.icons.communityIcon,
    (context) => context.l10n.dashboardNavCommunity,
  ),
  _NavItem(Assets.icons.chatsIcon, (context) => context.l10n.dashboardNavChats),
];

class DashboardBottomNav extends StatelessWidget {
  const new({this.currentIndex = 0, super.key});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final systemInset = MediaQuery.paddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s8,
        AppSpacing.s8,
        AppSpacing.s8,
        AppSpacing.s8 + systemInset,
      ),
      decoration: const BoxDecoration(
        color: AppColors.brandPrimary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.r16),
          topRight: Radius.circular(AppSpacing.r16),
        ),
      ),
      child: Row(
        children: [
          for (var i = 0; i < _items.length; i++)
            Expanded(
              child: _NavTile(
                item: _items[i],
                isActive: i == currentIndex,
                onTap: i == currentIndex
                    ? null
                    : switch (i) {
                        0 => () => context.goNamed(RouteNames.dashboard),
                        1 => () => context.pushNamed(RouteNames.classesHub),
                        2 => () => context.pushNamed(RouteNames.practice),
                        3 => () => context.pushNamed(RouteNames.community),
                        4 => () => context.pushNamed(RouteNames.chats),
                        _ => null,
                      },
              ),
            ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const new({required this.item, required this.isActive, this.onTap});

  final _NavItem item;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppHaptics.selection();
        if (onTap != null) {
          onTap!();
        } else if (!isActive) {
          AppSnackbar.info(context.l10n.dashboardComingSoon);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s4,
          vertical: AppSpacing.s8,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.r12),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              item.icon.svg(
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(
                  isActive ? Colors.white : Colors.white70,
                  BlendMode.srcIn,
                ),
              ),
              const Gap(AppSpacing.s4),
              Text(
                item.label(context),
                style: context.textTheme.bodySmall?.copyWith(
                  color: isActive ? Colors.white : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
