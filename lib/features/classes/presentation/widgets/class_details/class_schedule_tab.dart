import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/bloc/class_detail/class_detail_bloc.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_details/class_details_tab_scroll.dart';
import 'package:lengoal/features/dashboard/presentation/models/calendar_session.dart';
import 'package:lengoal/features/dashboard/presentation/widgets/calendar_session_card.dart';

class ClassScheduleTab extends StatelessWidget {
  const new({
    required this.sessions,
    required this.loadingReplayId,
    required this.isSubscribed,
    super.key,
  });

  final List<CalendarSession> sessions;
  final String? loadingReplayId;
  final bool isSubscribed;

  static const String _storageKey = 'classDetailsSchedule';

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return ClassDetailsTabScroll.empty(
        storageKey: _storageKey,
        message: context.l10n.classDetailsScheduleEmpty,
      );
    }
    final offset = isSubscribed ? 0 : 1;
    return ClassDetailsTabScroll(
      storageKey: _storageKey,
      slivers: [
        SliverPadding(
          padding: ClassDetailsTabScroll.padding,
          sliver: SliverList.separated(
            itemCount: sessions.length + offset,
            separatorBuilder: (context, index) => const Gap(AppSpacing.s16),
            itemBuilder: (context, index) {
              if (index < offset) return const _EnrollHint();
              final session = sessions[index - offset];
              if (!isSubscribed) {
                return IgnorePointer(
                  child: Opacity(
                    opacity: 0.5,
                    child: CalendarSessionCard(session: session),
                  ),
                );
              }
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
          ),
        ),
      ],
    );
  }
}

class _EnrollHint extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final muted = context.colors.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.r12),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline_rounded, size: 18, color: muted),
          const Gap(12),
          Expanded(
            child: Text(
              context.l10n.classDetailsScheduleEnrollHint,
              style: context.textTheme.bodyMedium?.copyWith(color: muted),
            ),
          ),
        ],
      ),
    );
  }
}
