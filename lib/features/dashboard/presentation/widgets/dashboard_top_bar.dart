import 'dart:async';

import 'package:lengoal/core/core.dart';

const _mockGoals = ['GATE, ESE and IIT-JAM', 'CUET', 'Foreign Studies'];

class DashboardTopBar extends StatelessWidget {
  const new({required this.firstName, super.key, this.avatarUrl});

  final String? firstName;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(child: _GoalSwitcherButton(activeGoal: _mockGoals.first)),
        const Gap(AppSpacing.s8),
        IconButton(
          onPressed: () async {
            AppHaptics.selection();
            await context.pushNamed(RouteNames.calendar);
          },
          icon: Assets.icons.calendarIcon.svg(
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              context.colors.onSurface,
              BlendMode.srcIn,
            ),
          ),
        ),
        _ComingSoonIconButton(
          icon: Assets.icons.heartIcon.svg(
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              context.colors.onSurface,
              BlendMode.srcIn,
            ),
          ),
        ),
        const Gap(AppSpacing.s8),
        _Avatar(firstName: firstName, avatarUrl: avatarUrl),
      ],
    );
  }
}

class _GoalSwitcherButton extends StatelessWidget {
  const new({required this.activeGoal});

  final String activeGoal;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (buttonContext) {
        return GestureDetector(
          onTap: () => _openMenu(buttonContext),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: AppSpacing.s8,
            ),
            decoration: BoxDecoration(
              color: buttonContext.colors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    activeGoal,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: buttonContext.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Gap(AppSpacing.s4),
                const Icon(Icons.keyboard_arrow_down, size: 18),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openMenu(BuildContext context) async {
    AppHaptics.selection();
    final renderBox = context.findRenderObject()! as RenderBox;
    final overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    final topLeft = renderBox.localToGlobal(
      Offset(0, renderBox.size.height + 8),
      ancestor: overlay,
    );
    final bottomRight = renderBox.localToGlobal(
      renderBox.size.bottomRight(const Offset(0, 8)),
      ancestor: overlay,
    );
    final position = RelativeRect.fromRect(
      Rect.fromPoints(topLeft, bottomRight),
      Offset.zero & overlay.size,
    );

    const createNewGoal = '__create_new_goal__';
    final selected = await showMenu<String>(
      context: context,
      position: position,
      color: context.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.r16),
      ),
      constraints: const BoxConstraints(minWidth: 220),
      items: [
        for (final goal in _mockGoals)
          PopupMenuItem(
            value: goal,
            child: Text(goal, style: context.textTheme.bodyLarge),
          ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem(
          value: createNewGoal,
          child: Row(
            children: [
              Icon(Icons.add, size: 18, color: context.colors.primary),
              const Gap(AppSpacing.s8),
              Text(
                context.l10n.dashboardCreateNewGoal,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (selected == createNewGoal && context.mounted) {
      AppHaptics.selection();
      await context.pushNamed(RouteNames.goalCategory);
    }
  }
}

class _ComingSoonIconButton extends StatelessWidget {
  const new({required this.icon});

  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        AppHaptics.selection();
        AppSnackbar.info(context.l10n.dashboardComingSoon);
      },
      icon: icon,
    );
  }
}

class _Avatar extends StatefulWidget {
  const new({required this.firstName, this.avatarUrl});

  final String? firstName;
  final String? avatarUrl;

  @override
  State<_Avatar> createState() => _AvatarState();
}

class _AvatarState extends State<_Avatar> {
  bool _imageFailed = false;

  @override
  void didUpdateWidget(covariant _Avatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.avatarUrl != widget.avatarUrl) {
      _imageFailed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final initial = (widget.firstName == null || widget.firstName!.isEmpty)
        ? '?'
        : widget.firstName![0].toUpperCase();
    final hasAvatar =
        !_imageFailed &&
        widget.avatarUrl != null &&
        widget.avatarUrl!.isNotEmpty;

    return GestureDetector(
      onTap: () {
        AppHaptics.selection();
        unawaited(context.pushNamed(RouteNames.profile));
      },
      child: CircleAvatar(
        radius: 18,
        backgroundColor: context.colors.primary,
        foregroundColor: Colors.white,
        backgroundImage: hasAvatar ? NetworkImage(widget.avatarUrl!) : null,
        onBackgroundImageError: hasAvatar
            ? (error, stackTrace) {
                if (mounted) setState(() => _imageFailed = true);
              }
            : null,
        child: hasAvatar
            ? null
            : Text(
                initial,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
      ),
    );
  }
}
