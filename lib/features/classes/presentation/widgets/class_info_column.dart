import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/bloc/class_attendance/class_attendance_store.dart';
import 'package:lengoal/features/classes/presentation/models/class_summary.dart';

class ClassInfoColumn extends StatelessWidget {
  const new({
    required this.item,
    this.stackDate = false,
    this.showProgress = true,
    super.key,
  });

  final ClassSummary item;
  final bool stackDate;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
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

    final tag = Container(
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
    );
    final date = Text(
      item.dateRange,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.textTheme.bodySmall,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (stackDate) ...[
          tag,
          const Gap(AppSpacing.s8),
          date,
        ] else
          Row(
            children: [
              tag,
              const Gap(AppSpacing.s8),
              Expanded(child: date),
            ],
          ),
        Gap(stackDate ? 6 : AppSpacing.s4),
        Text(
          item.title,
          maxLines: stackDate ? 3 : 2,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: stackDate ? 15 : 14,
            height: 1.35,
          ),
        ),
        Gap(stackDate ? 6 : AppSpacing.s4),
        Text(
          item.instructor,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodyMedium,
        ),
        if (showProgress && item.isSubscribed) ...[
          Gap(stackDate ? 10 : AppSpacing.s8),
          _ClassProgress(item: item, stackDate: stackDate),
        ],
      ],
    );
  }
}

class _ClassProgress extends StatefulWidget {
  const new({required this.item, required this.stackDate});

  final ClassSummary item;
  final bool stackDate;

  @override
  State<_ClassProgress> createState() => _ClassProgressState();
}

class _ClassProgressState extends State<_ClassProgress> {
  final ClassAttendanceStore _store = getIt();

  @override
  void initState() {
    super.initState();
    _store.ensure(widget.item.id);
  }

  @override
  void didUpdateWidget(_ClassProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) _store.ensure(widget.item.id);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final attendance = _store.attendanceFor(widget.item.id);
        final progress =
            attendance?.fractionOf(widget.item.sessionCount) ??
            widget.item.progress;
        return TweenAnimationBuilder<double>(
          tween: Tween(end: progress),
          duration: AppMotion.slow,
          curve: AppMotion.standard,
          builder: (context, value, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 4,
                  backgroundColor: colorScheme.outlineVariant.withValues(
                    alpha: 0.4,
                  ),
                  valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                ),
              ),
              Gap(widget.stackDate ? 6 : AppSpacing.s4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  context.l10n.dashboardCompletedPercent(
                    (progress * 100).round(),
                  ),
                  style: context.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
