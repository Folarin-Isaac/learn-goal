import 'package:lengoal/core/core.dart';

class SelectableListSkeleton extends StatelessWidget {
  const new({super.key, this.rowCount = 6});

  final int rowCount;

  static const _rowWidths = [0.7, 0.45, 0.6, 0.5, 0.65, 0.4];

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            for (var i = 0; i < rowCount; i++) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: _rowWidths[i % _rowWidths.length],
                    child: const SkeletonBox(height: 16),
                  ),
                ),
              ),
              if (i != rowCount - 1)
                Divider(height: 1, color: context.colors.outlineVariant),
            ],
          ],
        ),
      ),
    );
  }
}
