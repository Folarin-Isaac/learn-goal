import 'dart:async';

import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/domain/entities/lengoal_class.dart';
import 'package:lengoal/features/classes/presentation/bloc/class_detail/class_detail_bloc.dart';
import 'package:lengoal/features/classes/presentation/models/live_class_session.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_details/class_details_tab_scroll.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_details/class_enroll_hint.dart';
import 'package:lengoal/features/dashboard/presentation/models/calendar_session.dart';
import 'package:lengoal/features/dashboard/presentation/widgets/calendar_session_card.dart';

class ClassScheduleTab extends StatelessWidget {
  const new({
    required this.lengoalClass,
    required this.sessions,
    required this.loadingReplayId,
    required this.isSubscribed,
    super.key,
  });

  final LengoalClass lengoalClass;
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
              if (index < offset) {
                return ClassEnrollHint(
                  message: context.l10n.classDetailsScheduleEnrollHint,
                );
              }
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
                    label: context.l10n.classDetailsJoinOngoing,
                    icon: const Icon(Icons.videocam_outlined, size: 18),
                    onPressed: sessionId == null
                        ? null
                        : () {
                            AppHaptics.selection();
                            unawaited(
                              context.pushNamed(
                                RouteNames.liveClass,
                                extra: LiveClassSession(
                                  sessionId: sessionId,
                                  topic: session.title,
                                  className: lengoalClass.cohortName,
                                  timeLabel:
                                      '${session.dateLabel}, '
                                      '${session.timeRange}',
                                  educatorId: lengoalClass.educatorId,
                                  educatorName: lengoalClass.educatorName,
                                ),
                              ),
                            );
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
