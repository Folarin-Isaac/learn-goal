import 'package:lengoal/core/core.dart';

class ChatDaySeparator extends StatelessWidget {
  const new({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final line = Expanded(
      child: Divider(height: 1, color: context.colors.outlineVariant),
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
                  color: context.colors.onSurfaceVariant,
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
