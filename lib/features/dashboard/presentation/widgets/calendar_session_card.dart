import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/dashboard/presentation/models/calendar_session.dart';

class CalendarSessionCard extends StatelessWidget {
  const new({required this.session, super.key});

  final CalendarSession session;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      child: Card(
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.r16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.r16),
          onTap: () {
            AppHaptics.selection();
            AppSnackbar.info(context.l10n.dashboardComingSoon);
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        session.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Gap(AppSpacing.s8),
                    _StatusBadge(status: session.status),
                  ],
                ),
                const Gap(AppSpacing.s4),
                Text(
                  '${session.dateLabel}, ${session.timeRange}',
                  style: context.textTheme.bodySmall,
                ),
                if (session.meetingUrl.isNotEmpty) ...[
                  const Gap(AppSpacing.s4),
                  Row(
                    children: [
                      Assets.icons.linkIcon.svg(
                        width: 14,
                        height: 14,
                        colorFilter: ColorFilter.mode(
                          context.colors.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                      const Gap(4),
                      Expanded(
                        child: Text(
                          session.meetingUrl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (session.host case final host?) ...[
                  const Gap(AppSpacing.s4),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 8,
                        backgroundColor: context.colors.primary,
                        foregroundColor: Colors.white,
                        child: Text(
                          host[0],
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Gap(6),
                      Expanded(
                        child: Text(
                          host,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const new({required this.status});

  final CalendarSessionStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      CalendarSessionStatus.ongoing => (
        const Color(0xFF34C759),
        context.l10n.calendarStatusOngoing,
      ),
      CalendarSessionStatus.concluded => (
        const Color(0xFF2F6FE4),
        context.l10n.calendarStatusConcluded,
      ),
      CalendarSessionStatus.upcoming => (
        const Color(0xFFF2A93B),
        context.l10n.calendarStatusUpcoming,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(
        label,
        style: context.textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
