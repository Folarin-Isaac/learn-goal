import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/bloc/class_detail/class_detail_bloc.dart';

class ReplayBadgePill extends StatelessWidget {
  const new({required this.badge, this.onRetry, super.key});

  final ReplayBadge badge;
  final VoidCallback? onRetry;

  static const double _minTapHeight = 44;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (String label, Color accent, Widget lead) = switch (badge) {
      ReplayBadge.live => (
        l10n.replayBadgeLive,
        AppColors.badgeLive,
        const _PulsingDot(color: AppColors.badgeLive),
      ),
      ReplayBadge.loading => (
        l10n.replayBadgeLoading,
        AppColors.badgePending,
        const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: Colors.white,
          ),
        ),
      ),
      ReplayBadge.processing => (
        l10n.replayBadgeProcessing,
        AppColors.badgePending,
        const _PulsingDot(color: AppColors.badgePending),
      ),
      ReplayBadge.notHeld => (
        l10n.replayBadgeNotHeld,
        AppColors.badgeMuted,
        const _Dot(color: AppColors.badgeMuted),
      ),
      ReplayBadge.failed || ReplayBadge.none => (
        l10n.replayBadgeFailed,
        AppColors.badgeError,
        const Icon(Icons.refresh_rounded, size: 14, color: Colors.white),
      ),
    };

    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.badgeScrim,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          lead,
          const Gap(AppSpacing.s8),
          Flexible(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: badge == ReplayBadge.live
                    ? FontWeight.w600
                    : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );

    final retry = onRetry;
    if (badge != ReplayBadge.failed || retry == null) {
      return Semantics(liveRegion: true, child: pill);
    }
    return Semantics(
      button: true,
      child: Pressable(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: retry,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: _minTapHeight),
            child: Align(
              alignment: Alignment.centerLeft,
              widthFactor: 1,
              heightFactor: 1,
              child: pill,
            ),
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const new({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const new({required this.color});

  final Color color;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
    lowerBound: 0.4,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _controller
        ..stop()
        ..value = 1;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: _Dot(color: widget.color),
    );
  }
}
