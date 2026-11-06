import 'package:flutter/material.dart';
import 'package:lengoal/core/motion/app_motion.dart';
import 'package:lengoal/core/theme/app_colors.dart';

class SplashOverlay extends StatefulWidget {
  const new({required this.child, super.key});

  final Widget child;

  static const double logoSize = 240 * 40 / 108;

  @override
  State<SplashOverlay> createState() => _SplashOverlayState();
}

class _SplashOverlayState extends State<SplashOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  );

  bool _started = false;
  bool _done = false;

  late final Animation<double> _dotLift = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween<double>(
        begin: 0,
        end: -0.42,
      ).chain(CurveTween(curve: Curves.easeOutCubic)),
      weight: 40,
    ),
    TweenSequenceItem(
      tween: Tween<double>(
        begin: -0.42,
        end: 0,
      ).chain(CurveTween(curve: Curves.easeInCubic)),
      weight: 30,
    ),
    TweenSequenceItem(tween: ConstantTween<double>(0), weight: 30),
  ]).animate(_interval(0.1, 0.62));

  late final Animation<double> _dotSquash = TweenSequence<double>([
    TweenSequenceItem(tween: ConstantTween<double>(1), weight: 70),
    TweenSequenceItem(
      tween: Tween<double>(
        begin: 1,
        end: 0.78,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 10,
    ),
    TweenSequenceItem(
      tween: Tween<double>(
        begin: 0.78,
        end: 1,
      ).chain(CurveTween(curve: Curves.easeOutBack)),
      weight: 20,
    ),
  ]).animate(_interval(0.1, 0.62));

  late final Animation<double> _logoScale = Tween<double>(
    begin: 1,
    end: 1.12,
  ).animate(_interval(0.66, 1, AppMotion.exit));

  late final Animation<double> _logoOpacity = Tween<double>(
    begin: 1,
    end: 0,
  ).animate(_interval(0.66, 0.9, AppMotion.exit));

  late final Animation<double> _backgroundOpacity = Tween<double>(
    begin: 1,
    end: 0,
  ).animate(_interval(0.72, 1, AppMotion.standard));

  Animation<double> _interval(
    double begin,
    double end, [
    Curve curve = Curves.linear,
  ]) {
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(begin, end, curve: curve),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _done = true);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (AppMotion.reduced(context)) {
      _controller.value = 0.66;
      _controller.animateTo(1, duration: AppMotion.slow);
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        widget.child,
        if (!_done)
          Positioned.fill(
            child: AbsorbPointer(
              child: ExcludeSemantics(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return ColoredBox(
                      color: AppColors.brandPrimary.withValues(
                        alpha: _backgroundOpacity.value,
                      ),
                      child: Center(
                        child: Opacity(
                          opacity: _logoOpacity.value,
                          child: Transform.scale(
                            scale: _logoScale.value,
                            child: CustomPaint(
                              size: const Size.square(SplashOverlay.logoSize),
                              painter: _LogoPainter(
                                dotLift: _dotLift.value,
                                dotSquash: _dotSquash.value,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _LogoPainter extends CustomPainter {
  const new({required this.dotLift, required this.dotSquash});

  final double dotLift;
  final double dotSquash;

  static const double _unit = 76;
  static const List<Offset> _bar = [
    Offset(25.332, 0),
    Offset(25.332, 76),
    Offset(0, 76),
    Offset(0, 25.3325),
  ];
  static const List<Offset> _base = [
    Offset(76, 50.6646),
    Offset(76, 76),
    Offset(50.668, 76),
    Offset(25.332, 50.6646),
  ];
  static const Offset _dotCenter = Offset(63.3319, 25.3324);
  static const double _dotRadius = 12.664;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / _unit;
    final white = Paint()..color = Colors.white;
    canvas
      ..drawPath(_polygon(_bar, k), white)
      ..drawPath(_polygon(_base, k), white);

    final radius = _dotRadius * k;
    final squashY = dotSquash;
    final squashX = 2 - dotSquash;
    final center = Offset(
      _dotCenter.dx * k,
      _dotCenter.dy * k + dotLift * size.height + radius * (1 - squashY),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: radius * 2 * squashX,
        height: radius * 2 * squashY,
      ),
      Paint()..color = AppColors.brandGreen,
    );
  }

  Path _polygon(List<Offset> points, double k) {
    return Path()..addPolygon([for (final p in points) p * k], true);
  }

  @override
  bool shouldRepaint(_LogoPainter oldDelegate) =>
      oldDelegate.dotLift != dotLift || oldDelegate.dotSquash != dotSquash;
}
