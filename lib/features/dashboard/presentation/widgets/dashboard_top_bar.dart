import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/goal_setup/presentation/bloc/active_goal/active_goal_cubit.dart';

class DashboardTopBar extends StatelessWidget {
  const new({required this.firstName, super.key, this.avatarUrl});

  final String? firstName;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: _GoalSwitcherButton(),
          ),
        ),
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
  const new();

  @override
  Widget build(BuildContext context) {
    final cubit = getIt<ActiveGoalCubit>();
    return BlocBuilder<ActiveGoalCubit, ActiveGoalState>(
      bloc: cubit,
      builder: (context, state) {
        final active = state.activeGoal;
        final isLoading =
            active == null &&
            (state.status == ActiveGoalStatus.initial ||
                state.status == ActiveGoalStatus.loading);
        final label =
            active?.goalName ??
            (state.status == ActiveGoalStatus.failure
                ? context.l10n.dashboardGoalsRetry
                : context.l10n.dashboardSetGoal);

        return Builder(
          builder: (buttonContext) => GestureDetector(
            onTap: isLoading
                ? null
                : () {
                    if (active != null) {
                      unawaited(_openMenu(buttonContext, cubit, state));
                    } else if (state.status == ActiveGoalStatus.failure) {
                      AppHaptics.selection();
                      unawaited(cubit.load());
                    } else {
                      unawaited(_createGoal(buttonContext, cubit));
                    }
                  },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s16,
                vertical: AppSpacing.s8,
              ),
              decoration: BoxDecoration(
                color: buttonContext.colors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              ),
              child: isLoading
                  ? const Shimmer(child: SkeletonBox(width: 96))
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: buttonContext.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Gap(AppSpacing.s4),
                        Icon(
                          active != null
                              ? Icons.keyboard_arrow_down
                              : state.status == ActiveGoalStatus.failure
                              ? Icons.refresh
                              : Icons.add,
                          size: 18,
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _createGoal(BuildContext context, ActiveGoalCubit cubit) async {
    AppHaptics.selection();
    await context.pushNamed(RouteNames.goalCategory);
    await cubit.load();
  }

  Future<void> _openMenu(
    BuildContext context,
    ActiveGoalCubit cubit,
    ActiveGoalState state,
  ) async {
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
    final activeId = state.activeGoal?.id;
    final selected = await showMenu<String>(
      context: context,
      position: position,
      color: context.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.r16),
      ),
      constraints: const BoxConstraints(minWidth: 220),
      items: [
        for (final goal in state.goals)
          PopupMenuItem(
            value: goal.id,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    goal.goalName,
                    style: context.textTheme.bodyLarge,
                  ),
                ),
                if (goal.id == activeId)
                  Icon(Icons.check, size: 18, color: context.colors.primary),
              ],
            ),
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

    if (selected == null || !context.mounted) return;
    if (selected == createNewGoal) {
      await _createGoal(context, cubit);
      return;
    }
    final goal = state.goals.where((g) => g.id == selected).firstOrNull;
    if (goal != null) {
      AppHaptics.selection();
      await cubit.select(goal);
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
        backgroundImage: hasAvatar
            ? CachedNetworkImageProvider(widget.avatarUrl!)
            : null,
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
