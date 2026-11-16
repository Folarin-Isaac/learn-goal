import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lengoal/core/motion/app_motion.dart';

class Pressable extends StatefulWidget {
  const new({
    required this.child,
    super.key,
    this.pressedScale = 0.97,
    this.enabled = true,
  });

  final Widget child;

  final double pressedScale;
  final bool enabled;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;
  Timer? _pressTimer;
  Timer? _releaseTimer;
  Offset _origin = Offset.zero;
  bool _moved = false;

  @override
  void dispose() {
    _pressTimer?.cancel();
    _releaseTimer?.cancel();
    super.dispose();
  }

  void _set(bool down) {
    if (!mounted || _down == down) return;
    setState(() => _down = down);
  }

  void _onDown(PointerDownEvent event) {
    if (!widget.enabled) return;
    _releaseTimer?.cancel();
    _origin = event.position;
    _moved = false;
    _pressTimer?.cancel();
    _pressTimer = Timer(kPressTimeout, () => _set(true));
  }

  void _onMove(PointerMoveEvent event) {
    if (_moved) return;
    if ((event.position - _origin).distance > kTouchSlop / 2) {
      _moved = true;
      _pressTimer?.cancel();
      _set(false);
    }
  }

  void _onUp(PointerUpEvent event) {
    final wasPending = _pressTimer?.isActive ?? false;
    _pressTimer?.cancel();
    if (wasPending && !_moved && widget.enabled) {
      _set(true);
      _releaseTimer = Timer(AppMotion.fast, () => _set(false));
      return;
    }
    _set(false);
  }

  void _onCancel(PointerCancelEvent event) {
    _pressTimer?.cancel();
    _set(false);
  }

  @override
  Widget build(BuildContext context) {
    final pressed = _down && !AppMotion.reduced(context);
    return Listener(
      onPointerDown: _onDown,
      onPointerMove: _onMove,
      onPointerUp: _onUp,
      onPointerCancel: _onCancel,
      child: AnimatedScale(
        scale: pressed ? widget.pressedScale : 1,
        duration: AppMotion.fast,
        curve: AppMotion.standard,
        child: AnimatedOpacity(
          opacity: pressed ? 0.88 : 1,
          duration: AppMotion.fast,
          child: widget.child,
        ),
      ),
    );
  }
}
