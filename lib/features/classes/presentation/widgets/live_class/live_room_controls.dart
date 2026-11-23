import 'package:lengoal/core/core.dart';

class LiveRoomControls extends StatelessWidget {
  const new({
    required this.showDevices,
    required this.showSignals,
    required this.micOn,
    required this.cameraOn,
    required this.handRaised,
    required this.busy,
    required this.onMic,
    required this.onCamera,
    required this.onFlipCamera,
    required this.onHand,
    required this.onReact,
    required this.raisedHands,
    required this.onPeople,
    required this.unreadChat,
    required this.onChat,
    super.key,
  });

  final int raisedHands;
  final VoidCallback onPeople;
  final int unreadChat;
  final VoidCallback onChat;

  final bool showDevices;
  final bool showSignals;
  final bool micOn;
  final bool cameraOn;
  final bool handRaised;
  final bool busy;
  final VoidCallback onMic;
  final VoidCallback onCamera;
  final VoidCallback onFlipCamera;
  final VoidCallback onHand;
  final VoidCallback onReact;

  static const Color handColor = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final buttons = <Widget>[
      if (showDevices) ...[
        _RoundButton(
          icon: micOn ? Icons.mic : Icons.mic_off,
          label: micOn ? l10n.liveClassMuteMic : l10n.liveClassUnmuteMic,
          active: micOn,
          onTap: busy ? null : onMic,
        ),
        _RoundButton(
          icon: cameraOn ? Icons.videocam : Icons.videocam_off,
          label: cameraOn ? l10n.liveClassCameraOff : l10n.liveClassCameraOn,
          active: cameraOn,
          onTap: busy ? null : onCamera,
        ),
        if (cameraOn)
          _RoundButton(
            icon: Icons.cameraswitch_outlined,
            label: l10n.liveClassFlipCamera,
            active: false,
            onTap: busy ? null : onFlipCamera,
          ),
      ],
      _Badged(
        badge: unreadChat == 0
            ? null
            : unreadChat < 10
            ? '$unreadChat'
            : '9+',
        color: AppColors.errorRed,
        textColor: Colors.white,
        child: _RoundButton(
          icon: Icons.chat_bubble_outline,
          label: l10n.liveClassChat,
          active: false,
          onTap: onChat,
        ),
      ),
      if (showSignals) ...[
        _RoundButton(
          icon: handRaised ? Icons.back_hand : Icons.back_hand_outlined,
          label: handRaised ? l10n.liveClassLowerHand : l10n.liveClassRaiseHand,
          active: handRaised,
          activeColor: handColor,
          onTap: onHand,
        ),
        _RoundButton(
          icon: Icons.add_reaction_outlined,
          label: l10n.liveClassReact,
          active: false,
          onTap: onReact,
        ),
      ],
      _Badged(
        badge: raisedHands > 0 ? '✋ $raisedHands' : null,
        color: handColor,
        textColor: Colors.black87,
        child: _RoundButton(
          icon: Icons.people_alt_outlined,
          label: l10n.liveClassPeople,
          active: false,
          onTap: onPeople,
        ),
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) => _ControlSize(
        size: _fitSize(constraints.maxWidth, buttons.length),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s16,
            12,
            AppSpacing.s16,
            AppSpacing.s16,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: (constraints.maxWidth - AppSpacing.s32).clamp(
                0,
                double.infinity,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < buttons.length; i++) ...[
                  if (i > 0) const Gap(_gap),
                  buttons[i],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const double _gap = 12;
  static const double _maxSize = 52;
  static const double _minSize = 44;

  static double _fitSize(double width, int count) {
    if (count == 0 || !width.isFinite) return _maxSize;
    final available = width - AppSpacing.s32 - _gap * (count - 1);
    return (available / count).clamp(_minSize, _maxSize);
  }
}

class _ControlSize extends InheritedWidget {
  const new({required this.size, required super.child});

  final double size;

  static double of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ControlSize>()?.size ?? 52;

  @override
  bool updateShouldNotify(_ControlSize oldWidget) => size != oldWidget.size;
}

class _Badged extends StatelessWidget {
  const new({
    required this.child,
    required this.badge,
    required this.color,
    required this.textColor,
  });

  final Widget child;
  final String? badge;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final text = badge;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (text != null)
          Positioned(
            top: -6,
            right: -6,
            child: IgnorePointer(
              child: Container(
                constraints: const BoxConstraints(minWidth: 20),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const new({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.activeColor = Colors.white,
  });

  final IconData icon;
  final String label;
  final bool active;
  final Color activeColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        toggled: active,
        label: label,
        excludeSemantics: true,
        child: Material(
          color: active ? activeColor : Colors.white12,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap == null
                ? null
                : () {
                    AppHaptics.selection();
                    onTap!();
                  },
            child: SizedBox.square(
              dimension: _ControlSize.of(context),
              child: Icon(icon, color: active ? Colors.black87 : Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
