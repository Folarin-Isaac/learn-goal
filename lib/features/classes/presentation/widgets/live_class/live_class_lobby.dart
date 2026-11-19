import 'dart:async';

import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/domain/entities/live_class_status.dart';
import 'package:lengoal/features/classes/presentation/bloc/live_class/live_class_cubit.dart';
import 'package:lengoal/features/classes/presentation/models/live_class_session.dart';

class LiveClassLobby extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<LiveClassCubit>();
    final status = this.status;
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
                _PreviewCard(
                  micOn: micOn,
                  cameraOn: cameraOn,
                  onMic: isJoining ? null : cubit.toggleMic,
                  onCamera: isJoining ? null : cubit.toggleCamera,
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
                const Gap(AppSpacing.s32),
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
                  isLoading: isJoining,
                  onPressed: () {
                    AppHaptics.selection();
                    unawaited(cubit.join());
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
  const new({
    required this.micOn,
    required this.cameraOn,
    required this.onMic,
    required this.onCamera,
  });

  final bool micOn;
  final bool cameraOn;
  final VoidCallback? onMic;
  final VoidCallback? onCamera;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.r16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: ColoredBox(
          color: AppColors.darkBackground,
          child: Stack(
            children: [
              const Center(
                child: Icon(Icons.person, size: 96, color: Colors.white24),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: AppSpacing.s16,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: AppSpacing.s8,
                  runSpacing: AppSpacing.s8,
                  children: [
                    _DeviceChip(
                      on: micOn,
                      onIcon: Icons.mic,
                      offIcon: Icons.mic_off,
                      label: l10n.liveClassMicrophone,
                      onTap: onMic,
                    ),
                    _DeviceChip(
                      on: cameraOn,
                      onIcon: Icons.videocam,
                      offIcon: Icons.videocam_off,
                      label: l10n.liveClassCamera,
                      onTap: onCamera,
                    ),
                  ],
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
    final foreground = on ? Colors.white : Colors.white70;
    return Semantics(
      toggled: on,
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: on ? AppColors.accentBlue : Colors.white12,
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
