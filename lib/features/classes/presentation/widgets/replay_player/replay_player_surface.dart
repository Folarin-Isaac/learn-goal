import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/widgets/replay_player/replay_player_controls.dart';
import 'package:video_player/video_player.dart';

class ReplayPlayerSurface extends StatelessWidget {
  const new({
    required this.controller,
    required this.failed,
    required this.fullscreen,
    required this.title,
    required this.onRetry,
    required this.onToggleFullscreen,
    required this.onBack,
    this.onClose,
    super.key,
  });

  final VideoPlayerController? controller;
  final bool failed;
  final bool fullscreen;
  final String title;
  final VoidCallback onRetry;
  final VoidCallback onToggleFullscreen;
  final VoidCallback onBack;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final current = controller;
    const spinner = Center(
      child: CircularProgressIndicator(color: Colors.white),
    );
    return ColoredBox(
      color: Colors.black,
      child: failed
          ? _PlayerError(onRetry: onRetry, onClose: onClose)
          : current == null
          ? spinner
          : ValueListenableBuilder<VideoPlayerValue>(
              key: ObjectKey(current),
              valueListenable: current,
              builder: (context, value, _) {
                if (!value.isInitialized) return spinner;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Center(
                      child: AspectRatio(
                        aspectRatio: value.aspectRatio,
                        child: VideoPlayer(current),
                      ),
                    ),
                    ReplayPlayerControls(
                      controller: current,
                      fullscreen: fullscreen,
                      title: title,
                      onToggleFullscreen: onToggleFullscreen,
                      onBack: onBack,
                      onClose: onClose,
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class _PlayerError extends StatelessWidget {
  const new({required this.onRetry, this.onClose});

  final VoidCallback onRetry;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final close = onClose;
    return Stack(
      children: [
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.white70),
                const Gap(AppSpacing.s8),
                Text(
                  context.l10n.replayPlayerLoadFailed,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const Gap(AppSpacing.s8),
                OutlinedButton(
                  onPressed: onRetry,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                  ),
                  child: Text(context.l10n.commonRetry),
                ),
              ],
            ),
          ),
        ),
        if (close != null)
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              onPressed: close,
              color: Colors.white,
              icon: const Icon(Icons.close),
            ),
          ),
      ],
    );
  }
}
