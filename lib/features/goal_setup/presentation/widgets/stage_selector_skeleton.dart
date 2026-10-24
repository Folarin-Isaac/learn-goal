import 'package:lengoal/core/core.dart';

class StageSelectorSkeleton extends StatelessWidget {
  const new({super.key, this.rowCount = 3});

  final int rowCount;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Column(
        children: [
          for (var i = 0; i < rowCount; i++) ...[
            Container(
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: const Row(
                children: [
                  SkeletonBox.circle(size: 20),
                  Gap(AppSpacing.s16),
                  Expanded(child: SkeletonBox(height: 16)),
                ],
              ),
            ),
            if (i != rowCount - 1) const Gap(AppSpacing.s8),
          ],
        ],
      ),
    );
  }
}
