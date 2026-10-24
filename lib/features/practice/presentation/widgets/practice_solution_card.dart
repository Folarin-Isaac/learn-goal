import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/practice/presentation/models/practice_question.dart';

class PracticeSolutionCard extends StatelessWidget {
  const new({required this.question, required this.isCorrect, super.key});

  final PracticeQuestion question;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final background = isCorrect
        ? AppColors.successSurfaceMuted
        : AppColors.errorSurfaceMuted;
    final border = isCorrect ? AppColors.successBorder : AppColors.errorBorder;

    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.r12),
        border: Border.all(color: border),
      ),
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.practiceSolution,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const Gap(AppSpacing.s24),
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.s8),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: context.l10n.practiceAnswerIsCorrect(
                      question.correctLetter,
                    ),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: AppColors.successGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(text: question.solution),
                ],
              ),
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
