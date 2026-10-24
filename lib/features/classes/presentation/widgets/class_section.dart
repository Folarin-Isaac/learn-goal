import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/models/class_detail.dart';
import 'package:lengoal/features/classes/presentation/models/class_summary.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_card.dart';

class ClassSection extends StatefulWidget {
  const new({
    required this.title,
    required this.items,
    required this.onSeeAll,
    this.entranceIndex = 0,
    super.key,
  });

  final String title;
  final List<ClassSummary> items;
  final VoidCallback onSeeAll;

  final int entranceIndex;

  @override
  State<ClassSection> createState() => _ClassSectionState();
}

class _ClassSectionState extends State<ClassSection> {
  static const double _cardsPerScreen = 2.2;
  static const double _minCardWidth = 140;
  static const double _maxCardWidth = 200;

  @override
  Widget build(BuildContext context) {
    final items = widget.items;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth / _cardsPerScreen).clamp(
          _minCardWidth,
          _maxCardWidth,
        );
        final cardHeight = ClassCard.preferredHeight(cardWidth);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Entrance(
              index: widget.entranceIndex,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: context.textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _SeeAllButton(onTap: widget.onSeeAll),
                ],
              ),
            ),
            const Gap(AppSpacing.s16),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s24),
                child: Center(
                  child: Text(
                    context.l10n.dashboardNoFilterResults,
                    style: context.textTheme.bodyMedium,
                  ),
                ),
              )
            else
              SizedBox(
                height: cardHeight,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  separatorBuilder: (context, index) =>
                      const Gap(AppSpacing.s16),
                  itemBuilder: (context, index) => Entrance(
                    index: widget.entranceIndex + 1 + index,
                    offset: const Offset(20, 0),
                    child: ClassCard(
                      item: items[index],
                      width: cardWidth,
                      onTap: () => context.pushNamed(
                        RouteNames.classDetails,
                        extra: detailFor(items[index]),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SeeAllButton extends StatelessWidget {
  const new({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppHaptics.selection();
        onTap();
      },
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.r8),
          border: Border.all(color: context.colors.outlineVariant),
        ),
        child: const Icon(Icons.chevron_right, size: 16),
      ),
    );
  }
}
