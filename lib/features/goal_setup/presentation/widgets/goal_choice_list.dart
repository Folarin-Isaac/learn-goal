import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/goal_setup/domain/entities/exam_goal.dart';

class GoalChoiceList extends StatelessWidget {
  const new levels({
    required List<GoalLevel> this.levels,
    required this.selectedLevelId,
    required this.selectedSubjectIds,
    required ValueChanged<String> this.onLevelTap,
    required this.onSubjectToggle,
    super.key,
  }) : subjects = null;

  const new subjects({
    required List<GoalSubject> this.subjects,
    required this.selectedSubjectIds,
    required this.onSubjectToggle,
    super.key,
  }) : levels = null,
       selectedLevelId = null,
       onLevelTap = null;

  final List<GoalLevel>? levels;
  final List<GoalSubject>? subjects;
  final String? selectedLevelId;
  final Set<String> selectedSubjectIds;
  final ValueChanged<String>? onLevelTap;
  final ValueChanged<String> onSubjectToggle;

  static const double maxHeight = 300;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final levels = this.levels;
    final children = levels != null
        ? [for (final level in levels) _level(context, level)]
        : [
            for (final subject in subjects ?? const <GoalSubject>[])
              _subjectRow(context, subject),
          ];
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.r16),
      ),
      constraints: const BoxConstraints(maxHeight: maxHeight),
      clipBehavior: Clip.antiAlias,
      child: Scrollbar(
        child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s4),
          itemCount: children.length,
          separatorBuilder: (context, index) =>
              Divider(height: 1, color: colors.outlineVariant),
          itemBuilder: (context, index) => children[index],
        ),
      ),
    );
  }

  Widget _level(BuildContext context, GoalLevel level) {
    final colors = context.colors;
    final selected = level.id == selectedLevelId;
    final header = InkWell(
      onTap: () {
        AppHaptics.selection();
        onLevelTap?.call(level.id);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: 14,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(level.name, style: context.textTheme.bodyLarge),
            ),
            if (selected)
              Icon(Icons.check_circle, color: colors.primary, size: 20),
          ],
        ),
      ),
    );
    if (!selected || level.subjects.isEmpty) return header;
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.s8,
        AppSpacing.s4,
        AppSpacing.s8,
        AppSpacing.s8,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(AppSpacing.r12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          for (final subject in level.subjects) _checkboxRow(context, subject),
        ],
      ),
    );
  }

  Widget _checkboxRow(BuildContext context, GoalSubject subject) {
    final checked = selectedSubjectIds.contains(subject.id);
    return InkWell(
      onTap: () {
        AppHaptics.selection();
        onSubjectToggle(subject.id);
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s8,
          AppSpacing.s4,
          AppSpacing.s16,
          AppSpacing.s4,
        ),
        child: Row(
          children: [
            Checkbox(
              value: checked,
              onChanged: (_) {
                AppHaptics.selection();
                onSubjectToggle(subject.id);
              },
            ),
            Expanded(
              child: Text(subject.name, style: context.textTheme.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }

  Widget _subjectRow(BuildContext context, GoalSubject subject) {
    final selected = selectedSubjectIds.contains(subject.id);
    return InkWell(
      onTap: () {
        AppHaptics.selection();
        onSubjectToggle(subject.id);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: 14,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(subject.name, style: context.textTheme.bodyLarge),
            ),
            if (selected)
              Icon(Icons.check_circle, color: context.colors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
