import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/bloc/live_class/live_room_signals.dart';

class LiveReactionPicker extends StatelessWidget {
  const new({super.key});

  static Future<LiveReaction?> show(BuildContext context) {
    return showModalBottomSheet<LiveReaction>(
      context: context,
      showDragHandle: true,
      backgroundColor: const Color(0xFF1C1C22),
      builder: (_) => const LiveReactionPicker(),
    );
  }

  static String labelFor(BuildContext context, LiveReaction reaction) {
    final l10n = context.l10n;
    return switch (reaction) {
      LiveReaction.love => l10n.liveClassReactionLove,
      LiveReaction.clap => l10n.liveClassReactionClap,
      LiveReaction.celebrate => l10n.liveClassReactionCelebrate,
      LiveReaction.laugh => l10n.liveClassReactionLaugh,
      LiveReaction.sad => l10n.liveClassReactionSad,
      LiveReaction.thumbsUp => l10n.liveClassReactionThumbsUp,
      LiveReaction.thumbsDown => l10n.liveClassReactionThumbsDown,
      LiveReaction.thinking => l10n.liveClassReactionThinking,
      LiveReaction.wave => l10n.liveClassReactionWave,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s16,
          0,
          AppSpacing.s16,
          AppSpacing.s16,
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.s8,
          runSpacing: AppSpacing.s8,
          children: [
            for (final reaction in LiveReaction.values)
              Tooltip(
                message: labelFor(context, reaction),
                child: Semantics(
                  button: true,
                  label: labelFor(context, reaction),
                  excludeSemantics: true,
                  child: Material(
                    color: Colors.white10,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        AppHaptics.selection();
                        Navigator.of(context).pop(reaction);
                      },
                      child: SizedBox.square(
                        dimension: 56,
                        child: Center(
                          child: Text(
                            reaction.emoji,
                            style: const TextStyle(fontSize: 28),
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
    );
  }
}
