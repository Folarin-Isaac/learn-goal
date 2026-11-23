import 'package:lengoal/core/core.dart';

class LiveRoomImmersiveStage extends StatelessWidget {
  const new({
    required this.video,
    required this.moments,
    required this.topBar,
    required this.onExit,
    this.banner,
    this.controls,
    super.key,
  });

  final Widget video;
  final Widget moments;
  final Widget topBar;
  final Widget? banner;
  final Widget? controls;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Stack(
      fit: StackFit.expand,
      children: [
        video,
        moments,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _Scrim(
            begin: Alignment.topCenter,
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [topBar, ?banner],
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _Scrim(
            begin: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(child: controls ?? const SizedBox(height: 80)),
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.s16),
                    child: Tooltip(
                      message: l10n.liveClassExitFullScreen,
                      child: Semantics(
                        button: true,
                        label: l10n.liveClassExitFullScreen,
                        excludeSemantics: true,
                        child: Material(
                          color: Colors.white12,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () {
                              AppHaptics.selection();
                              onExit();
                            },
                            child: const SizedBox.square(
                              dimension: 48,
                              child: Icon(
                                Icons.fullscreen_exit,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Scrim extends StatelessWidget {
  const new({required this.begin, required this.child});

  final Alignment begin;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: -begin,
          colors: const [Color(0xB3000000), Color(0x00000000)],
        ),
      ),
      child: child,
    );
  }
}
