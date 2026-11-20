import 'package:lengoal/core/core.dart';

class ChatSwipeToReply extends StatefulWidget {
  const new({
    required this.child,
    required this.onReply,
    this.enabled = true,
    super.key,
  });

  final Widget child;
  final VoidCallback onReply;
  final bool enabled;

  @override
  State<ChatSwipeToReply> createState() => _ChatSwipeToReplyState();
}

class _ChatSwipeToReplyState extends State<ChatSwipeToReply>
    with SingleTickerProviderStateMixin {
  static const double _maxDrag = 72;
  static const double _threshold = 52;
  static const double _resistance = 0.7;

  late final AnimationController _offset = AnimationController(
    vsync: this,
    upperBound: _maxDrag,
  );
  bool _armed = false;

  @override
  void dispose() {
    _offset.dispose();
    super.dispose();
  }

  void _onUpdate(DragUpdateDetails details) {
    final next = (_offset.value + details.delta.dx * _resistance).clamp(
      0.0,
      _maxDrag,
    );
    _offset.value = next;
    final armed = next >= _threshold;
    if (armed && !_armed) AppHaptics.selection();
    _armed = armed;
  }

  void _release() {
    if (_armed) widget.onReply();
    _armed = false;
    _offset.animateTo(0, duration: AppMotion.fast, curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: _onUpdate,
      onHorizontalDragEnd: (_) => _release(),
      onHorizontalDragCancel: _release,
      child: AnimatedBuilder(
        animation: _offset,
        builder: (context, child) {
          final value = _offset.value;
          final progress = (value / _threshold).clamp(0.0, 1.0);
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Opacity(
                  opacity: progress,
                  child: Transform.scale(
                    scale: 0.6 + 0.4 * progress,
                    child: Center(
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.colors.surfaceContainerHighest,
                        ),
                        child: Icon(
                          Icons.reply_rounded,
                          size: 18,
                          color: context.colors.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Transform.translate(offset: Offset(value, 0), child: child),
            ],
          );
        },
        child: widget.child,
      ),
    );
  }
}
