import 'package:lengoal/core/core.dart';

class ChatDaySeparator extends StatelessWidget {
  const new({required this.label, this.highlight = false, super.key});

  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final color = highlight
        ? context.colors.primary
        : context.colors.onSurfaceVariant;
    final line = Expanded(
      child: Divider(
        height: 1,
        color: highlight ? color : context.colors.outlineVariant,
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
      child: Row(
        children: [
          line,
          Flexible(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: context.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: highlight ? FontWeight.w600 : null,
                ),
              ),
            ),
          ),
          line,
        ],
      ),
    );
  }
}
