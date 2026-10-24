import 'package:lengoal/core/core.dart';

class PracticeQuestionPalette extends StatelessWidget {
  const new({
    required this.count,
    required this.currentIndex,
    required this.answeredIndexes,
    required this.onSelect,
    super.key,
  });

  final int count;
  final int currentIndex;
  final Set<int> answeredIndexes;
  final ValueChanged<int> onSelect;

  static const int _columns = 7;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.r12),
      ),
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.practiceQuestionsHeading,
            style: context.textTheme.titleLarge?.copyWith(
              color: AppColors.accentBlue,
            ),
          ),
          const Gap(AppSpacing.s16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: count,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _columns,
              mainAxisSpacing: AppSpacing.s8,
              crossAxisSpacing: AppSpacing.s8,
            ),
            itemBuilder: (context, index) => _PaletteCell(
              number: index + 1,
              isCurrent: index == currentIndex,
              isAnswered: answeredIndexes.contains(index),
              onTap: () {
                AppHaptics.selection();
                onSelect(index);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PaletteCell extends StatelessWidget {
  const new({
    required this.number,
    required this.isCurrent,
    required this.isAnswered,
    required this.onTap,
  });

  final int number;
  final bool isCurrent;
  final bool isAnswered;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = isCurrent
        ? AppColors.accentBlue
        : isAnswered
        ? AppColors.accentBlueSoft
        : Colors.transparent;

    return Pressable(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.r8),
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppSpacing.r8),
          ),
          child: Text(
            '$number',
            style: context.textTheme.bodyMedium?.copyWith(
              color: isCurrent ? Colors.white : context.colors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
