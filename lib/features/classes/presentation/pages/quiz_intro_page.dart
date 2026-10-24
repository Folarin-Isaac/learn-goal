import 'dart:async';

import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/models/class_quiz.dart';

class QuizIntroPage extends StatelessWidget {
  const new({required this.quiz, super.key});

  final ClassQuiz quiz;

  @override
  Widget build(BuildContext context) {
    final session = quiz.session;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
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
              const Gap(AppSpacing.s24),
              Expanded(
                child: SingleChildScrollView(
                  child: Card(
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
                          Text(quiz.title, style: context.textTheme.titleLarge),
                          const Gap(AppSpacing.s16),
                          Text(
                            context.l10n.quizInstructionsHeading,
                            style: context.textTheme.bodyLarge,
                          ),
                          const Gap(AppSpacing.s8),
                          for (final instruction in session.instructions)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.s4,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '•  ',
                                    style: context.textTheme.bodyMedium,
                                  ),
                                  Expanded(
                                    child: Text(
                                      instruction,
                                      style: context.textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const Gap(AppSpacing.s16),
                          _StatRow(
                            icon: Assets.icons.quizQuestionsIcon,
                            label: context.l10n.quizQuestionsCount(
                              session.questionCount,
                            ),
                          ),
                          const Gap(AppSpacing.s8),
                          _StatRow(
                            icon: Assets.icons.quizTimerIcon,
                            label: context.l10n.quizMinutesPerQuestion(
                              session.minutesPerQuestion,
                            ),
                          ),
                          const Gap(AppSpacing.s8),
                          _StatRow(
                            icon: Assets.icons.quizTimerIcon,
                            label: context.l10n.quizPassPercent(
                              session.passPercent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(AppSpacing.s16),
              AppButton(
                label: context.l10n.quizStartQuiz,
                onPressed: () {
                  AppHaptics.selection();
                  unawaited(
                    context.pushNamed(RouteNames.quizTaking, extra: session),
                  );
                },
              ),
              const Gap(AppSpacing.s8),
              AppButton(
                label: context.l10n.quizCancel,
                isOutlined: true,
                onPressed: () {
                  AppHaptics.selection();
                  context.pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const new({required this.icon, required this.label});

  final SvgGenImage icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFE0EBFF),
            borderRadius: BorderRadius.circular(AppSpacing.r8),
          ),
          child: icon.svg(width: 18, height: 18),
        ),
        const Gap(AppSpacing.s8),
        Text(label, style: context.textTheme.bodyLarge),
      ],
    );
  }
}
