import 'dart:async';

import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/models/class_summary.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_discount_text.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_thumbnail.dart';
import 'package:lengoal/features/explore/domain/entities/explore_class.dart';

enum ExploreClassCardKind { running, upcoming }

class ExploreClassCard extends StatelessWidget {
  const new({
    required this.item,
    required this.width,
    this.kind = ExploreClassCardKind.running,
    super.key,
  });

  final ExploreClass item;
  final double width;
  final ExploreClassCardKind kind;

  static const double _imageAspectRatio = 1.95;
  static const double _fillingFastShare = 0.6;

  void _open(BuildContext context) {
    AppHaptics.selection();
    unawaited(
      context.pushNamed(RouteNames.classDetails, extra: item.lengoalClass),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lengoalClass = item.lengoalClass;
    final summary = ClassSummary.fromClass(lengoalClass);
    final accent = lengoalClass.bgColorKey == null
        ? AppColors.successGreen
        : summary.thumbnailColor;

    return Pressable(
      child: GestureDetector(
        onTap: () => _open(context),
        child: Container(
          width: width,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.r16),
            border: Border.all(color: accent.withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: _imageAspectRatio,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.r12),
                      child: ClassCover(item: summary),
                    ),
                  ),
                  const Gap(12),
                  _TagChip(label: item.tag, color: accent),
                  const Gap(AppSpacing.s8),
                  Text(
                    lengoalClass.cohortName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleMedium,
                  ),
                  const Gap(AppSpacing.s4),
                  Text(
                    lengoalClass.educatorName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall,
                  ),
                  const Gap(AppSpacing.s8),
                  _progress(context),
                  const Gap(AppSpacing.s8),
                  _dates(context, summary.dateRange),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(12),
                  _priceRow(context, summary),
                  if (!summary.isSubscribed &&
                      ClassDiscountText.showsFor(summary)) ...[
                    const Gap(AppSpacing.s4),
                    ClassDiscountText(item: summary, maxLines: 2),
                  ],
                  const Gap(12),
                  AppButton(
                    label: lengoalClass.isSubscribed
                        ? context.l10n.exploreViewClass
                        : context.l10n.exploreJoinNow,
                    height: 44,
                    onPressed: () => _open(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _progress(BuildContext context) {
    final small = context.textTheme.bodySmall;
    final double value;
    final Widget label;
    if (kind == ExploreClassCardKind.upcoming) {
      final total = item.enrollmentLimit;
      value = total > 0 ? item.filledSlots / total : 0;
      label = Text(
        total > 0
            ? context.l10n.exploreSpotsFilled(item.filledSlots, total)
            : context.l10n.exploreLearners(item.filledSlots),
        style: small?.copyWith(color: AppColors.successGreen),
      );
    } else {
      value = item.completion ?? classProgress(item.lengoalClass);
      label = Row(
        children: [
          Expanded(
            child: Text(
              context.l10n.dashboardCompletedPercent((value * 100).round()),
              style: small?.copyWith(color: AppColors.successGreen),
            ),
          ),
          Text(
            context.l10n.exploreLearners(item.lengoalClass.numberOfSubscribers),
            style: small,
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        label,
        const Gap(AppSpacing.s4),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          child: LinearProgressIndicator(
            value: value.clamp(0, 1),
            minHeight: 4,
            backgroundColor: AppColors.borderGray200,
            valueColor: const AlwaysStoppedAnimation(AppColors.successGreen),
          ),
        ),
      ],
    );
  }

  Widget _dates(BuildContext context, String range) {
    final text = range.isEmpty
        ? ''
        : kind == ExploreClassCardKind.upcoming
        ? context.l10n.exploreStartsDates(range)
        : context.l10n.exploreFromDates(range);
    return Row(
      children: [
        Assets.icons.clockIcon.svg(width: 18, height: 18),
        const Gap(AppSpacing.s8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _priceRow(BuildContext context, ClassSummary summary) {
    final limit = item.enrollmentLimit;
    final isFillingFast =
        kind == ExploreClassCardKind.upcoming &&
        limit > 0 &&
        item.filledSlots / limit >= _fillingFastShare &&
        item.filledSlots < limit;
    return Row(
      children: [
        Expanded(
          child: Text(
            summary.priceLabel ?? context.l10n.dashboardFreeTag,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (isFillingFast) const _FillingFastBadge(),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const new({required this.label, required this.color});

  final String? label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = label;
    if (text == null) return const SizedBox(height: 26);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: AppSpacing.s4,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const Gap(6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FillingFastBadge extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.images.lightning.image(width: 12, height: 12),
          const Gap(2),
          Text(
            context.l10n.exploreFillingFast,
            style: context.textTheme.bodySmall?.copyWith(
              color: AppColors.errorRed,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
