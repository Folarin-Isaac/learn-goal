import 'package:lengoal/core/core.dart';

class PracticeExamButton extends StatelessWidget {
  const new({required this.isReview, required this.onPressed, super.key});

  final bool isReview;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      child: Material(
        color: isReview ? AppColors.actionBlue : AppColors.successGreen,
        borderRadius: BorderRadius.circular(AppSpacing.r4),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.r4),
          onTap: () {
            AppHaptics.selection();
            onPressed();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: AppSpacing.s8,
            ),
            child: Text(
              isReview
                  ? context.l10n.practiceReviewExam
                  : context.l10n.practiceStartExam,
              style: context.textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
