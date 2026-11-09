import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/domain/entities/class_attendance.dart';
import 'package:lengoal/features/classes/presentation/bloc/class_detail/class_detail_bloc.dart';
import 'package:lengoal/features/dashboard/presentation/models/calendar_session.dart';
import 'package:lengoal/features/dashboard/presentation/widgets/calendar_session_card.dart';

class ClassScheduleTab extends StatelessWidget {
  const new({
    required this.sessions,
    required this.loadingReplayId,
    this.attendance,
    super.key,
  });

  final List<CalendarSession> sessions;
  final String? loadingReplayId;
  final ClassAttendance? attendance;

  @override
  Widget build(BuildContext context) {
    final summary = attendance;
    final showSummary = summary != null && summary.totalSessions > 0;
    if (sessions.isEmpty && !showSummary) {
      return Center(
        child: Text(
          context.l10n.classDetailsScheduleEmpty,
          style: context.textTheme.bodyMedium,
        ),
      );
    }
    final leading = showSummary ? 1 : 0;
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.s24),
      itemCount: sessions.length + leading,
      separatorBuilder: (context, index) => const Gap(AppSpacing.s16),
      itemBuilder: (context, index) {
        if (showSummary && index == 0) {
          return _AttendanceSummary(attendance: summary);
        }
        final session = sessions[index - leading];
        final sessionId = session.id;
        if (session.hasReplay && sessionId != null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CalendarSessionCard(session: session),
              const Gap(AppSpacing.s16),
              AppButton(
                label: context.l10n.classDetailsWatchReplay,
                icon: const Icon(Icons.play_circle_outline, size: 18),
                isOutlined: true,
                isLoading: loadingReplayId == sessionId,
                onPressed: () {
                  AppHaptics.selection();
                  context.read<ClassDetailBloc>().add(
                    ClassDetailReplayRequested(sessionId),
                  );
                },
              ),
            ],
          );
        }
        if (session.status != CalendarSessionStatus.ongoing) {
          return CalendarSessionCard(session: session);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CalendarSessionCard(session: session),
            const Gap(AppSpacing.s16),
            AppButton(
              label: context.l10n.classDetailsJoinUpcoming,
              onPressed: () {
                AppHaptics.selection();
                AppSnackbar.info(context.l10n.dashboardComingSoon);
              },
            ),
          ],
        );
      },
    );
  }
}

class _AttendanceSummary extends StatelessWidget {
  const new({required this.attendance});

  final ClassAttendance attendance;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.r16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.classDetailsAttendanceTitle,
                  style: context.textTheme.titleMedium,
                ),
              ),
              Text(
                context.l10n.classDetailsAttendancePercent(attendance.percent),
                style: context.textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.s8),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            child: LinearProgressIndicator(
              value: attendance.fraction,
              minHeight: 6,
              backgroundColor: colorScheme.outlineVariant.withValues(
                alpha: 0.4,
              ),
              valueColor: AlwaysStoppedAnimation(colorScheme.primary),
            ),
          ),
          const Gap(AppSpacing.s8),
          Text(
            context.l10n.classDetailsAttendanceSummary(
              attendance.attendedSessions,
              attendance.totalSessions,
            ),
            style: context.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
