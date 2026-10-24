import 'dart:async';

import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/practice/presentation/models/practice_mock.dart';
import 'package:lengoal/features/practice/presentation/models/practice_stats.dart';
import 'package:lengoal/features/practice/presentation/models/practice_subject.dart';
import 'package:lengoal/features/practice/presentation/widgets/practice_exam_button.dart';
import 'package:lengoal/features/practice/presentation/widgets/practice_stats_card.dart';
import 'package:lengoal/features/practice/presentation/widgets/practice_subject_card.dart';

class PracticeMockDetailPage extends StatefulWidget {
  const new({required this.mock, super.key});

  final PracticeMock mock;

  @override
  State<PracticeMockDetailPage> createState() => _PracticeMockDetailPageState();
}

class _PracticeMockDetailPageState extends State<PracticeMockDetailPage> {
  int? _expandedIndex = 0;

  void _openSession(PracticeMockSession session) {
    if (session.isCompleted) {
      unawaited(
        context.pushNamed(RouteNames.practiceTopic, extra: session.toTopic()),
      );
      return;
    }
    unawaited(
      context.pushNamed(
        RouteNames.practiceMockIntro,
        extra: (mock: widget.mock, topic: session.toTopic()),
      ),
    );
  }

  void _openSubject(PracticeSubject subject) {
    unawaited(
      context.pushNamed(
        RouteNames.practiceMockIntro,
        extra: (mock: widget.mock, topic: subject.topics.first),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mock = widget.mock;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: context.colors.surface,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s16,
                AppSpacing.s8,
                AppSpacing.s24,
                AppSpacing.s16,
              ),
              child: Entrance(
                child: Row(
                  children: [
                    const AppBackButton(),
                    const Gap(AppSpacing.s8),
                    Expanded(
                      child: Text(
                        mock.label,
                        style: context.textTheme.headlineSmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.s16),
                children: [
                  const Entrance(
                    child: PracticeStatsCard(
                      stats: mockPracticeStats,
                      isMock: true,
                    ),
                  ),
                  const Gap(AppSpacing.s16),
                  if (mock.sessions.isNotEmpty)
                    Entrance(
                      index: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          borderRadius: BorderRadius.circular(AppSpacing.r12),
                        ),
                        child: Column(
                          children: [
                            for (var i = 0; i < mock.sessions.length; i++) ...[
                              if (i != 0)
                                Divider(
                                  height: 1,
                                  color: context.colors.outlineVariant
                                      .withValues(alpha: 0.4),
                                ),
                              _SessionRow(
                                session: mock.sessions[i],
                                onTap: () => _openSession(mock.sessions[i]),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  for (var i = 0; i < mock.subjectGroups.length; i++) ...[
                    Entrance(
                      index: i + 1,
                      child: PracticeSubjectCard(
                        subject: mock.subjectGroups[i],
                        isExpanded: _expandedIndex == i,
                        onToggle: () => setState(
                          () => _expandedIndex = _expandedIndex == i ? null : i,
                        ),
                        onTopicTap: (topic) => unawaited(
                          context.pushNamed(
                            RouteNames.practiceMockIntro,
                            extra: (mock: mock, topic: topic),
                          ),
                        ),
                        trailing: PracticeExamButton(
                          isReview: false,
                          onPressed: () => _openSubject(mock.subjectGroups[i]),
                        ),
                      ),
                    ),
                    const Gap(AppSpacing.s16),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  const new({required this.session, required this.onTap});

  final PracticeMockSession session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.title, style: context.textTheme.bodyLarge),
                const Gap(AppSpacing.s2),
                Text(
                  context.l10n.practiceSolvedOf(
                    session.solvedCount,
                    session.totalCount,
                  ),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Gap(AppSpacing.s8),
          PracticeExamButton(isReview: session.isCompleted, onPressed: onTap),
        ],
      ),
    );
  }
}
