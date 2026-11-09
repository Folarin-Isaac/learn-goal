import 'package:cached_network_image/cached_network_image.dart';
import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/domain/entities/class_educator.dart';
import 'package:lengoal/features/classes/presentation/models/class_detail.dart';

class ClassAboutTab extends StatelessWidget {
  const new({required this.detail, required this.educators, super.key});

  final ClassDetail detail;
  final List<ClassEducator> educators;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (detail.outline.isNotEmpty) ...[
            Text(
              context.l10n.classDetailsOutlineHeading,
              style: context.textTheme.titleLarge,
            ),
            const Gap(AppSpacing.s8),
            Text(detail.outline, style: context.textTheme.bodyMedium),
            const Gap(AppSpacing.s24),
          ],
          if (educators.isEmpty) ...[
            Text(
              context.l10n.classDetailsAboutInstructor(detail.item.instructor),
              style: context.textTheme.titleLarge,
            ),
            if (detail.instructorTitle.isNotEmpty) ...[
              const Gap(AppSpacing.s4),
              Text(detail.instructorTitle, style: context.textTheme.bodyMedium),
            ],
          ] else
            for (var i = 0; i < educators.length; i++) ...[
              if (i > 0) const Gap(AppSpacing.s24),
              _EducatorSection(
                educator: educators[i],
                tierName: detail.instructorTitle,
              ),
            ],
        ],
      ),
    );
  }
}

class _EducatorSection extends StatelessWidget {
  const new({required this.educator, required this.tierName});

  final ClassEducator educator;
  final String tierName;

  @override
  Widget build(BuildContext context) {
    final avatar = educator.avatar;
    final hasAvatar = avatar != null && avatar.isNotEmpty;
    final summary = educator.profileSummary?.trim() ?? '';
    final details = [
      if (tierName.isNotEmpty) tierName,
      if (educator.yearsOfExperience > 0)
        context.l10n.classDetailsYearsExperience(educator.yearsOfExperience),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.classDetailsAboutInstructor(educator.fullName),
          style: context.textTheme.titleLarge,
        ),
        const Gap(AppSpacing.s8),
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: context.colors.primary.withValues(alpha: 0.1),
              backgroundImage: hasAvatar
                  ? CachedNetworkImageProvider(avatar)
                  : null,
              child: hasAvatar
                  ? null
                  : Text(
                      educator.fullName.isEmpty ? '?' : educator.fullName[0],
                      style: context.textTheme.titleMedium?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
            ),
            const Gap(AppSpacing.s16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final line in details)
                    Text(line, style: context.textTheme.bodyMedium),
                  if (educator.reviewCount > 0)
                    Row(
                      children: [
                        Assets.icons.starIcon.svg(width: 14, height: 14),
                        const Gap(4),
                        Text(
                          educator.averageRating.toStringAsFixed(1),
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
        if (summary.isNotEmpty) ...[
          const Gap(AppSpacing.s8),
          Text(summary, style: context.textTheme.bodyMedium),
        ],
      ],
    );
  }
}
