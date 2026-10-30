import 'dart:async';

import 'package:lengoal/core/core.dart';

class HomeShell extends StatefulWidget {
  const new({required this.navigationShell, required this.children, super.key});

  final StatefulNavigationShell navigationShell;
  final List<Widget> children;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late final PageController _controller = PageController(
    initialPage: widget.navigationShell.currentIndex,
  );
  bool _isAnimating = false;

  int get _index => widget.navigationShell.currentIndex;

  @override
  void didUpdateWidget(HomeShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    final page = _controller.hasClients ? _controller.page?.round() : null;
    if (page != null && page != _index) {
      unawaited(_showPage(_index));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showPage(int index) async {
    if (AppMotion.reduced(context)) {
      _controller.jumpToPage(index);
      return;
    }
    _isAnimating = true;
    await _controller.animateToPage(
      index,
      duration: AppMotion.slow,
      curve: Curves.easeOutCubic,
    );
    _isAnimating = false;
  }

  void _onPageChanged(int index) {
    if (_isAnimating || index == _index) return;
    AppHaptics.selection();
    widget.navigationShell.goBranch(index);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) widget.navigationShell.goBranch(0);
      },
      child: Scaffold(
        body: PageView(
          controller: _controller,
          onPageChanged: _onPageChanged,
          children: [
            for (final child in widget.children) _KeepAlivePage(child: child),
          ],
        ),
        bottomNavigationBar: DashboardBottomNav(
          currentIndex: _index,
          onSelect: widget.navigationShell.goBranch,
        ),
      ),
    );
  }
}

class _KeepAlivePage extends StatefulWidget {
  const new({required this.child});

  final Widget child;

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
