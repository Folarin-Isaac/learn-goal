import 'package:cached_network_image/cached_network_image.dart';
import 'package:lengoal/core/core.dart';

class ReplayPoster extends StatelessWidget {
  const new({
    required this.posterUrl,
    required this.title,
    required this.onPlay,
    super.key,
  });

  final String? posterUrl;
  final String title;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final url = posterUrl;
    const blank = ColoredBox(color: Colors.black);
    return Semantics(
      button: true,
      label: title,
      child: GestureDetector(
        onTap: onPlay,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (url == null)
              blank
            else
              CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (context, _) => blank,
                errorWidget: (context, _, _) => blank,
              ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x33000000), Color(0x99000000)],
                ),
              ),
            ),
            Center(
              child: Material(
                color: Colors.black45,
                shape: const CircleBorder(),
                child: IconButton(
                  onPressed: onPlay,
                  iconSize: 40,
                  color: Colors.white,
                  icon: const Icon(Icons.play_arrow),
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.s16,
              right: AppSpacing.s16,
              bottom: 12,
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
