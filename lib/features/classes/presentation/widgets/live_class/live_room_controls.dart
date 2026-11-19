import 'package:lengoal/core/core.dart';

class LiveRoomControls extends StatelessWidget {
  const new({
    required this.micOn,
    required this.cameraOn,
    required this.busy,
    required this.onMic,
    required this.onCamera,
    required this.onFlipCamera,
    super.key,
  });

  final bool micOn;
  final bool cameraOn;
  final bool busy;
  final VoidCallback onMic;
  final VoidCallback onCamera;
  final VoidCallback onFlipCamera;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _RoundButton(
            icon: micOn ? Icons.mic : Icons.mic_off,
            label: micOn ? l10n.liveClassMuteMic : l10n.liveClassUnmuteMic,
            active: micOn,
            onTap: busy ? null : onMic,
          ),
          const Gap(AppSpacing.s24),
          _RoundButton(
            icon: cameraOn ? Icons.videocam : Icons.videocam_off,
            label: cameraOn ? l10n.liveClassCameraOff : l10n.liveClassCameraOn,
            active: cameraOn,
            onTap: busy ? null : onCamera,
          ),
          if (cameraOn) ...[
            const Gap(AppSpacing.s24),
            _RoundButton(
              icon: Icons.cameraswitch_outlined,
              label: l10n.liveClassFlipCamera,
              active: false,
              onTap: busy ? null : onFlipCamera,
            ),
          ],
        ],
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
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        child: Material(
          color: active ? Colors.white : Colors.white12,
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
