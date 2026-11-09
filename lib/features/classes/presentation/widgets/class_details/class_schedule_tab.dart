import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/bloc/class_detail/class_detail_bloc.dart';
import 'package:lengoal/features/dashboard/presentation/models/calendar_session.dart';
import 'package:lengoal/features/dashboard/presentation/widgets/calendar_session_card.dart';

class ClassScheduleTab extends StatelessWidget {
  const new({required this.sessions, required this.loadingReplayId, super.key});

  final List<CalendarSession> sessions;
  final String? loadingReplayId;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return Center(
        child: Text(
          context.l10n.classDetailsScheduleEmpty,
          style: context.textTheme.bodyMedium,
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.s24),
      itemCount: sessions.length,
      separatorBuilder: (context, index) => const Gap(AppSpacing.s16),
      itemBuilder: (context, index) {
        final session = sessions[index];
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
