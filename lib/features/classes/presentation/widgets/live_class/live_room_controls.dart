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
    super.key,
  });

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
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.s16,
        horizontal: AppSpacing.s8,
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < buttons.length; i++) ...[
              if (i > 0) const Gap(AppSpacing.s16),
              buttons[i],
            ],
          ],
        ),
      ),
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
              dimension: 56,
              child: Icon(icon, color: active ? Colors.black87 : Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
