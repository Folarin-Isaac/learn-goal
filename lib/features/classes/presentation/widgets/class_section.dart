import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/bloc/class_list/class_list_bloc.dart';
import 'package:lengoal/features/classes/presentation/models/class_summary.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_card.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_list_loader.dart';

class ClassSection extends StatelessWidget {
  const new({
    required this.title,
    required this.source,
    required this.onSeeAll,
    this.entranceIndex = 0,
    super.key,
  });

  final String title;
  final ClassListSource source;
  final VoidCallback onSeeAll;

  final int entranceIndex;

  static const double _cardsPerScreen = 2.2;
  static const double _minCardWidth = 140;
  static const double _maxCardWidth = 200;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth / _cardsPerScreen).clamp(
          _minCardWidth,
          _maxCardWidth,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Entrance(
              index: entranceIndex,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: context.textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _SeeAllButton(onTap: onSeeAll),
                ],
              ),
            ),
            const Gap(AppSpacing.s16),
            ClassListLoader(
              source: source,
              compactError: true,
              loading: ClassCardRowSkeleton(cardWidth: cardWidth),
              builder: (context, classes) {
                if (classes.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.s24,
                    ),
                    child: Center(
                      child: Text(
                        context.l10n.classesEmpty,
                        style: context.textTheme.bodyMedium,
                      ),
                    ),
                  );
                }
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var index = 0; index < classes.length; index++) ...[
                        if (index > 0) const Gap(AppSpacing.s16),
                        Entrance(
                          index: entranceIndex + 1 + index,
                          offset: const Offset(20, 0),
                          child: ClassCard(
                            item: ClassSummary.fromClass(
                              classes[index],
                              isFavorite: source == ClassListSource.saved,
                            ),
                            width: cardWidth,
                            onTap: () => context.pushNamed(
                              RouteNames.classDetails,
                              extra: classes[index],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
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
