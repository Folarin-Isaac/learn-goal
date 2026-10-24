import 'dart:math' as math;

import 'package:lengoal/core/core.dart';

class DashedBorderBox extends StatelessWidget {
  const new({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _DashedBorderPainter(color: AppColors.borderGray200),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.r4),
        child: ColoredBox(color: AppColors.panelGray, child: child),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const new({required this.color});

  final Color color;

  static const double _dash = 5;
  static const double _gap = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppSpacing.s1
      ..color = color;

    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(AppSpacing.r4),
    );
    final metrics = (Path()..addRRect(rect)).computeMetrics();

    for (final metric in metrics) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = math.min(distance + _dash, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}
