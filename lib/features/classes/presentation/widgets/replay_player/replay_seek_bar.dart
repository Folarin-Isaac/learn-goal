import 'package:lengoal/core/core.dart';
import 'package:video_player/video_player.dart';

class ReplaySeekBar extends StatefulWidget {
  const new({
    required this.value,
    required this.onScrubStart,
    required this.onScrubEnd,
    super.key,
  });

  final VideoPlayerValue value;
  final VoidCallback onScrubStart;
  final ValueChanged<Duration> onScrubEnd;

  @override
  State<ReplaySeekBar> createState() => _ReplaySeekBarState();
}

class _ReplaySeekBarState extends State<ReplaySeekBar> {
  double? _dragMs;

  @override
  Widget build(BuildContext context) {
    final value = widget.value;
    final totalMs = value.duration.inMilliseconds.toDouble();
    if (totalMs <= 0) return const SizedBox(height: 24);
    final positionMs = (_dragMs ?? value.position.inMilliseconds.toDouble())
        .clamp(0.0, totalMs);
    final bufferedMs = value.buffered.isEmpty
        ? 0.0
        : value.buffered
              .map((range) => range.end.inMilliseconds.toDouble())
              .reduce((a, b) => a > b ? a : b)
              .clamp(0.0, totalMs);

    return SizedBox(
      height: 24,
      child: SliderTheme(
        data: SliderThemeData(
          trackHeight: 3,
          activeTrackColor: AppColors.brandGreen,
          inactiveTrackColor: Colors.white24,
          secondaryActiveTrackColor: Colors.white54,
          thumbColor: AppColors.brandGreen,
          overlayColor: AppColors.brandGreen.withValues(alpha: 0.2),
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
        ),
        child: Slider(
          max: totalMs,
          value: positionMs,
          secondaryTrackValue: bufferedMs,
          onChangeStart: (ms) {
            widget.onScrubStart();
            setState(() => _dragMs = ms);
          },
          onChanged: (ms) => setState(() => _dragMs = ms),
          onChangeEnd: (ms) {
            setState(() => _dragMs = null);
            widget.onScrubEnd(Duration(milliseconds: ms.round()));
          },
        ),
      ),
    );
  }
}
