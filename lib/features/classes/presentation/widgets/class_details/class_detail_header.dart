import 'dart:async';

import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/bloc/class_detail/class_detail_bloc.dart';
import 'package:lengoal/features/classes/presentation/models/class_detail.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_list_loader.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_thumbnail.dart';

class ClassDetailHeader extends StatelessWidget {
  const new({required this.detail, required this.isSharing, super.key});

  final ClassDetail detail;
  final bool isSharing;

  @override
  Widget build(BuildContext context) {
    final item = detail.item;
    final isFree = item.priceLabel == null;
    final tagBackground = isFree
        ? const Color(0xFFDAF2E4)
        : const Color(0xFFE0EBFF);
    final tagForeground = isFree
        ? const Color(0xFF0E8C43)
        : const Color(0xFF004DE6);
    final tagIcon = isFree
        ? Assets.icons.freeTagIcon
        : Assets.icons.premiumTagIcon;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.r16),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: ClassCover(item: item),
          ),
        ),
        const Gap(AppSpacing.s16),
        Row(
          children: [
            Expanded(
              child: Text(item.title, style: context.textTheme.headlineSmall),
            ),
            IconButton(
              onPressed: isSharing
                  ? null
                  : () {
                      AppHaptics.selection();
                      context.read<ClassDetailBloc>().add(
                        const ClassDetailShareRequested(),
                      );
                    },
              icon: isSharing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Assets.icons.shareIcon.svg(width: 20, height: 20),
            ),
          ],
        ),
        Text(item.dateRange, style: context.textTheme.bodyMedium),
        const Gap(AppSpacing.s4),
        Text(item.instructor, style: context.textTheme.bodyLarge),
        if (detail.reviewCount > 0) ...[
          const Gap(AppSpacing.s8),
          Row(
            children: [
              Text(
                detail.rating.toStringAsFixed(1),
                style: context.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFFF2A93B),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(AppSpacing.s4),
              for (var i = 0; i < 5; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 1),
                  child: Assets.icons.starIcon.svg(width: 14, height: 14),
                ),
              const Gap(AppSpacing.s4),
              Text(
                context.l10n.classDetailsRatingCount(detail.reviewCount),
                style: context.textTheme.bodyMedium,
              ),
            ],
          ),
        ],
        const Gap(AppSpacing.s8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: tagBackground,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  tagIcon.svg(width: 14, height: 14),
                  const Gap(4),
                  Text(
                    isFree ? context.l10n.dashboardFreeTag : item.priceLabel!,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: tagForeground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (!isFree && item.isSubscribed) ...[
              const Gap(AppSpacing.s8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDAF2E4),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  context.l10n.classDetailsStatusPaid,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF0E8C43),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (!item.isSubscribed) ...[
          const Gap(AppSpacing.s16),
          AppButton(
            label: context.l10n.classDetailsBuyNow,
            onPressed: () {
              AppHaptics.selection();
              unawaited(context.pushNamed(RouteNames.payment, extra: detail));
            },
          ),
          const Gap(AppSpacing.s8),
          SavedClassesBuilder(
            builder: (context, savedIds) {
              final isSaved = savedIds.contains(detail.source.id);
              return AppButton(
                label: isSaved
                    ? context.l10n.classDetailsUnsaveClass
                    : context.l10n.classDetailsSaveClass,
                isOutlined: true,
                onPressed: () {
                  AppHaptics.selection();
                  unawaited(
                    toggleSavedClass(
                      context,
                      detail.source,
                      save: !isSaved,
                      confirm: true,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ],
    );
  }
}
