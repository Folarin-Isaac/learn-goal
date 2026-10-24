import 'package:flutter/material.dart';
import 'package:lengoal/core/motion/app_motion.dart';

class Entrance extends StatefulWidget {
  const new({
    required this.child,
    super.key,
    this.index = 0,
    this.delay = Duration.zero,
    this.offset = const Offset(0, 14),
    this.duration = AppMotion.base,
  });

  final Widget child;
  final int index;
  final Duration delay;
  final Offset offset;
  final Duration duration;

  static const int _maxStaggered = 10;

  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _controller,
    curve: AppMotion.enter,
  );
  bool _scheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_scheduled) return;
    _scheduled = true;
    if (AppMotion.reduced(context)) {
      _controller.value = 1;
      return;
    }
    final step = widget.index.clamp(0, Entrance._maxStaggered);
    final wait = widget.delay + AppMotion.stagger * step;
    if (wait == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(wait, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      child: widget.child,
      builder: (context, child) {
        final t = _curve.value;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: widget.offset * (1 - t),
            child: child,
          ),
        );
      },
    );
  }
}

class StaggeredColumn extends StatelessWidget {
  const new({
    required this.children,
    super.key,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.delay = Duration.zero,
  });

  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: [
        for (var i = 0; i < children.length; i++)
          Entrance(index: i, delay: delay, child: children[i]),
      ],
    );
  }
}
