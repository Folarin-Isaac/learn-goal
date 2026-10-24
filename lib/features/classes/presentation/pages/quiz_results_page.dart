import 'dart:async';

import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/models/quiz_question.dart';
import 'package:lengoal/features/classes/presentation/models/quiz_session.dart';

class QuizResultsPage extends StatelessWidget {
  const new({required this.session, required this.answers, super.key});

  final QuizSession session;
  final Map<int, int> answers;

  int get _correctCount {
    var count = 0;
    for (var i = 0; i < session.questions.length; i++) {
      if (answers[i] == session.questions[i].correctOptionIndex) count++;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final scorePercent = (_correctCount / session.questions.length * 100)
        .round();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s24,
                AppSpacing.s24,
                AppSpacing.s24,
                0,
              ),
              child: Row(
                children: [
                  const AppBackButton(),
                  const Gap(AppSpacing.s8),
                  Expanded(
                    child: Text(
                      context.l10n.classDetailsTabQuiz,
                      style: context.textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.s24),
                children: [
                  _ScoreHero(scorePercent: scorePercent),
                  const Gap(AppSpacing.s16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatBox(
                          value: '82%',
                          label: context.l10n.quizResultsPercentileRank,
                        ),
                      ),
                      const Gap(AppSpacing.s8),
                      Expanded(
                        child: _StatBox(
                          value: '12',
                          label: context.l10n.quizResultsMockSolved,
                        ),
                      ),
                      const Gap(AppSpacing.s8),
                      Expanded(
                        child: _StatBox(
                          value: '45s',
                          label: context.l10n.quizResultsAvgTime,
                        ),
                      ),
                    ],
                  ),
                  const Gap(AppSpacing.s24),
                  for (var i = 0; i < session.questions.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
                      child: _QuestionResultRow(
                        index: i,
                        question: session.questions[i],
                        isCorrect:
                            answers[i] ==
                            session.questions[i].correctOptionIndex,
                        onReview: () {
                          AppHaptics.selection();
                          unawaited(
                            context.pushNamed(
                              RouteNames.quizReview,
                              extra: (
                                session: session,
                                answers: answers,
                                startIndex: i,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const Gap(AppSpacing.s8),
                  AppButton(
                    label: context.l10n.quizResultsReviewAll,
                    isOutlined: true,
                    onPressed: () {
                      AppHaptics.selection();
                      unawaited(
                        context.pushNamed(
                          RouteNames.quizReview,
                          extra: (
                            session: session,
                            answers: answers,
                            startIndex: 0,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreHero extends StatelessWidget {
  const new({required this.scorePercent});

  final int scorePercent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: context.colors.primary,
        borderRadius: BorderRadius.circular(AppSpacing.r16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              context.l10n.quizResultsAverageScore,
              style: context.textTheme.bodyLarge?.copyWith(color: Colors.white),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: AppSpacing.s8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            ),
            child: Text(
              '$scorePercent%',
              style: context.textTheme.titleLarge?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const new({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s8),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.r12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: context.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _QuestionResultRow extends StatelessWidget {
  const new({
    required this.index,
    required this.question,
    required this.isCorrect,
    required this.onReview,
  });

  final int index;
  final QuizQuestion question;
  final bool isCorrect;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? const Color(0xFF0E8C43) : Colors.red;
    final label = isCorrect
        ? context.l10n.quizResultsCorrect
        : context.l10n.quizResultsIncorrect;

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.r12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${index + 1}. ${question.text}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyMedium,
              ),
            ),
            const Gap(AppSpacing.s8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: color),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCorrect ? Icons.check_rounded : Icons.close_rounded,
                        size: 14,
                        color: color,
                      ),
                      const Gap(4),
                      Text(
                        label,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(4),
                Pressable(
                  child: InkWell(
                    onTap: onReview,
                    child: Text(
                      context.l10n.quizResultsReview,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
