import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lengoal/core/motion/entrance.dart';
import 'package:lengoal/core/motion/pressable.dart';
import 'package:lengoal/core/theme/app_spacing.dart';
import 'package:lengoal/core/utils/haptics.dart';
import 'package:lengoal/features/goal_setup/domain/entities/exam_stage.dart';

class StageSelector extends StatelessWidget {
  const new({
    required this.stages,
    required this.selectedStage,
    required this.selectedTopicIds,
    required this.onStageSelected,
    required this.onTopicToggled,
    super.key,
  });

  final List<ExamStage> stages;
  final ExamStage? selectedStage;
  final Set<String> selectedTopicIds;
  final ValueChanged<ExamStage> onStageSelected;
  final ValueChanged<String> onTopicToggled;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < stages.length; i++) ...[
          Entrance(
            index: i,
            child: _StageTile(
              stage: stages[i],
              isSelected: stages[i] == selectedStage,
              selectedTopicIds: selectedTopicIds,
              onSelected: () {
                AppHaptics.selection();
                onStageSelected(stages[i]);
              },
              onTopicToggled: onTopicToggled,
            ),
          ),
          if (i != stages.length - 1) const Gap(AppSpacing.s8),
        ],
      ],
    );
  }
}

class _StageTile extends StatelessWidget {
  const new({
    required this.stage,
    required this.isSelected,
    required this.selectedTopicIds,
    required this.onSelected,
    required this.onTopicToggled,
  });

  final ExamStage stage;
  final bool isSelected;
  final Set<String> selectedTopicIds;
  final VoidCallback onSelected;
  final ValueChanged<String> onTopicToggled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Pressable(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onSelected,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: isSelected ? true : null,
                      onChanged: (_) => onSelected(),
                    ),
                    Expanded(
                      child: Text(
                        stage.name,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isSelected)
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 16, bottom: 12),
              child: Column(
                children: [
                  for (final topic in stage.topics)
                    Pressable(
                      child: InkWell(
                        onTap: () {
                          AppHaptics.selection();
                          onTopicToggled(topic.id);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Checkbox(
                                value: selectedTopicIds.contains(topic.id),
                                onChanged: (_) {
                                  AppHaptics.selection();
                                  onTopicToggled(topic.id);
                                },
                              ),
                              Expanded(
                                child: Text(
                                  topic.name,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
