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

  void _set(bool down) {
    if (!widget.enabled || _down == down) return;
    setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) {
    final reduced = AppMotion.reduced(context);
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      onPointerMove: (e) {
        if (_down && e.delta.distance > 2) _set(false);
      },
      child: AnimatedScale(
        scale: _down && !reduced ? widget.pressedScale : 1,
        duration: AppMotion.fast,
        curve: AppMotion.standard,
        child: AnimatedOpacity(
          opacity: _down && !reduced ? 0.88 : 1,
          duration: AppMotion.fast,
          child: widget.child,
        ),
      ),
    );
  }
}
