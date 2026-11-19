import 'dart:async';

import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/domain/entities/live_class_status.dart';
import 'package:lengoal/features/classes/presentation/bloc/live_class/live_class_cubit.dart';
import 'package:lengoal/features/classes/presentation/bloc/live_class/lobby_devices.dart';
import 'package:lengoal/features/classes/presentation/models/live_class_session.dart';
import 'package:livekit_client/livekit_client.dart';

class LiveClassLobby extends StatefulWidget {
  const new({
    required this.session,
    required this.status,
    required this.micOn,
    required this.cameraOn,
    required this.isJoining,
    super.key,
  });

  final LiveClassSession session;
  final LiveClassStatus? status;
  final bool micOn;
  final bool cameraOn;
  final bool isJoining;

  @override
  State<LiveClassLobby> createState() => _LiveClassLobbyState();
}

class _LiveClassLobbyState extends State<LiveClassLobby> {
  final LobbyDevices _devices = LobbyDevices();

  @override
  void initState() {
    super.initState();
    if (widget.micOn) unawaited(_devices.setMicrophone(enabled: true));
    if (widget.cameraOn) unawaited(_devices.setCamera(enabled: true));
  }

  Future<void> _toggleMic() async {
    final cubit = context.read<LiveClassCubit>();
    final blocked = context.l10n.liveClassMicBlocked;
    final ok = await _devices.setMicrophone(enabled: !widget.micOn);
    if (!mounted) return;
    if (ok) {
      cubit.toggleMic();
    } else {
      AppSnackbar.error(blocked);
    }
  }

  Future<void> _toggleCamera() async {
    final cubit = context.read<LiveClassCubit>();
    final blocked = context.l10n.liveClassCameraBlocked;
    final ok = await _devices.setCamera(enabled: !widget.cameraOn);
    if (!mounted) return;
    if (ok) {
      cubit.toggleCamera();
    } else {
      AppSnackbar.error(blocked);
    }
  }

  @override
  void dispose() {
    _devices.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final status = widget.status;
    final session = widget.session;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.s24),
              children: [
                Row(
                  children: [
                    const AppBackButton(),
                    const Gap(AppSpacing.s8),
                    Expanded(
                      child: Text(
                        l10n.liveClassTitle,
                        style: context.textTheme.headlineSmall,
                      ),
                    ),
                  ],
                ),
                const Gap(AppSpacing.s24),
                ListenableBuilder(
                  listenable: _devices,
                  builder: (context, _) {
                    final locked = widget.isJoining || _devices.busy;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _PreviewCard(
                          camera: widget.cameraOn ? _devices.camera : null,
                          micOn: widget.micOn,
                        ),
                        const Gap(AppSpacing.s16),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: AppSpacing.s8,
                          runSpacing: AppSpacing.s8,
                          children: [
                            _DeviceChip(
                              on: widget.micOn,
                              onIcon: Icons.mic,
                              offIcon: Icons.mic_off,
                              label: l10n.liveClassMicrophone,
                              onTap: locked ? null : _toggleMic,
                            ),
                            _DeviceChip(
                              on: widget.cameraOn,
                              onIcon: Icons.videocam,
                              offIcon: Icons.videocam_off,
                              label: l10n.liveClassCamera,
                              onTap: locked ? null : _toggleCamera,
                            ),
                          ],
                        ),
                        const Gap(AppSpacing.s8),
                        Text(
                          widget.micOn || widget.cameraOn
                              ? l10n.liveClassDevicesOnHint
                              : l10n.liveClassDevicesOffHint,
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const Gap(AppSpacing.s16),
                if (status != null && status.isRecording)
                  _Notice(
                    icon: Icons.fiber_manual_record,
                    iconColor: AppColors.errorRed,
                    label: l10n.liveClassRecordingNotice,
                  ),
                if (status != null && status.participantCount > 0) ...[
                  const Gap(AppSpacing.s8),
                  _Notice(
                    icon: Icons.people_alt_outlined,
                    label: l10n.liveClassInClass(status.participantCount),
                  ),
                ],
                const Gap(AppSpacing.s24),
                Text(
                  session.topic,
                  textAlign: TextAlign.center,
                  style: context.textTheme.headlineSmall,
                ),
                const Gap(AppSpacing.s8),
                Text(
                  session.className,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const Gap(AppSpacing.s16),
                Text(
                  l10n.liveClassScheduledFor,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const Gap(AppSpacing.s4),
                Text(
                  session.timeLabel,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium,
                ),
                const Gap(AppSpacing.s32),
                AppButton(
                  label: l10n.liveClassJoin,
                  isLoading: widget.isJoining,
                  onPressed: () {
                    AppHaptics.selection();
                    unawaited(context.read<LiveClassCubit>().join());
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const new({required this.camera, required this.micOn});

  final LocalVideoTrack? camera;
  final bool micOn;

  @override
  Widget build(BuildContext context) {
    final camera = this.camera;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.r16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: ColoredBox(
          color: const Color(0xFF1F1F1F),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (camera != null)
                VideoTrackRenderer(
                  camera,
                  key: ObjectKey(camera),
                  fit: VideoViewFit.cover,
                )
              else
                const Center(
                  child: Icon(Icons.person, size: 88, color: Colors.white24),
                ),
              Positioned(
                left: AppSpacing.s8,
                bottom: AppSpacing.s8,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.s4),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    micOn ? Icons.mic : Icons.mic_off,
                    size: 16,
                    color: micOn ? Colors.white : AppColors.errorBorder,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeviceChip extends StatelessWidget {
  const new({
    required this.on,
    required this.onIcon,
    required this.offIcon,
    required this.label,
    required this.onTap,
  });

  final bool on;
  final IconData onIcon;
  final IconData offIcon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = on ? Colors.white : context.colors.onSurface;
    return Semantics(
      toggled: on,
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: on
            ? AppColors.accentBlue
            : context.colors.surfaceContainerHighest,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap == null
              ? null
              : () {
                  AppHaptics.selection();
                  onTap!();
                },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: AppSpacing.s8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(on ? onIcon : offIcon, size: 18, color: foreground),
                const Gap(AppSpacing.s8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.labelLarge?.copyWith(
                      color: foreground,
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

class _Notice extends StatelessWidget {
  const new({required this.icon, required this.label, this.iconColor});

  final IconData icon;
  final String label;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 14,
          color: iconColor ?? context.colors.onSurfaceVariant,
        ),
        const Gap(AppSpacing.s8),
        Flexible(
          child: Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
