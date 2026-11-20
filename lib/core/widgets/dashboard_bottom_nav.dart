import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lengoal/core/router/route_names.dart';
import 'package:lengoal/core/theme/app_colors.dart';
import 'package:lengoal/core/theme/app_spacing.dart';
import 'package:lengoal/core/utils/extensions/context_extensions.dart';
import 'package:lengoal/core/utils/haptics.dart';
import 'package:lengoal/core/widgets/app_snackbar.dart';
import 'package:lengoal/core/widgets/nav_badges.dart';
import 'package:lengoal/gen/assets.gen.dart';
import 'package:lengoal/l10n/l10n.dart';

class _NavItem {
  const new(this.icon, this.label);

  final SvgGenImage icon;
  final String Function(BuildContext context) label;
}

final _items = [
  _NavItem(
    Assets.icons.exploreIcon,
    (context) => context.l10n.dashboardNavExplore,
  ),
  _NavItem(
    Assets.icons.dashboardIcon,
    (context) => context.l10n.dashboardNavDashboard,
  ),
  _NavItem(
    Assets.icons.classesIcon,
    (context) => context.l10n.dashboardNavClasses,
  ),
  // _NavItem(
  //   Assets.icons.practiceIcon,
  //   (context) => context.l10n.dashboardNavPractice,
  // ),
  // _NavItem(
  //   Assets.icons.communityIcon,
  //   (context) => context.l10n.dashboardNavCommunity,
  // ),
  _NavItem(Assets.icons.chatsIcon, (context) => context.l10n.dashboardNavChats),
];

class DashboardBottomNav extends StatelessWidget {
  const new({this.currentIndex = 0, this.onSelect, super.key});

  final int currentIndex;
  final ValueChanged<int>? onSelect;

  static const int _chatsIndex = 3;

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
                badge: i == _chatsIndex ? NavBadges.chats : null,
                onTap: i == currentIndex
                    ? null
                    : onSelect != null
                    ? () => onSelect!(i)
                    : switch (i) {
                        0 => () => context.goNamed(RouteNames.explore),
                        1 => () => context.goNamed(RouteNames.dashboard),
                        2 => () => context.goNamed(RouteNames.classesHub),
                        // 3 => () => context.goNamed(RouteNames.practice),
                        // 4 => () => context.goNamed(RouteNames.community),
                        3 => () => context.goNamed(RouteNames.chats),
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
  const new({
    required this.item,
    required this.isActive,
    this.onTap,
    this.badge,
  });

  final _NavItem item;
  final bool isActive;
  final VoidCallback? onTap;
  final ValueListenable<int>? badge;

  Widget _withBadge(Widget icon) {
    final listenable = badge;
    if (listenable == null) return icon;
    return ValueListenableBuilder<int>(
      valueListenable: listenable,
      builder: (context, count, _) {
        if (count <= 0) return icon;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            icon,
            Positioned(
              top: -6,
              right: -10,
              child: Container(
                constraints: const BoxConstraints(minWidth: 16),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: AppColors.errorRed,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  border: Border.all(color: AppColors.brandPrimary, width: 1.5),
                ),
                child: Text(
                  count > 9 ? '9+' : '$count',
                  textAlign: TextAlign.center,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

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
              _withBadge(
                item.icon.svg(
                  width: 22,
                  height: 22,
                  colorFilter: ColorFilter.mode(
                    isActive ? Colors.white : Colors.white70,
                    BlendMode.srcIn,
                  ),
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
