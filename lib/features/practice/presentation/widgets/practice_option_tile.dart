import 'package:lengoal/core/core.dart';

enum PracticeOptionState { idle, correct, wrong }

class PracticeOptionTile extends StatelessWidget {
  const new({
    required this.letter,
    required this.label,
    required this.isSelected,
    required this.state,
    this.onTap,
    super.key,
  });

  final String letter;
  final String label;
  final bool isSelected;
  final PracticeOptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (background, border) = switch (state) {
      PracticeOptionState.idle => (null, null),
      PracticeOptionState.correct => (
        AppColors.successSurface,
        AppColors.successBorder,
      ),
      PracticeOptionState.wrong => (
        AppColors.errorSurface,
        AppColors.errorBorder,
      ),
    };

    return Pressable(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.r8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s8,
            vertical: AppSpacing.s8,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppSpacing.r8),
            border: border == null ? null : Border.all(color: border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Radio(isSelected: isSelected),
              const Gap(AppSpacing.s8),
              Text(
                '$letter.',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Gap(AppSpacing.s8),
              Expanded(
                child: Text(
                  label,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? context.colors.onSurface
                        : context.colors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const new({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      margin: const EdgeInsets.only(top: AppSpacing.s2),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected
              ? context.colors.onSurface
              : AppColors.borderGray200,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: isSelected
          ? Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colors.onSurface,
              ),
            )
          : null,
    );
  }
}
