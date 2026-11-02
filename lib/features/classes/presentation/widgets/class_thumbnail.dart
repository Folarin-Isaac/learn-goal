import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/models/class_summary.dart';

class ClassThumbnail extends StatelessWidget {
  const new({
    required this.item,
    this.showFavorite = false,
    this.onFavoriteTap,
    this.playBadgeAlignment = Alignment.center,
    super.key,
  });

  final ClassSummary item;
  final bool showFavorite;
  final VoidCallback? onFavoriteTap;
  final Alignment playBadgeAlignment;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.r12),
            child: ClassCover(item: item),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: playBadgeAlignment,
            child: Padding(
              padding: playBadgeAlignment == Alignment.center
                  ? EdgeInsets.zero
                  : const EdgeInsets.all(AppSpacing.s8),
              child: const _PlayBadge(),
            ),
          ),
        ),
        if (showFavorite)
          Positioned(
            right: AppSpacing.s8,
            bottom: AppSpacing.s8,
            child: GestureDetector(
              onTap: onFavoriteTap == null
                  ? null
                  : () {
                      AppHaptics.selection();
                      onFavoriteTap!();
                    },
              child: _FavoriteBadge(isFavorite: item.isFavorite),
            ),
          ),
      ],
    );
  }
}

class ClassCover extends StatelessWidget {
  const new({required this.item, super.key});

  final ClassSummary item;

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.imageUrl;
    return ColoredBox(
      color: item.thumbnailColor,
      child: imageUrl == null
          ? const SizedBox.expand()
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.expand(),
            ),
    );
  }
}

class _PlayBadge extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Assets.icons.playIcon.svg(width: 32, height: 32);
  }
}

class _FavoriteBadge extends StatelessWidget {
  const new({required this.isFavorite});

  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    final icon = isFavorite
        ? Assets.icons.favoriteFilledIcon
        : Assets.icons.favoriteOutlineIcon;
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: icon.svg(width: 14, height: 13),
    );
  }
}
