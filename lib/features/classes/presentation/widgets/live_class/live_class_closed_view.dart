import 'dart:async';

import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/bloc/live_class/live_class_cubit.dart';
import 'package:lengoal/features/classes/presentation/models/live_class_session.dart';

class LiveClassClosedView extends StatelessWidget {
  const new({required this.session, required this.phase, super.key});

  final LiveClassSession session;
  final LiveClassPhase phase;

  bool get canRejoin =>
      phase == LiveClassPhase.dropped || phase == LiveClassPhase.replaced;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (icon, iconColor, title, body) = switch (phase) {
      LiveClassPhase.replaced => (
        Icons.devices_outlined,
        context.colors.onSurfaceVariant,
        l10n.liveClassReplacedTitle,
        l10n.liveClassReplacedBody,
      ),
      LiveClassPhase.removed => (
        Icons.person_remove_outlined,
        context.colors.onSurfaceVariant,
        l10n.liveClassRemovedTitle,
        l10n.liveClassRemovedBody,
      ),
      LiveClassPhase.dropped => (
        Icons.wifi_off_rounded,
        context.colors.onSurfaceVariant,
        l10n.liveClassDroppedTitle,
        l10n.liveClassDroppedBody,
      ),
      _ => (
        Icons.event_available,
        AppColors.successGreen,
        l10n.liveClassEndedTitle,
        l10n.liveClassEndedBody,
      ),
    };
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.s24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(icon, size: 56, color: iconColor),
                  const Gap(AppSpacing.s16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: context.textTheme.headlineSmall,
                  ),
                  const Gap(AppSpacing.s8),
                  Text(
                    body,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const Gap(AppSpacing.s8),
                  Text(
                    session.topic,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const Gap(AppSpacing.s32),
                  if (canRejoin) ...[
                    AppButton(
                      label: l10n.liveClassRejoin,
                      onPressed: () {
                        AppHaptics.selection();
                        unawaited(context.read<LiveClassCubit>().join());
                      },
                    ),
                    const Gap(AppSpacing.s16),
                  ],
                  AppButton(
                    label: l10n.liveClassBackToClass,
                    isOutlined: canRejoin,
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
