import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lengoal/core/theme/app_colors.dart';

enum SnackType { success, error, info, warning }

class AppSnackbar {
  const new();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const Duration _duration = Duration(seconds: 4);

  static OverlayEntry? _currentEntry;

  static void show(String message, {SnackType type = SnackType.info}) {
    final overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    _currentEntry?.remove();
    _currentEntry = null;

    late final OverlayEntry entry;
    void dismiss() {
      if (_currentEntry != entry) return;
      entry.remove();
      _currentEntry = null;
    }

    entry = OverlayEntry(
      builder: (context) => _TopSnackbar(
        message: message,
        type: type,
        duration: _duration,
        onDismiss: dismiss,
      ),
    );
    _currentEntry = entry;
    overlay.insert(entry);
  }

  static void success(String message) => show(message, type: SnackType.success);
  static void error(String message) => show(message, type: SnackType.error);
  static void info(String message) => show(message);
  static void warning(String message) => show(message, type: SnackType.warning);
}

class _SnackStyle {
  const new({required this.icon, required this.accent});

  final IconData icon;
  final Color accent;
}

_SnackStyle _styleFor(SnackType type) => switch (type) {
  SnackType.success => const _SnackStyle(
    icon: Icons.check_rounded,
    accent: Color(0xFF16A34A),
  ),
  SnackType.error => const _SnackStyle(
    icon: Icons.close_rounded,
    accent: Color(0xFFDC2626),
  ),
  SnackType.warning => const _SnackStyle(
    icon: Icons.priority_high_rounded,
    accent: Color(0xFFD97706),
  ),
  SnackType.info => const _SnackStyle(
    icon: Icons.info_rounded,
    accent: AppColors.brandPrimary,
  ),
};

class _TopSnackbar extends StatefulWidget {
  const new({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
  });

  final String message;
  final SnackType type;
  final Duration duration;
  final VoidCallback onDismiss;

  @override
  State<_TopSnackbar> createState() => _TopSnackbarState();
}

class _TopSnackbarState extends State<_TopSnackbar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final CurvedAnimation _entrance = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.15, curve: Curves.easeOutCubic),
  );

  @override
  void initState() {
    super.initState();
    unawaited(_controller.forward().whenComplete(widget.onDismiss));
  }

  @override
  void dispose() {
    _entrance.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.stop();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _entrance,
          builder: (context, child) => Opacity(
            opacity: _entrance.value,
            child: Transform.translate(
              offset: Offset(0, -24 * (1 - _entrance.value)),
              child: child,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _SnackbarCard(
              message: widget.message,
              type: widget.type,
              progress: _controller,
              onClose: _dismiss,
            ),
          ),
        ),
      ),
    );
  }
}

class _SnackbarCard extends StatelessWidget {
  const new({
    required this.message,
    required this.type,
    required this.progress,
    required this.onClose,
  });

  final String message;
  final SnackType type;
  final Animation<double> progress;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final style = _styleFor(type);
    final cardColor = isDark ? const Color(0xFF1B1E25) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1F2937);

    return Material(
      color: Colors.transparent,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.borderGray200.withValues(alpha: 0.6),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.5, end: 1),
                    duration: const Duration(milliseconds: 420),
                    curve: Curves.easeOutBack,
                    builder: (context, scale, child) =>
                        Transform.scale(scale: scale, child: child),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: style.accent.withValues(
                          alpha: isDark ? 0.18 : 0.12,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(style.icon, size: 18, color: style.accent),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        message,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: onClose,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: textColor.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedBuilder(
              animation: progress,
              builder: (context, _) => Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: (1 - progress.value).clamp(0, 1),
                  child: Container(
                    height: 3,
                    color: style.accent.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
