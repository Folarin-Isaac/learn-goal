import 'package:lengoal/core/core.dart';

class EducatorProfileTextCard extends StatelessWidget {
  const new({required this.title, required this.body, super.key});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: context.textTheme.titleMedium),
            const Gap(AppSpacing.s8),
            Text(body, style: context.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
