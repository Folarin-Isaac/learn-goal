import 'package:cached_network_image/cached_network_image.dart';
import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/explore/domain/entities/top_educator.dart';

class ExploreEducatorCard extends StatelessWidget {
  const new({
    required this.educator,
    required this.width,
    this.index = 0,
    super.key,
  });

  final TopEducator educator;
  final double width;
  final int index;

  static const int _maxCategories = 2;
  static const List<Color> _chipColors = [
    AppColors.successGreen,
    AppColors.accentBlue,
  ];

  static const List<_BannerTheme> _themes = [
    _BannerTheme(
      background: Color(0xFFEFF6DE),
      circle: Color(0xFFDAE5C4),
      border: Color(0xFFB7D58A),
    ),
    _BannerTheme(
      background: Color(0xFFE5EEFF),
      circle: Color(0xFFCCDBFA),
      border: Color(0xFF99B8F5),
    ),
    _BannerTheme(
      background: Color(0xFFFFF1E2),
      circle: Color(0xFFF8DDBF),
      border: Color(0xFFF0BD85),
    ),
    _BannerTheme(
      background: Color(0xFFF3EBFD),
      circle: Color(0xFFE1D2F7),
      border: Color(0xFFC3A6EE),
    ),
    _BannerTheme(
      background: Color(0xFFFDEAF3),
      circle: Color(0xFFF6D0E2),
      border: Color(0xFFEDA3C5),
    ),
    _BannerTheme(
      background: Color(0xFFE3F6F2),
      circle: Color(0xFFC9EAE3),
      border: Color(0xFF8DD3C4),
    ),
  ];

  void _viewProfile(BuildContext context) {
    AppHaptics.selection();
    AppSnackbar.info(context.l10n.dashboardComingSoon);
  }

  @override
  Widget build(BuildContext context) {
    final theme = _themes[index % _themes.length];
    final categories = educator.categories.take(_maxCategories).toList();

    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.r16),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Banner(photoUrl: educator.photoUrl, theme: theme),
          const Gap(12),
          SizedBox(
            height: 28,
            child: Row(
              children: [
                for (var i = 0; i < categories.length; i++) ...[
                  if (i > 0) const Gap(AppSpacing.s8),
                  Flexible(
                    child: _CategoryChip(
                      label: categories[i],
                      color: _chipColors[i % _chipColors.length],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Gap(AppSpacing.s8),
          Row(
            children: [
              Expanded(
                child: Text(
                  educator.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleMedium,
                ),
              ),
              if (educator.rating > 0) _Rating(educator: educator),
            ],
          ),
          const Gap(AppSpacing.s4),
          Text(
            context.l10n.exploreActiveCohorts(educator.activeClassCount),
            style: context.textTheme.bodySmall,
          ),
          const Gap(12),
          AppButton(
            label: context.l10n.exploreViewProfile,
            isOutlined: true,
            height: 44,
            foregroundColor: AppColors.accentBlue,
            onPressed: () => _viewProfile(context),
          ),
        ],
      ),
    );
  }
}

class _BannerTheme {
  const new({
    required this.background,
    required this.circle,
    required this.border,
  });

  final Color background;
  final Color circle;
  final Color border;
}

class _Banner extends StatelessWidget {
  const new({required this.photoUrl, required this.theme});

  final String? photoUrl;
  final _BannerTheme theme;

  static const double _aspectRatio = 300 / 156;
  static const double _circleShare = 143 / 156;
  static const double _photoInset = 8;

  @override
  Widget build(BuildContext context) {
    final photo = photoUrl;
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    return RepaintBoundary(
      child: AspectRatio(
        aspectRatio: _aspectRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.r8),
          child: ColoredBox(
            color: theme.background,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final circleSize = constraints.maxHeight * _circleShare;
                final photoSize = circleSize - _photoInset * 2;
                final placeholder = Icon(
                  Icons.person_rounded,
                  size: photoSize * 0.6,
                  color: Colors.white,
                );
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Assets.images.educatorCardPattern.svg(fit: BoxFit.cover),
                    Center(
                      child: Container(
                        width: circleSize,
                        height: circleSize,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.circle.withValues(alpha: 0.8),
                        ),
                        child: ClipOval(
                          child: SizedBox.square(
                            dimension: photoSize,
                            child: photo == null
                                ? placeholder
                                : CachedNetworkImage(
                                    imageUrl: photo,
                                    fit: BoxFit.cover,
                                    memCacheWidth: (photoSize * pixelRatio)
                                        .round(),
                                    fadeInDuration: AppMotion.base,
                                    errorWidget: (context, url, error) =>
                                        placeholder,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const new({required this.label, required this.color});

  final String label;
  final Color color;

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
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
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

class _Rating extends StatelessWidget {
  const new({required this.educator});

  final TopEducator educator;

  @override
  Widget build(BuildContext context) {
    final small = context.textTheme.bodySmall;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          educator.rating.toStringAsFixed(1),
          style: small?.copyWith(
            color: context.colors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (educator.reviewCount > 0) ...[
          const Gap(AppSpacing.s4),
          Text(context.l10n.exploreRatings(educator.reviewCount), style: small),
        ],
        const Gap(AppSpacing.s4),
        Assets.icons.educatorStarIcon.svg(width: 16, height: 16),
      ],
    );
  }
}
