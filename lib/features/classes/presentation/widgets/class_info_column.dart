import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/models/class_summary.dart';

class ClassInfoColumn extends StatelessWidget {
  const new({required this.item, super.key});

  final ClassSummary item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final isFree = item.priceLabel == null;
    final tagBackground = isFree
        ? const Color(0xFFDAF2E4)
        : const Color(0xFFE0EBFF);
    final tagForeground = isFree
        ? const Color(0xFF0E8C43)
        : const Color(0xFF004DE6);
    final tagIcon = isFree
        ? Assets.icons.freeTagIcon
        : Assets.icons.premiumTagIcon;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: tagBackground,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  tagIcon.svg(width: 12, height: 12),
                  const Gap(4),
                  Flexible(
                    child: Text(
                      isFree ? context.l10n.dashboardFreeTag : item.priceLabel!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: tagForeground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(AppSpacing.s8),
            Expanded(
              child: Text(
                item.dateRange,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodySmall,
              ),
            ),
          ],
        ),
        const Gap(AppSpacing.s4),
        Text(
          item.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const Gap(AppSpacing.s4),
        Text(
          item.instructor,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodyMedium,
        ),
        if (item.isSubscribed) ...[
          const Gap(AppSpacing.s8),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            child: LinearProgressIndicator(
              value: item.progress,
              minHeight: 4,
              backgroundColor: colorScheme.outlineVariant.withValues(
                alpha: 0.4,
              ),
              valueColor: AlwaysStoppedAnimation(colorScheme.primary),
            ),
          ),
          const Gap(AppSpacing.s4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              context.l10n.dashboardCompletedPercent(
                (item.progress * 100).round(),
              ),
              style: context.textTheme.bodySmall,
            ),
          ),
        ],
      ],
    );
  }
}
