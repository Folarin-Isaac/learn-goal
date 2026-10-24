import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/models/class_summary.dart';

class ClassThumbnail extends StatefulWidget {
  const new({
    required this.item,
    this.showFavorite = false,
    this.playBadgeAlignment = Alignment.center,
    super.key,
  });

  final ClassSummary item;
  final bool showFavorite;
  final Alignment playBadgeAlignment;

  @override
  State<ClassThumbnail> createState() => _ClassThumbnailState();
}

class _ClassThumbnailState extends State<ClassThumbnail> {
  late bool _isFavorite = widget.item.isFavorite;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.r12),
          child: Container(
            color: widget.item.thumbnailColor,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: widget.playBadgeAlignment,
            child: Padding(
              padding: widget.playBadgeAlignment == Alignment.center
                  ? EdgeInsets.zero
                  : const EdgeInsets.all(AppSpacing.s8),
              child: const _PlayBadge(),
            ),
          ),
        ),
        if (widget.showFavorite)
          Positioned(
            right: AppSpacing.s8,
            bottom: AppSpacing.s8,
            child: GestureDetector(
              onTap: () {
                AppHaptics.selection();
                setState(() => _isFavorite = !_isFavorite);
              },
              child: _FavoriteBadge(isFavorite: _isFavorite),
            ),
          ),
      ],
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
