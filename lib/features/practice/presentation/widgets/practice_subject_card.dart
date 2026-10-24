import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/practice/presentation/models/practice_subject.dart';
import 'package:lengoal/features/practice/presentation/widgets/dashed_border_box.dart';

class PracticeSubjectCard extends StatelessWidget {
  const new({
    required this.subject,
    required this.isExpanded,
    required this.onToggle,
    required this.onTopicTap,
    super.key,
    this.trailing,
  });

  final PracticeSubject subject;
  final bool isExpanded;
  final VoidCallback onToggle;
  final ValueChanged<PracticeTopic> onTopicTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Pressable(
          child: Material(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.r12),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.r12),
              onTap: () {
                AppHaptics.selection();
                onToggle();
              },
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.s16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject.title,
                            style: context.textTheme.titleLarge,
                          ),
                          const Gap(AppSpacing.s2),
                          Text(
                            context.l10n.practiceSolvedOf(
                              subject.solvedCount,
                              subject.totalCount,
                            ),
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(AppSpacing.s8),
                    trailing ??
                        Text(
                          '${subject.progressPercent}%',
                          style: context.textTheme.titleLarge,
                        ),
                    const Gap(AppSpacing.s8),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: AppMotion.fast,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: context.colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: AppMotion.base,
          curve: AppMotion.enter,
          alignment: Alignment.topCenter,
          child: isExpanded
              ? Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.s4),
                  child: DashedBorderBox(
                    child: Column(
                      children: [
                        for (var i = 0; i < subject.topics.length; i++) ...[
                          if (i != 0)
                            Divider(
                              height: 1,
                              color: context.colors.surface.withValues(
                                alpha: 0.9,
                              ),
                            ),
                          _TopicRow(
                            topic: subject.topics[i],
                            onTap: () => onTopicTap(subject.topics[i]),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

class _TopicRow extends StatelessWidget {
  const new({required this.topic, required this.onTap});

  final PracticeTopic topic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      child: InkWell(
        onTap: () {
          AppHaptics.selection();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s16,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(topic.title, style: context.textTheme.bodyLarge),
                    const Gap(AppSpacing.s2),
                    Text(
                      context.l10n.practiceSolvedOf(
                        topic.solvedCount,
                        topic.totalCount,
                      ),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(AppSpacing.s8),
              Text(
                topic.scorePercent == null
                    ? context.l10n.practiceNoScore
                    : '${topic.scorePercent}%',
                style: context.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
