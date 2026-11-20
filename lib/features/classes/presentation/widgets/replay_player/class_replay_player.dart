import 'dart:async';

import 'package:flutter/services.dart';
import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/domain/entities/class_replay.dart';
import 'package:lengoal/features/classes/presentation/models/replay_resume_positions.dart';
import 'package:lengoal/features/classes/presentation/widgets/replay_player/replay_player_surface.dart';
import 'package:lengoal/features/classes/presentation/widgets/replay_player/replay_poster.dart';
import 'package:lengoal/features/classes/presentation/widgets/replay_player/replay_time.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class ClassReplayPlayer extends StatefulWidget {
  const new({
    required this.replay,
    required this.title,
    required this.onClose,
    this.autoPlay = true,
    super.key,
  });

  final ClassReplay replay;
  final String title;
  final VoidCallback onClose;
  final bool autoPlay;

  @override
  State<ClassReplayPlayer> createState() => _ClassReplayPlayerState();
}

class _ClassReplayPlayerState extends State<ClassReplayPlayer> {
  static const List<DeviceOrientation> _portrait = [
    DeviceOrientation.portraitUp,
  ];

  static const List<DeviceOrientation> _landscape = [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ];

  VideoPlayerController? _controller;
  bool _failed = false;
  bool _fullscreen = false;
  bool _wakelockOn = false;
  bool _started = false;
  Route<void>? _fullscreenRoute;

  List<String> get _sources => widget.replay.sources;

  String get _resumeKey => _sources.isEmpty ? widget.title : _sources.first;

  @override
  void initState() {
    super.initState();
    if (widget.autoPlay) _start();
  }

  void _start() {
    if (_started) return;
    _started = true;
    unawaited(SystemChrome.setPreferredOrientations(_portrait));
    unawaited(_open(0));
  }

  @override
  void dispose() {
    final route = _fullscreenRoute;
    final controller = _controller;
    if (route != null) {
      _fullscreenRoute = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (route.isActive) route.navigator?.removeRoute(route);
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _release(controller),
        );
      });
      unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
    } else {
      _release(controller);
    }
    if (_started) {
      unawaited(WakelockPlus.disable());
      unawaited(
        SystemChrome.setPreferredOrientations(DeviceOrientation.values),
      );
    }
    super.dispose();
  }

  void _release(VideoPlayerController? controller) {
    if (controller == null) return;
    final value = controller.value;
    if (value.isInitialized) {
      ReplayResumePositions.save(_resumeKey, value.position, value.duration);
    }
    controller.removeListener(_syncWakelock);
    unawaited(controller.dispose());
  }

  Future<void> _open(int index) async {
    if (index >= _sources.length) {
      if (mounted) setState(() => _failed = true);
      return;
    }
    _release(_controller);
    final url = _sources[index];
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(url),
      formatHint: url.contains('.m3u8') ? VideoFormat.hls : null,
    );
    setState(() {
      _controller = controller;
      _failed = false;
    });
    try {
      await controller.initialize();
    } on Object {
      if (!mounted || _controller != controller) return;
      await _open(index + 1);
      return;
    }
    if (!mounted || _controller != controller) return;
    controller.addListener(_syncWakelock);
    final resumeAt = ReplayResumePositions.of(_resumeKey);
    if (resumeAt != null && resumeAt < controller.value.duration) {
      await controller.seekTo(resumeAt);
      if (mounted) {
        AppSnackbar.info(
          context.l10n.replayPlayerResumed(formatReplayTime(resumeAt)),
        );
      }
    }
    await controller.play();
  }

  void _syncWakelock() {
    final playing = _controller?.value.isPlaying ?? false;
    if (playing == _wakelockOn) return;
    _wakelockOn = playing;
    unawaited(playing ? WakelockPlus.enable() : WakelockPlus.disable());
  }

  void _retry() {
    AppHaptics.selection();
    unawaited(_open(0));
  }

  void _enterFullscreen() {
    final controller = _controller;
    if (_fullscreenRoute != null || controller == null) return;
    final route = PageRouteBuilder<void>(
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (_, _, _) => Material(
        color: Colors.black,
        child: ReplayPlayerSurface(
          controller: controller,
          failed: false,
          fullscreen: true,
          title: widget.title,
          onRetry: _retry,
          onToggleFullscreen: _exitFullscreen,
          onBack: _exitFullscreen,
        ),
      ),
    );
    _fullscreenRoute = route;
    setState(() => _fullscreen = true);
    unawaited(SystemChrome.setPreferredOrientations(_landscape));
    unawaited(
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky),
    );
    unawaited(
      Navigator.of(
        context,
        rootNavigator: true,
      ).push(route).whenComplete(() => _onFullscreenClosed(route)),
    );
  }

  void _exitFullscreen() {
    final route = _fullscreenRoute;
    if (route == null) return;
    if (route.isActive) route.navigator?.removeRoute(route);
    _onFullscreenClosed(route);
  }

  void _onFullscreenClosed(Route<void> route) {
    if (_fullscreenRoute != route) return;
    _fullscreenRoute = null;
    unawaited(SystemChrome.setPreferredOrientations(_portrait));
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
    if (mounted) setState(() => _fullscreen = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_fullscreen) return const ColoredBox(color: Colors.black);
    if (!_started) {
      return ReplayPoster(
        posterUrl: widget.replay.posterUrl,
        title: widget.title,
        onPlay: () {
          AppHaptics.selection();
          setState(_start);
        },
      );
    }
    return ReplayPlayerSurface(
      controller: _controller,
      failed: _failed,
      fullscreen: false,
      title: widget.title,
      onRetry: _retry,
      onToggleFullscreen: _enterFullscreen,
      onBack: widget.onClose,
      onClose: widget.onClose,
    );
  }
}
