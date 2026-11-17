import 'package:lengoal/core/core.dart';

class ClassEnrollHint extends StatelessWidget {
  const new({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final muted = context.colors.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.r12),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline_rounded, size: 18, color: muted),
          const Gap(12),
          Expanded(
            child: Text(
              message,
              style: context.textTheme.bodyMedium?.copyWith(color: muted),
            ),
          ),
        ],
      ),
    );
  }
}
