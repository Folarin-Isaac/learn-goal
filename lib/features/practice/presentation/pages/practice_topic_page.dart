import 'dart:async';

import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/practice/presentation/models/practice_stats.dart';
import 'package:lengoal/features/practice/presentation/models/practice_subject.dart';
import 'package:lengoal/features/practice/presentation/widgets/practice_result_card.dart';
import 'package:lengoal/features/practice/presentation/widgets/practice_stats_card.dart';

class PracticeTopicPage extends StatelessWidget {
  const new({required this.topic, super.key});

  final PracticeTopic topic;

  bool get _hasAttempt => topic.status != PracticeTopicStatus.notStarted;

  void _startSession(BuildContext context) {
    AppHaptics.selection();
    unawaited(context.pushNamed(RouteNames.practiceSession, extra: topic));
  }

  void _review(BuildContext context, int startIndex) {
    AppHaptics.selection();
    unawaited(
      context.pushNamed(
        RouteNames.practiceReview,
        extra: (topic: topic, startIndex: startIndex),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                        topic.title,
                        style: context.textTheme.headlineSmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _hasAttempt
                  ? _AttemptView(
                      topic: topic,
                      onReview: (index) => _review(context, index),
                    )
                  : _EmptyView(isMock: topic.isMock),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: AppButton(
                label: switch (topic.status) {
                  PracticeTopicStatus.notStarted =>
                    context.l10n.practiceStartNow,
                  PracticeTopicStatus.inProgress =>
                    context.l10n.practiceContinueAttempt,
                  PracticeTopicStatus.completed =>
                    context.l10n.practiceReviewAll,
                },
                onPressed: () => topic.status == PracticeTopicStatus.completed
                    ? _review(context, 0)
                    : _startSession(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttemptView extends StatelessWidget {
  const new({required this.topic, required this.onReview});

  final PracticeTopic topic;
  final ValueChanged<int> onReview;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s16,
        AppSpacing.s16,
        0,
      ),
      children: [
        Entrance(
          child: PracticeStatsCard(
            stats: mockPracticeStats,
            isMock: topic.isMock,
          ),
        ),
        const Gap(AppSpacing.s16),
        for (var i = 0; i < topic.questions.length; i++) ...[
          Entrance(
            index: i + 1,
            child: PracticeResultCard(
              index: i,
              question: topic.questions[i],
              selectedOption: topic.answers[i],
              onReview: () => onReview(i),
            ),
          ),
          const Gap(AppSpacing.s16),
        ],
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  const new({required this.isMock});

  final bool isMock;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.s16),
      children: [
        Entrance(
          child: PracticeStatsCard(stats: mockPracticeStats, isMock: isMock),
        ),
        const Gap(AppSpacing.s48),
        Entrance(
          index: 1,
          child: Center(
            child: Assets.images.practiceEmptyIllustration.svg(
              width: 140,
              height: 140,
            ),
          ),
        ),
        const Gap(AppSpacing.s24),
        Entrance(
          index: 2,
          child: Text(
            context.l10n.practiceEmptyMessage,
            textAlign: TextAlign.center,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
