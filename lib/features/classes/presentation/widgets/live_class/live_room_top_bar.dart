import 'package:lengoal/core/core.dart';

class LiveRoomTopBar extends StatelessWidget {
  const new({
    required this.topic,
    required this.isRecording,
    required this.participantCount,
    required this.onLeave,
    super.key,
  });

  final String topic;
  final bool isRecording;
  final int participantCount;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final style = OutlinedButton.styleFrom(
      foregroundColor: AppColors.errorBorder,
      side: const BorderSide(color: AppColors.errorRed),
      visualDensity: VisualDensity.compact,
      minimumSize: const Size(0, 36),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.r8),
      ),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s8,
        AppSpacing.s8,
        AppSpacing.s16,
        AppSpacing.s8,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < _fullWidth * scale;
          final leave = compact
              ? Tooltip(
                  message: l10n.liveClassLeave,
                  child: OutlinedButton(
                    onPressed: onLeave,
                    style: style.copyWith(
                      padding: const WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: AppSpacing.s8),
                      ),
                    ),
                    child: Semantics(
                      label: l10n.liveClassLeave,
                      child: const Icon(Icons.logout, size: 18),
                    ),
                  ),
                )
              : OutlinedButton.icon(
                  onPressed: onLeave,
                  icon: const Icon(Icons.logout, size: 16),
                  label: Text(l10n.liveClassLeave),
                  style: style,
                );
          return _row(context, leave);
        },
      ),
    );
  }

  static const double _fullWidth = 360;

  Widget _row(BuildContext context, Widget leave) {
    final l10n = context.l10n;
    return Row(
      children: [
        leave,
        const Gap(AppSpacing.s16),
        Expanded(
          child: Text(
            topic,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.titleSmall?.copyWith(color: Colors.white),
          ),
        ),
        if (isRecording) ...[
          const Gap(AppSpacing.s8),
          Semantics(
            label: l10n.liveClassRecordingNotice,
            excludeSemantics: true,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s8,
                vertical: AppSpacing.s2,
              ),
              decoration: BoxDecoration(
                color: AppColors.errorRed,
                borderRadius: BorderRadius.circular(AppSpacing.r4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.fiber_manual_record,
                    size: 10,
                    color: Colors.white,
                  ),
                  const Gap(AppSpacing.s4),
                  Text(
                    l10n.liveClassRec,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const Gap(AppSpacing.s8),
        Semantics(
          label: l10n.liveClassInClass(participantCount),
          excludeSemantics: true,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.people_alt_outlined,
                size: 16,
                color: Colors.white70,
              ),
              const Gap(AppSpacing.s4),
              Text(
                '$participantCount',
                style: context.textTheme.labelMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
