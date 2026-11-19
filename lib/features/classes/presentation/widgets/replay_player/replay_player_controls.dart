import 'dart:async';

import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/widgets/replay_player/replay_seek_bar.dart';
import 'package:lengoal/features/classes/presentation/widgets/replay_player/replay_speed_sheet.dart';
import 'package:lengoal/features/classes/presentation/widgets/replay_player/replay_time.dart';
import 'package:video_player/video_player.dart';

class ReplayPlayerControls extends StatefulWidget {
  const new({
    required this.controller,
    required this.fullscreen,
    required this.title,
    required this.onToggleFullscreen,
    required this.onBack,
    this.onClose,
    super.key,
  });

  final VideoPlayerController controller;
  final bool fullscreen;
  final String title;
  final VoidCallback onToggleFullscreen;
  final VoidCallback onBack;
  final VoidCallback? onClose;

  @override
  State<ReplayPlayerControls> createState() => _ReplayPlayerControlsState();
}

class _ReplayPlayerControlsState extends State<ReplayPlayerControls> {
  static const Duration _skip = Duration(seconds: 10);
  static const Duration _hideAfter = Duration(seconds: 3);

  bool _visible = true;
  bool _scrubbing = false;
  Timer? _hideTimer;
  Timer? _flashTimer;
  int _flashSeconds = 0;
  Offset? _doubleTapAt;

  VideoPlayerValue get _value => widget.controller.value;

  @override
  void initState() {
    super.initState();
    _scheduleHide();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _flashTimer?.cancel();
    super.dispose();
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(_hideAfter, () {
      if (!mounted || _scrubbing || !_value.isPlaying) return;
      setState(() => _visible = false);
    });
  }

  void _toggleVisible() {
    setState(() => _visible = !_visible);
    if (_visible) _scheduleHide();
  }

  void _poke() {
    if (!_visible) setState(() => _visible = true);
    _scheduleHide();
  }

  Future<void> _togglePlay() async {
    AppHaptics.selection();
    _poke();
    final value = _value;
    if (_isEnded(value)) {
      await widget.controller.seekTo(Duration.zero);
      await widget.controller.play();
    } else if (value.isPlaying) {
      await widget.controller.pause();
    } else {
      await widget.controller.play();
    }
  }

  Future<void> _seekBy(Duration offset) async {
    final value = _value;
    var target = value.position + offset;
    if (target < Duration.zero) target = Duration.zero;
    if (target > value.duration) target = value.duration;
    await widget.controller.seekTo(target);
  }

