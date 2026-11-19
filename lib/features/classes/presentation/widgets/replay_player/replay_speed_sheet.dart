import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/widgets/replay_player/replay_time.dart';

const List<double> replaySpeeds = [0.5, 0.75, 1, 1.25, 1.5, 1.75, 2];

Future<double?> showReplaySpeedSheet(
  BuildContext context, {
  required double current,
}) {
  return showModalBottomSheet<double>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s24,
                0,
                AppSpacing.s24,
                AppSpacing.s8,
              ),
              child: Text(
                context.l10n.replayPlayerSpeed,
                style: context.textTheme.titleMedium,
              ),
            ),
            for (final speed in replaySpeeds)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s24,
                ),
                title: Text(
                  speed == 1
                      ? context.l10n.replayPlayerNormalSpeed
                      : formatReplaySpeed(speed),
                  style: context.textTheme.bodyLarge,
                ),
                trailing: speed == current
                    ? Icon(Icons.check, color: context.colors.primary)
                    : null,
                onTap: () {
                  AppHaptics.selection();
                  Navigator.of(context).pop(speed);
                },
              ),
          ],
        ),
      ),
    ),
  );
}
