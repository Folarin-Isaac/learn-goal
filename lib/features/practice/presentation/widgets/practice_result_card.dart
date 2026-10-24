import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/practice/presentation/models/practice_question.dart';

class PracticeResultCard extends StatelessWidget {
  const new({
    required this.index,
    required this.question,
    required this.selectedOption,
    required this.onReview,
    super.key,
  });

  final int index;
  final PracticeQuestion question;
  final int? selectedOption;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final isCorrect = selectedOption == question.correctOptionIndex;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.r12),
      ),
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '${index + 1}',
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
          const Gap(AppSpacing.s8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(question.text, style: context.textTheme.bodyLarge),
                if (selectedOption != null) ...[
                  const Gap(AppSpacing.s16),
                  _VerdictChip(isCorrect: isCorrect),
                ],
              ],
            ),
          ),
          const Gap(AppSpacing.s8),
          Pressable(
            child: InkWell(
              onTap: () {
                AppHaptics.selection();
                onReview();
              },
              child: Text(
                context.l10n.practiceReview,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: AppColors.accentBlue,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.accentBlue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerdictChip extends StatelessWidget {
  const new({required this.isCorrect});

  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? AppColors.successGreen : AppColors.errorRed;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s4,
        AppSpacing.s4,
        AppSpacing.s8,
        AppSpacing.s4,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(AppSpacing.r8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isCorrect)
            Assets.icons.practiceCorrectBadgeIcon.svg(width: 18, height: 18)
          else
            Container(
              width: 18,
              height: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(AppSpacing.r4),
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 12,
                color: Colors.white,
              ),
            ),
          const Gap(AppSpacing.s4),
          Text(
            isCorrect
                ? context.l10n.practiceCorrect
                : context.l10n.practiceIncorrect,
            style: context.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
