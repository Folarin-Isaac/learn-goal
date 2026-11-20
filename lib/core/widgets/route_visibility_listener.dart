import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RouteVisibilityListener extends StatefulWidget {
  const new({
    required this.routeName,
    required this.onVisible,
    required this.child,
    super.key,
  });

  final String routeName;
  final VoidCallback onVisible;
  final Widget child;

  @override
  State<RouteVisibilityListener> createState() =>
      _RouteVisibilityListenerState();
}

class _RouteVisibilityListenerState extends State<RouteVisibilityListener> {
  late final AppLifecycleListener _lifecycle;
  GoRouterDelegate? _delegate;
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _onResume);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final delegate = GoRouter.of(context).routerDelegate;
    if (identical(delegate, _delegate)) return;
    _delegate?.removeListener(_onRouteChanged);
    _delegate = delegate..addListener(_onRouteChanged);
    _visible = _isShowing;
  }

  bool get _isShowing {
    final delegate = _delegate;
    if (delegate == null || delegate.currentConfiguration.isEmpty) {
      return false;
    }
    return delegate.state.name == widget.routeName;
  }

  void _onRouteChanged() {
    final visible = _isShowing;
    if (visible && !_visible) widget.onVisible();
    _visible = visible;
  }

  void _onResume() {
    if (_isShowing) widget.onVisible();
  }

  @override
  void dispose() {
    _delegate?.removeListener(_onRouteChanged);
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
