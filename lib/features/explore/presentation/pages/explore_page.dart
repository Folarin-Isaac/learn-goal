import 'dart:async';

import 'package:flutter/rendering.dart';

import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/explore/presentation/bloc/explore_cubit.dart';
import 'package:lengoal/features/explore/presentation/widgets/explore_category_chips.dart';
import 'package:lengoal/features/explore/presentation/widgets/explore_class_card.dart';
import 'package:lengoal/features/explore/presentation/widgets/explore_educator_card.dart';
import 'package:lengoal/features/explore/presentation/widgets/explore_row.dart';
import 'package:lengoal/features/explore/presentation/widgets/explore_section_header.dart';

class ExplorePage extends StatefulWidget {
  const new({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final ExploreCubit _cubit = getIt<ExploreCubit>();

  @override
  void initState() {
    super.initState();
    unawaited(_cubit.load());
  }

  @override
  void dispose() {
    unawaited(_cubit.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RouteVisibilityListener(
      routeName: RouteNames.explore,
      onVisible: () => unawaited(_cubit.refreshIfStale()),
      child: BlocProvider.value(value: _cubit, child: const _ExploreView()),
    );
  }
}

class _ExploreView extends StatelessWidget {
  const new();

  static const Color _liveColor = AppColors.successGreen;
  static const Color _upcomingColor = Color(0xFFB8860B);
  static const Color _educatorsColor = Color(0xFFE6198C);
  static const double _cardWidthShare = 0.82;
  static const double _minCardWidth = 260;
  static const double _maxCardWidth = 340;
  static const double _cacheExtent = 3000;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cardWidth = (MediaQuery.sizeOf(context).width * _cardWidthShare)
        .clamp(_minCardWidth, _maxCardWidth);
    const sidePadding = EdgeInsets.symmetric(horizontal: AppSpacing.s16);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<ExploreCubit, ExploreState>(
          builder: (context, state) {
            final cubit = context.read<ExploreCubit>();
            return RefreshIndicator(
              onRefresh: cubit.load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                scrollCacheExtent: const ScrollCacheExtent.pixels(_cacheExtent),
                padding: const EdgeInsets.only(
                  top: AppSpacing.s16,
                  bottom: AppSpacing.s32,
                ),
                children: [
                  Padding(
                    padding: sidePadding,
                    child: Entrance(
                      child: Text(
                        l10n.exploreTitle,
                        style: context.textTheme.headlineSmall,
                      ),
                    ),
                  ),
                  const Gap(AppSpacing.s16),
                  const Padding(
                    padding: sidePadding,
                    child: Entrance(index: 1, child: _SearchField()),
                  ),
                  const Gap(AppSpacing.s32),
                  Padding(
                    padding: sidePadding,
                    child: Entrance(
                      index: 2,
                      child: ExploreSectionHeader(
                        eyebrow: l10n.exploreCategoryEyebrow,
                        color: _liveColor,
                        title: l10n.exploreCategoryTitle,
                        subtitle: l10n.exploreCategorySubtitle,
                      ),
                    ),
                  ),
                  const Gap(AppSpacing.s16),
                  Padding(
                    padding: sidePadding,
                    child: Entrance(
                      index: 3,
                      child: ExploreCategoryChips(
                        categories: state.categories.items,
                        selectedId: state.selectedCategoryId,
                        isLoading:
                            state.categories.status ==
                            ExploreSectionStatus.loading,
                        onSelected: (id) => unawaited(cubit.selectCategory(id)),
                      ),
                    ),
                  ),
                  const Gap(AppSpacing.s24),
                  ExploreRow(
                    section: state.categoryClasses,
                    cardWidth: cardWidth,
                    emptyMessage: l10n.classesEmpty,
                    itemBuilder: (context, item, _) =>
                        ExploreClassCard(item: item, width: cardWidth),
                  ),
                  const Gap(AppSpacing.s48),
                  Padding(
                    padding: sidePadding,
                    child: ExploreSectionHeader(
                      eyebrow: l10n.exploreLiveEyebrow,
                      color: _liveColor,
                      title: l10n.exploreLiveTitle,
                      subtitle: l10n.exploreLiveSubtitle,
                    ),
                  ),
                  const Gap(AppSpacing.s24),
                  ExploreRow(
                    section: state.ongoing,
                    cardWidth: cardWidth,
                    emptyMessage: l10n.classesEmpty,
                    itemBuilder: (context, item, _) =>
                        ExploreClassCard(item: item, width: cardWidth),
                  ),
                  const Gap(AppSpacing.s48),
                  Padding(
                    padding: sidePadding,
                    child: ExploreSectionHeader(
                      eyebrow: l10n.exploreUpcomingEyebrow,
                      color: _upcomingColor,
                      title: l10n.exploreUpcomingTitle,
                      subtitle: l10n.exploreUpcomingSubtitle,
                    ),
                  ),
                  const Gap(AppSpacing.s24),
                  ExploreRow(
                    section: state.upcoming,
                    cardWidth: cardWidth,
                    emptyMessage: l10n.classesEmpty,
                    itemBuilder: (context, item, _) => ExploreClassCard(
                      item: item,
                      width: cardWidth,
                      kind: ExploreClassCardKind.upcoming,
                    ),
                  ),
                  const Gap(AppSpacing.s48),
                  Padding(
                    padding: sidePadding,
                    child: ExploreSectionHeader(
                      eyebrow: l10n.exploreEducatorsEyebrow,
                      color: _educatorsColor,
                      title: l10n.exploreEducatorsTitle,
                      subtitle: l10n.exploreEducatorsSubtitle,
                    ),
                  ),
                  const Gap(AppSpacing.s24),
                  ExploreRow(
                    section: state.educators,
                    cardWidth: cardWidth,
                    emptyMessage: l10n.exploreEducatorsEmpty,
                    itemBuilder: (context, educator, index) =>
                        ExploreEducatorCard(
                          educator: educator,
                          width: cardWidth,
                          index: index,
                        ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofillHints: null,
      readOnly: true,
      onTap: () {
        AppHaptics.selection();
        unawaited(context.pushNamed(RouteNames.classSearch));
      },
      decoration: InputDecoration(
        hintText: context.l10n.dashboardSearchHint,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(14),
          child: Assets.icons.searchIcon.svg(width: 20, height: 20),
        ),
      ),
    );
  }
}
