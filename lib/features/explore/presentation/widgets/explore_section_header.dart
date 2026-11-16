import 'package:lengoal/core/core.dart';

class ExploreSectionHeader extends StatelessWidget {
  const new({
    required this.eyebrow,
    required this.color,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final String eyebrow;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const Gap(AppSpacing.s8),
            Flexible(
              child: Text(
                eyebrow,
                style: context.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
        const Gap(AppSpacing.s8),
        Text(title, style: context.textTheme.titleLarge),
        const Gap(AppSpacing.s8),
        Text(subtitle, style: context.textTheme.bodyMedium),
      ],
    );
  }
}
