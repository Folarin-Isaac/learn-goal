import 'package:cached_network_image/cached_network_image.dart';
import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/models/class_summary.dart';
import 'package:lengoal/features/explore/domain/entities/educator_profile.dart';

class EducatorProfileHeroCard extends StatelessWidget {
  const new({required this.profile, super.key});

  final EducatorProfile profile;

  static const double _photoSize = 72;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final accent = profile.bgColorKey == null
        ? context.accentForeground
        : classThumbnailColor(profile.bgColorKey);
    final experience = [
      if (profile.yearsOfExperience > 0)
        l10n.educatorProfileYearsExperience(profile.yearsOfExperience),
      ?profile.experiencePeriod,
    ].join(' · ');

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Photo(url: profile.photoUrl, size: _photoSize, color: accent),
                const Gap(AppSpacing.s16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (profile.tierName != null) ...[
                        const Gap(AppSpacing.s4),
                        Text(
                          profile.tierName!,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const Gap(AppSpacing.s4),
                      _Rating(profile: profile),
                    ],
                  ),
                ),
              ],
            ),
            if (experience.isNotEmpty) ...[
              const Gap(AppSpacing.s16),
              Row(
                children: [
                  Icon(
                    Icons.work_outline_rounded,
                    size: 18,
                    color: context.colors.onSurfaceVariant,
                  ),
                  const Gap(AppSpacing.s8),
                  Expanded(
                    child: Text(
                      experience,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (profile.categories.isNotEmpty) ...[
              const Gap(12),
              Wrap(
                spacing: AppSpacing.s8,
                runSpacing: AppSpacing.s8,
                children: [
                  for (final category in profile.categories)
                    _Chip(label: category, color: AppColors.successGreen),
                ],
              ),
            ],
            if (profile.badges.isNotEmpty) ...[
              const Gap(12),
              Wrap(
                spacing: AppSpacing.s8,
                runSpacing: AppSpacing.s8,
                children: [
                  for (final badge in profile.badges)
                    _Chip(
                      label: badge,
                      color: context.accentForeground,
                      icon: Icons.verified_rounded,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  const new({required this.url, required this.size, required this.color});

  final String? url;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final photo = url;
    final placeholder = Icon(
      Icons.person_rounded,
      size: size * 0.6,
      color: Colors.white,
    );
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.35),
      ),
      child: ClipOval(
        child: photo == null
            ? placeholder
            : CachedNetworkImage(
                imageUrl: photo,
                fit: BoxFit.cover,
                memCacheWidth: (size * MediaQuery.devicePixelRatioOf(context))
                    .round(),
                fadeInDuration: AppMotion.base,
                errorWidget: (context, url, error) => placeholder,
              ),
      ),
    );
  }
}

class _Rating extends StatelessWidget {
  const new({required this.profile});

  final EducatorProfile profile;

  @override
  Widget build(BuildContext context) {
    final small = context.textTheme.bodySmall;
    return Row(
      children: [
        Assets.icons.educatorStarIcon.svg(width: 16, height: 16),
        const Gap(AppSpacing.s4),
        Text(
          profile.rating.toStringAsFixed(1),
          style: small?.copyWith(
            color: context.colors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Gap(AppSpacing.s4),
        Flexible(
          child: Text(
            context.l10n.exploreRatings(profile.reviewCount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: small,
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const new({required this.label, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon == null)
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            )
          else
            Icon(icon, size: 14, color: color),
          const Gap(6),
          Flexible(
            child: Text(
              label,
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
