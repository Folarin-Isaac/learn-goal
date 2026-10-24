import 'dart:async';

import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/models/class_quiz.dart';
import 'package:lengoal/features/classes/presentation/models/quiz_session.dart';

Map<int, int> _mockCompletedAnswers(QuizSession session) {
  return {
    for (var i = 0; i < session.questions.length; i++)
      i: i == 1
          ? (session.questions[i].correctOptionIndex + 1) %
                session.questions[i].options.length
          : session.questions[i].correctOptionIndex,
  };
}

class ClassQuizCard extends StatelessWidget {
  const new({required this.quiz, super.key});

  final ClassQuiz quiz;

  @override
  Widget build(BuildContext context) {
    final isCompleted = quiz.status == QuizStatus.completed;

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.r16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    quiz.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Gap(AppSpacing.s8),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF34C759),
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusPill,
                      ),
                    ),
                    child: Text(
                      context.l10n.classDetailsQuizCompleted,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const Gap(AppSpacing.s4),
            Text(
              context.l10n.classDetailsQuizDue(quiz.dueDate),
              style: context.textTheme.bodySmall,
            ),
            const Gap(AppSpacing.s8),
            Row(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: context.colors.primary,
                  foregroundColor: Colors.white,
                  child: Text(
                    quiz.instructorName[0],
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Gap(6),
                Expanded(
                  child: Text(
                    context.l10n.classDetailsQuizBy(quiz.instructorName),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const Gap(AppSpacing.s16),
            AppButton(
              label: isCompleted
                  ? context.l10n.classDetailsReviewQuiz
                  : context.l10n.quizStartQuiz,
              onPressed: () {
                AppHaptics.selection();
                if (isCompleted) {
                  unawaited(
                    context.pushNamed(
                      RouteNames.quizResults,
                      extra: (
                        session: quiz.session,
                        answers: _mockCompletedAnswers(quiz.session),
                      ),
                    ),
                  );
                } else {
                  unawaited(
                    context.pushNamed(RouteNames.quizIntro, extra: quiz),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
