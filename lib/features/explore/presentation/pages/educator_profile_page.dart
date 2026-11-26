import 'dart:async';

import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/models/class_detail.dart';
import 'package:lengoal/features/explore/domain/entities/educator_profile.dart';
import 'package:lengoal/features/explore/presentation/bloc/educator_profile_cubit.dart';
import 'package:lengoal/features/explore/presentation/bloc/explore_cubit.dart';
import 'package:lengoal/features/explore/presentation/widgets/educator_profile/educator_profile_hero_card.dart';
import 'package:lengoal/features/explore/presentation/widgets/educator_profile/educator_profile_stats_card.dart';
import 'package:lengoal/features/explore/presentation/widgets/educator_profile/educator_profile_text_card.dart';
import 'package:lengoal/features/explore/presentation/widgets/explore_class_card.dart';
import 'package:lengoal/features/explore/presentation/widgets/explore_row.dart';

class EducatorProfilePage extends StatelessWidget {
  const new({required this.educatorId, super.key});

  final String educatorId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<EducatorProfileCubit>();
        unawaited(cubit.load(educatorId));
        return cubit;
      },
      child: _EducatorProfileView(educatorId: educatorId),
    );
  }
}

class _EducatorProfileView extends StatelessWidget {
  const new({required this.educatorId});

  final String educatorId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s16,
                AppSpacing.s8,
                AppSpacing.s16,
                AppSpacing.s8,
              ),
              child: Row(
                children: [
                  const AppBackButton(),
                  const Gap(12),
                  Expanded(
                    child: Text(
                      context.l10n.educatorProfileTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<EducatorProfileCubit, EducatorProfileState>(
                builder: (context, state) {
                  final cubit = context.read<EducatorProfileCubit>();
                  final profile = state.profile;
                  if (profile == null) {
                    if (state.status == EducatorProfileStatus.failure) {
                      return _LoadFailed(
                        onRetry: () => unawaited(cubit.load(educatorId)),
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  }
                  return RefreshIndicator(
                    onRefresh: () => cubit.load(educatorId),
                    child: _ProfileBody(profile: profile),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadFailed extends StatelessWidget {
  const new({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.educatorProfileLoadFailed,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium,
            ),
            const Gap(AppSpacing.s16),
            AppButton(
              label: context.l10n.commonRetry,
              isOutlined: true,
              height: 44,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const new({required this.profile});

  final EducatorProfile profile;

  static const double _cardWidthShare = 0.82;
  static const double _minCardWidth = 260;
  static const double _maxCardWidth = 340;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cardWidth = (MediaQuery.sizeOf(context).width * _cardWidthShare)
        .clamp(_minCardWidth, _maxCardWidth);
    const sidePadding = EdgeInsets.symmetric(horizontal: AppSpacing.s16);
    final summary = htmlToPlainText(profile.summary ?? '');
    final highlights = htmlToPlainText(profile.highlights ?? '');

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(
        top: AppSpacing.s8,
        bottom: AppSpacing.s32,
      ),
      children: [
        Padding(
          padding: sidePadding,
          child: Entrance(child: EducatorProfileHeroCard(profile: profile)),
        ),
        const Gap(AppSpacing.s16),
        Padding(
          padding: sidePadding,
          child: Entrance(
            index: 1,
            child: EducatorProfileStatsCard(profile: profile),
          ),
        ),
        if (summary.isNotEmpty) ...[
          const Gap(AppSpacing.s16),
          Padding(
            padding: sidePadding,
            child: Entrance(
              index: 2,
              child: EducatorProfileTextCard(
                title: l10n.educatorProfileAbout,
                body: summary,
              ),
            ),
          ),
        ],
        if (highlights.isNotEmpty) ...[
          const Gap(AppSpacing.s16),
          Padding(
            padding: sidePadding,
            child: Entrance(
              index: 3,
              child: EducatorProfileTextCard(
                title: l10n.educatorProfileHighlights,
                body: highlights,
              ),
            ),
          ),
        ],
        const Gap(AppSpacing.s24),
        Padding(
          padding: sidePadding,
          child: Text(
            l10n.educatorProfileActiveCohorts,
            style: context.textTheme.titleMedium,
          ),
        ),
        const Gap(12),
        ExploreRow(
          section: ExploreSection(
            status: ExploreSectionStatus.loaded,
            items: profile.activeCohorts,
          ),
          cardWidth: cardWidth,
          emptyMessage: l10n.educatorProfileNoCohorts,
          equalHeights: true,
          itemBuilder: (context, item, _) =>
              ExploreClassCard(item: item, width: cardWidth),
        ),
      ],
    );
  }
}
