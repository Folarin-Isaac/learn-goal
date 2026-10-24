import 'dart:math' as math;

import 'package:lengoal/core/core.dart';

class PracticeScoreRing extends StatelessWidget {
  const new({
    required this.percent,
    required this.value,
    required this.caption,
    super.key,
    this.size = 68,
  });

  final int percent;
  final String value;
  final String caption;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(percent: percent),
        child: Center(
          child: SizedBox(
            width: size * 0.54,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    caption,
                    maxLines: 1,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontSize: 7,
                      height: 1,
                    ),
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

class _RingPainter extends CustomPainter {
  const new({required this.percent});

  final int percent;

  static const double _strokeRatio = 0.19;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.shortestSide * _strokeRatio;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: (size.shortestSide - stroke) / 2,
    );

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = Colors.white.withValues(alpha: 0.35);
    final progress = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = Colors.white;

    canvas
      ..drawCircle(rect.center, rect.width / 2, track)
      ..drawArc(
        rect,
        -math.pi / 2,
        -2 * math.pi * (percent.clamp(0, 100) / 100),
        false,
        progress,
      );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.percent != percent;
}
