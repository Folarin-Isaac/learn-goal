import 'dart:async';
import 'dart:math';

import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/bloc/live_class/live_room_signals.dart';

class LiveRoomMomentsLayer extends StatefulWidget {
  const new({required this.moments, super.key});

  final Stream<LiveRoomMoment> moments;

  @override
  State<LiveRoomMomentsLayer> createState() => _LiveRoomMomentsLayerState();
}

class _LiveRoomMomentsLayerState extends State<LiveRoomMomentsLayer>
    with TickerProviderStateMixin {
  static const int _maxFloating = 24;
  static const int _maxToasts = 3;
  static const Duration _floatDuration = Duration(milliseconds: 3000);
  static const Duration _toastDuration = Duration(seconds: 6);

  final Random _random = Random();
  final List<_Floating> _floating = [];
  final List<_Toast> _toasts = [];
  StreamSubscription<LiveRoomMoment>? _subscription;
  int _nextId = 0;

  @override
  void initState() {
    super.initState();
    _subscription = widget.moments.listen(_onMoment);
  }

  @override
  void didUpdateWidget(LiveRoomMomentsLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.moments != widget.moments) {
      unawaited(_subscription?.cancel());
      _subscription = widget.moments.listen(_onMoment);
    }
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    for (final f in _floating) {
      f.controller.dispose();
    }
    for (final t in _toasts) {
      t.timer.cancel();
    }
    super.dispose();
  }

  void _onMoment(LiveRoomMoment moment) {
    if (!mounted) return;
    switch (moment) {
      case ReactionMoment(:final emoji, :final name):
        _addFloating(emoji, name);
      case HandRaisedMoment(:final name):
        AppHaptics.selection();
        _addToast(context.l10n.liveClassRaisedHand(name));
      case HandLoweredMoment():
        _addToast(context.l10n.liveClassHandLowered);
    }
  }

  void _addFloating(String emoji, String name) {
    if (_floating.length >= _maxFloating) {
      _floating.removeAt(0).controller.dispose();
    }
    final controller = AnimationController(
      vsync: this,
      duration: _floatDuration,
    );
    final item = _Floating(
      id: _nextId++,
      emoji: emoji,
      name: name,
      x: 0.1 + _random.nextDouble() * 0.8,
      controller: controller,
    );
    setState(() => _floating.add(item));
    unawaited(
      controller.forward().whenComplete(() {
        if (!mounted) return;
        setState(() => _floating.remove(item));
        controller.dispose();
      }),
    );
  }

  void _addToast(String text) {
    final id = _nextId++;
    late final _Toast toast;
    toast = _Toast(
      id: id,
      text: text,
      timer: Timer(_toastDuration, () {
        if (mounted) setState(() => _toasts.remove(toast));
      }),
    );
    setState(() {
      _toasts.add(toast);
      while (_toasts.length > _maxToasts) {
        _toasts.removeAt(0).timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight;
          final width = constraints.maxWidth;
          return Stack(
            children: [
              for (final item in _floating)
                AnimatedBuilder(
                  key: ValueKey(item.id),
                  animation: item.controller,
                  builder: (context, child) {
                    final t = Curves.easeOutQuad.transform(
                      item.controller.value,
                    );
                    final opacity = t < 0.6 ? 1.0 : (1 - (t - 0.6) / 0.4);
                    final scale = t < 0.1 ? 0.4 + t * 8 : 1.0 + 0.2 * t;
                    return Positioned(
                      left: item.x * width - 40,
                      bottom: AppSpacing.s16 + t * height * 0.8,
                      width: 80,
                      child: Opacity(
                        opacity: opacity.clamp(0, 1),
                        child: Transform.scale(scale: scale, child: child),
                      ),
                    );
                  },
                  child: _FloatingReaction(emoji: item.emoji, name: item.name),
                ),
              Positioned(
                top: AppSpacing.s8,
                left: AppSpacing.s16,
                right: AppSpacing.s16,
                child: Column(
                  children: [
                    for (final toast in _toasts)
                      Padding(
                        key: ValueKey(toast.id),
                        padding: const EdgeInsets.only(bottom: AppSpacing.s8),
                        child: _HandToast(text: toast.text),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Floating {
  new({
    required this.id,
    required this.emoji,
    required this.name,
    required this.x,
    required this.controller,
  });

  final int id;
  final String emoji;
  final String name;
  final double x;
  final AnimationController controller;
}

class _Toast {
  new({required this.id, required this.text, required this.timer});

  final int id;
  final String text;
  final Timer timer;
}

class _FloatingReaction extends StatelessWidget {
  const new({required this.emoji, required this.name});

  final String emoji;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 36)),
        if (name.isNotEmpty) ...[
          const Gap(AppSpacing.s4),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s8,
              vertical: AppSpacing.s2,
            ),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            ),
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.labelSmall?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _HandToast extends StatelessWidget {
  const new({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xF2121218),
        borderRadius: BorderRadius.circular(AppSpacing.r12),
        border: Border.all(color: const Color(0x80F59E0B)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('✋', style: TextStyle(fontSize: 20)),
          const Gap(AppSpacing.s8),
          Flexible(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
