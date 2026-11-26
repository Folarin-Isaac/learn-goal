import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_list_loader.dart';
import 'package:lengoal/features/explore/presentation/bloc/explore_cubit.dart';

class ExploreRow<T> extends StatelessWidget {
  const new({
    required this.section,
    required this.cardWidth,
    required this.emptyMessage,
    required this.itemBuilder,
    this.equalHeights = false,
    super.key,
  });

  final ExploreSection<T> section;
  final double cardWidth;
  final String emptyMessage;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final bool equalHeights;

  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: AppSpacing.s16,
  );

  @override
  Widget build(BuildContext context) {
    final items = section.items;
    if (items.isEmpty) {
      if (section.status == ExploreSectionStatus.loading) {
        return Padding(
          padding: _padding,
          child: ClassCardRowSkeleton(cardWidth: cardWidth),
        );
      }
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s24,
        ),
        child: Center(
          child: Text(
            section.status == ExploreSectionStatus.failure
                ? context.l10n.exploreSectionError
                : emptyMessage,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium,
          ),
        ),
      );
    }
    final row = Row(
      crossAxisAlignment: equalHeights
          ? CrossAxisAlignment.stretch
          : CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const Gap(AppSpacing.s16),
          Entrance(
            index: i,
            offset: const Offset(20, 0),
            child: RepaintBoundary(child: itemBuilder(context, items[i], i)),
          ),
        ],
      ],
    );
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: _padding,
      child: equalHeights ? IntrinsicHeight(child: row) : row,
    );
  }
}
