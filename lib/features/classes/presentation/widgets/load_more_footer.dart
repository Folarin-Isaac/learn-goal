import 'package:lengoal/core/core.dart';

class LoadMoreFooter extends StatelessWidget {
  const new({required this.failed, required this.onRetry, super.key});

  final bool failed;
  final VoidCallback onRetry;

  static bool shouldLoadMore(Notification notification) {
    final metrics = switch (notification) {
      ScrollNotification(:final metrics) => metrics,
      ScrollMetricsNotification(:final metrics) => metrics,
      _ => null,
    };
    return metrics != null && metrics.extentAfter < 400;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
      child: failed
          ? Column(
              children: [
                Text(
                  context.l10n.classesLoadMoreFailed,
                  style: context.textTheme.bodyMedium,
                ),
                TextButton(
                  onPressed: () {
                    AppHaptics.selection();
                    onRetry();
                  },
                  child: Text(context.l10n.commonRetry),
                ),
              ],
            )
          : const LoadingIndicator(size: 24),
    );
  }
}