  void _onDoubleTap() {
    final at = _doubleTapAt;
    final width = context.size?.width;
    if (at == null || width == null) return;
    final forward = at.dx > width / 2;
    AppHaptics.selection();
    unawaited(_seekBy(forward ? _skip : -_skip));
    final step = _skip.inSeconds * (forward ? 1 : -1);
    setState(() {
      final sameSide = _flashSeconds == 0 || (_flashSeconds > 0) == forward;
      _flashSeconds = sameSide ? _flashSeconds + step : step;
    });
    _flashTimer?.cancel();
    _flashTimer = Timer(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _flashSeconds = 0);
    });
  }

  Future<void> _pickSpeed() async {
    _hideTimer?.cancel();
    final speed = await showReplaySpeedSheet(
      context,
      current: _value.playbackSpeed,
    );
    if (speed != null) await widget.controller.setPlaybackSpeed(speed);
    _scheduleHide();
  }

  static bool _isEnded(VideoPlayerValue value) =>
      value.isCompleted ||
      (value.duration > Duration.zero &&
          value.position >= value.duration &&
          !value.isPlaying);

  @override
  Widget build(BuildContext context) {
    final value = _value;
    final showControls = _visible || !value.isPlaying || _isEnded(value);
    final scaler = MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.4);
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: scaler),
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggleVisible,
            onDoubleTapDown: (details) => _doubleTapAt = details.localPosition,
            onDoubleTap: _onDoubleTap,
          ),
          IgnorePointer(
            child: AnimatedOpacity(
              opacity: showControls ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: const ColoredBox(color: Color(0x66000000)),
            ),
          ),
          if (_flashSeconds != 0)
            IgnorePointer(child: _SeekFlash(seconds: _flashSeconds)),
          AnimatedOpacity(
            opacity: showControls ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !showControls,
              child: _ControlsLayer(
                value: value,
                fullscreen: widget.fullscreen,
                title: widget.title,
                ended: _isEnded(value),
                onBack: widget.onBack,
                onClose: widget.onClose,
                onTogglePlay: () => unawaited(_togglePlay()),
                onRewind: () {
                  AppHaptics.selection();
                  _poke();
                  unawaited(_seekBy(-_skip));
                },
                onForward: () {
                  AppHaptics.selection();
                  _poke();
                  unawaited(_seekBy(_skip));
                },
                onSpeed: () => unawaited(_pickSpeed()),
                onToggleFullscreen: () {
                  AppHaptics.selection();
                  _poke();
                  widget.onToggleFullscreen();
                },
                seekBar: ReplaySeekBar(
                  value: value,
                  onScrubStart: () {
                    _scrubbing = true;
                    _hideTimer?.cancel();
                  },
                  onScrubEnd: (position) async {
                    _scrubbing = false;
                    await widget.controller.seekTo(position);
                    _scheduleHide();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlsLayer extends StatelessWidget {
  const new({
    required this.value,
    required this.fullscreen,
    required this.title,
    required this.ended,
    required this.onBack,
    required this.onTogglePlay,
    required this.onRewind,
    required this.onForward,
    required this.onSpeed,
    required this.onToggleFullscreen,
    required this.seekBar,
    this.onClose,
  });

  final VideoPlayerValue value;
  final bool fullscreen;
  final String title;
  final bool ended;
  final VoidCallback onBack;
  final VoidCallback onTogglePlay;
  final VoidCallback onRewind;
  final VoidCallback onForward;
  final VoidCallback onSpeed;
  final VoidCallback onToggleFullscreen;
  final Widget seekBar;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final speedLabel = formatReplaySpeed(value.playbackSpeed);
    final timeStyle = context.textTheme.labelMedium?.copyWith(
      color: Colors.white,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final close = onClose;
    const compact = VisualDensity.compact;
    final content = Column(
      children: [
        Row(
          children: [
            if (fullscreen)
              IconButton(
                onPressed: onBack,
                color: Colors.white,
                visualDensity: compact,
                icon: const Icon(Icons.arrow_back),
              )
            else
              const Gap(AppSpacing.s16),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    (fullscreen
                            ? context.textTheme.titleMedium
                            : context.textTheme.labelLarge)
                        ?.copyWith(color: Colors.white),
              ),
            ),
            if (!fullscreen && close != null)
              IconButton(
                onPressed: close,
                color: Colors.white,
                visualDensity: compact,
                icon: const Icon(Icons.close),
              )
            else
              const Gap(AppSpacing.s16),
          ],
        ),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _RoundButton(icon: Icons.replay_10, onPressed: onRewind),
                const Gap(AppSpacing.s32),
                if (value.isBuffering && !ended)
                  const SizedBox.square(
                    dimension: 64,
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.s16),
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  )
                else
                  _RoundButton(
                    icon: ended
                        ? Icons.replay
                        : value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    size: 56,
                    onPressed: onTogglePlay,
                  ),
                const Gap(AppSpacing.s32),
                _RoundButton(icon: Icons.forward_10, onPressed: onForward),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.s16),
          child: Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${formatReplayTime(value.position)} / '
                    '${formatReplayTime(value.duration)}',
                    style: timeStyle,
                  ),
                ),
              ),
              TextButton(
                onPressed: onSpeed,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  visualDensity: compact,
                  minimumSize: const Size(40, 32),
                ),
                child: Text(speedLabel, style: timeStyle),
              ),
              IconButton(
                onPressed: onToggleFullscreen,
                color: Colors.white,
                visualDensity: compact,
                icon: Icon(
                  fullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                ),
              ),
            ],
          ),
        ),
        seekBar,
        Gap(fullscreen ? AppSpacing.s16 : AppSpacing.s2),
      ],
    );
    return fullscreen ? SafeArea(child: content) : content;
  }
}

class _RoundButton extends StatelessWidget {
  const new({required this.icon, required this.onPressed, this.size = 36});

  final IconData icon;
  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black38,
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onPressed,
        iconSize: size * 0.7,
        color: Colors.white,
        constraints: BoxConstraints.tight(Size.square(size + 8)),
        icon: Icon(icon),
      ),
    );
  }
}

class _SeekFlash extends StatelessWidget {
  const new({required this.seconds});

  final int seconds;

  @override
  Widget build(BuildContext context) {
    final forward = seconds > 0;
    return Align(
      alignment: forward ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s48),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: AppSpacing.s8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  forward ? Icons.fast_forward : Icons.fast_rewind,
                  color: Colors.white,
                  size: 20,
                ),
                const Gap(AppSpacing.s4),
                Text(
                  '${forward ? '+' : '−'}${seconds.abs()}s',
                  style: context.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
