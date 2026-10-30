import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/models/class_summary.dart';

enum ClassFilterOption { free, premium, subscribed, none }

bool matchesClassFilter(ClassSummary item, ClassFilterOption? filter) {
  return switch (filter) {
    null || ClassFilterOption.none => true,
    ClassFilterOption.free => item.priceLabel == null,
    ClassFilterOption.premium => item.priceLabel != null,
    ClassFilterOption.subscribed => item.isSubscribed,
  };
}

String classFilterLabel(BuildContext context, ClassFilterOption option) =>
    switch (option) {
      ClassFilterOption.free => context.l10n.dashboardFilterFree,
      ClassFilterOption.premium => context.l10n.dashboardFilterPremium,
      ClassFilterOption.subscribed => context.l10n.dashboardFilterSubscribed,
      ClassFilterOption.none => context.l10n.dashboardFilterClearAll,
    };

Future<ClassFilterOption?> _showClassFilterMenu(
  BuildContext context,
  ClassFilterOption? current,
) {
  final renderBox = context.findRenderObject()! as RenderBox;
  final overlay = Overlay.of(context).context.findRenderObject()! as RenderBox;
  final topLeft = renderBox.localToGlobal(
    Offset(0, renderBox.size.height + 8),
    ancestor: overlay,
  );
  final bottomRight = renderBox.localToGlobal(
    renderBox.size.bottomRight(const Offset(0, 8)),
    ancestor: overlay,
  );
  final position = RelativeRect.fromRect(
    Rect.fromPoints(topLeft, bottomRight),
    Offset.zero & overlay.size,
  );

  PopupMenuItem<ClassFilterOption> option(ClassFilterOption value) {
    final isSelected = value == current;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Expanded(
            child: Text(
              classFilterLabel(context, value),
              style: context.textTheme.bodyLarge,
            ),
          ),
          if (isSelected)
            Icon(Icons.check, size: 18, color: context.colors.primary),
        ],
      ),
    );
  }

  return showMenu<ClassFilterOption>(
    context: context,
    position: position,
    color: context.colors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.r16),
    ),
    constraints: const BoxConstraints(minWidth: 200),
    items: [
      option(ClassFilterOption.free),
      option(ClassFilterOption.premium),
      option(ClassFilterOption.subscribed),
      const PopupMenuDivider(height: 1),
      PopupMenuItem(
        value: ClassFilterOption.none,
        child: Row(
          children: [
            const Icon(Icons.restore, size: 18, color: Colors.redAccent),
            const Gap(AppSpacing.s8),
            Text(
              context.l10n.dashboardFilterClearAll,
              style: context.textTheme.bodyLarge?.copyWith(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class ClassFilterChip extends StatelessWidget {
  const new({required this.current, required this.onChanged, super.key});

  final ClassFilterOption? current;
  final ValueChanged<ClassFilterOption?> onChanged;

  @override
  Widget build(BuildContext context) {
    final option = current;
    final label = option == null
        ? context.l10n.dashboardFilterAll
        : classFilterLabel(context, option);
    final (background, foreground, icon) = switch (option) {
      ClassFilterOption.free => (
        const Color(0xFFDAF2E4),
        const Color(0xFF0E8C43),
        Assets.icons.freeTagIcon,
      ),
      ClassFilterOption.premium => (
        const Color(0xFFE0EBFF),
        const Color(0xFF004DE6),
        Assets.icons.premiumTagIcon,
      ),
      _ => (
        context.colors.primary.withValues(alpha: 0.08),
        context.colors.primary,
        null,
      ),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.l10n.dashboardFilterByLabel,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const Gap(AppSpacing.s8),
        Builder(
          builder: (buttonContext) => GestureDetector(
            onTap: () async {
              AppHaptics.selection();
              final result = await _showClassFilterMenu(buttonContext, option);
              if (result != null) {
                onChanged(result == ClassFilterOption.none ? null : result);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(AppSpacing.r4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon.svg(width: 14, height: 14),
                    const Gap(AppSpacing.s4),
                  ],
                  Text(
                    label,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(2),
                  Icon(Icons.keyboard_arrow_down, size: 16, color: foreground),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
