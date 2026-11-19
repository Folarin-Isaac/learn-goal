import 'dart:async';

import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/bloc/live_class/live_class_cubit.dart';
import 'package:lengoal/features/classes/presentation/models/live_class_session.dart';

class LiveClassClosedView extends StatelessWidget {
  const new ended({required this.session, super.key}) : canRejoin = false;

  const new dropped({required this.session, super.key}) : canRejoin = true;

  final LiveClassSession session;
  final bool canRejoin;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
                  Icon(
                    canRejoin ? Icons.wifi_off_rounded : Icons.event_available,
                    size: 56,
                    color: canRejoin
                        ? context.colors.onSurfaceVariant
                        : AppColors.successGreen,
                  ),
                  const Gap(AppSpacing.s16),
                  Text(
                    canRejoin
                        ? l10n.liveClassDroppedTitle
                        : l10n.liveClassEndedTitle,
                    textAlign: TextAlign.center,
                    style: context.textTheme.headlineSmall,
                  ),
                  const Gap(AppSpacing.s8),
                  Text(
                    canRejoin
                        ? l10n.liveClassDroppedBody
                        : l10n.liveClassEndedBody,
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
