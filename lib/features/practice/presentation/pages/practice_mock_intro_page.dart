import 'dart:async';

import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/practice/presentation/models/practice_mock.dart';
import 'package:lengoal/features/practice/presentation/models/practice_subject.dart';

class PracticeMockIntroPage extends StatelessWidget {
  const new({required this.mock, required this.topic, super.key});

  final PracticeMock mock;
  final PracticeTopic topic;

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
                  Entrance(
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        borderRadius: BorderRadius.circular(AppSpacing.r12),
                      ),
                      padding: const EdgeInsets.all(AppSpacing.s16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            context.l10n.practiceMockExamTitle(mock.title),
                            textAlign: TextAlign.center,
                            style: context.textTheme.headlineSmall,
                          ),
                          const Gap(AppSpacing.s16),
                          Text(
                            context.l10n.quizInstructionsHeading,
                            textAlign: TextAlign.center,
                            style: context.textTheme.bodyLarge,
                          ),
                          const Gap(AppSpacing.s8),
                          for (final instruction in mock.instructions)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.s4,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '•  ',
                                    style: context.textTheme.bodyMedium
                                        ?.copyWith(
                                          color:
                                              context.colors.onSurfaceVariant,
                                        ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      instruction,
                                      style: context.textTheme.bodyMedium
                                          ?.copyWith(
                                            color:
                                                context.colors.onSurfaceVariant,
                                            height: 1.5,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const Gap(AppSpacing.s24),
                          _StatRow(
                            icon: Assets.icons.quizQuestionsIcon,
                            label: context.l10n.quizQuestionsCount(
                              topic.questions.length,
                            ),
                          ),
                          const Gap(AppSpacing.s16),
                          _StatRow(
                            icon: Assets.icons.quizTimerIcon,
                            label: context.l10n.quizMinutesPerQuestion(
                              mock.minutesPerQuestion,
                            ),
                          ),
                          const Gap(AppSpacing.s16),
                          _StatRow(
                            icon: Assets.icons.quizTimerIcon,
                            label: context.l10n.quizPassPercent(
                              mock.passPercent,
                            ),
                          ),
                          const Gap(AppSpacing.s24),
                          AppButton(
                            label: context.l10n.practiceStartExamCta,
                            onPressed: () {
                              AppHaptics.selection();
                              unawaited(
                                context.pushNamed(
                                  RouteNames.practiceSession,
                                  extra: topic,
                                ),
                              );
                            },
                          ),
                          const Gap(AppSpacing.s16),
                          AppButton(
                            label: context.l10n.commonCancel,
                            isOutlined: true,
                            foregroundColor: AppColors.brandPrimary,
                            onPressed: () {
                              AppHaptics.selection();
                              context.pop();
                            },
                          ),
                        ],
                      ),
                    ),
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
            color: AppColors.tagBlueSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          ),
          child: icon.svg(width: 18, height: 18),
        ),
        const Gap(AppSpacing.s16),
        Expanded(child: Text(label, style: context.textTheme.bodyLarge)),
      ],
    );
  }
}
