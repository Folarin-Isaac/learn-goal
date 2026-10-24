import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/practice/presentation/models/practice_question.dart';
import 'package:lengoal/features/practice/presentation/widgets/practice_nav_button.dart';
import 'package:lengoal/features/practice/presentation/widgets/practice_option_tile.dart';

class PracticeQuestionCard extends StatelessWidget {
  const new({
    required this.number,
    required this.question,
    required this.selectedOption,
    required this.onPrevious,
    required this.onNext,
    super.key,
    this.onSelect,
    this.onSave,
    this.revealAnswer = false,
  });

  final int number;
  final PracticeQuestion question;
  final int? selectedOption;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final ValueChanged<int>? onSelect;
  final VoidCallback? onSave;
  final bool revealAnswer;

  PracticeOptionState _stateFor(int index) {
    if (!revealAnswer || selectedOption != index) {
      return PracticeOptionState.idle;
    }
    return index == question.correctOptionIndex
        ? PracticeOptionState.correct
        : PracticeOptionState.wrong;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.r12),
      ),
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '$number. ${question.text}',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const Gap(AppSpacing.s24),
          for (var i = 0; i < question.options.length; i++) ...[
            PracticeOptionTile(
              letter: String.fromCharCode(65 + i),
              label: question.options[i],
              isSelected: selectedOption == i,
              state: _stateFor(i),
              onTap: onSelect == null
                  ? null
                  : () {
                      AppHaptics.selection();
                      onSelect!(i);
                    },
            ),
            if (i != question.options.length - 1) const Gap(AppSpacing.s16),
          ],
          const Gap(AppSpacing.s24),
          Row(
            mainAxisAlignment: onSave == null
                ? MainAxisAlignment.center
                : MainAxisAlignment.spaceBetween,
            children: [
              PracticeNavButton(isForward: false, onPressed: onPrevious),
              if (onSave == null)
                const Gap(AppSpacing.s16)
              else ...[
                const Gap(AppSpacing.s16),
                Expanded(child: _SaveButton(onPressed: onSave)),
                const Gap(AppSpacing.s16),
              ],
              PracticeNavButton(isForward: true, onPressed: onNext),
            ],
          ),
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const new({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(44),
        foregroundColor: AppColors.accentBlue,
        side: const BorderSide(color: AppColors.accentBlue),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.r8),
        ),
      ),
      onPressed: onPressed,
      child: Text(context.l10n.practiceSave),
    );
  }
}
