import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/bloc/live_class/live_room_signals.dart';

sealed class LiveTrayChoice {
  const new();
}

class LiveTrayReaction extends LiveTrayChoice {
  const new(this.reaction);

  final LiveReaction reaction;
}

class LiveTrayHand extends LiveTrayChoice {
  const new();
}

class LiveReactionPicker extends StatelessWidget {
  const new({required this.handRaised, super.key});

  final bool handRaised;

  static const Color _amber = Color(0xFFF59E0B);

  static Future<LiveTrayChoice?> show(
    BuildContext context, {
    required bool handRaised,
  }) {
    return showModalBottomSheet<LiveTrayChoice>(
      context: context,
      showDragHandle: true,
      backgroundColor: const Color(0xFF1C1C22),
      builder: (_) => LiveReactionPicker(handRaised: handRaised),
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
    final l10n = context.l10n;
    final items = <(String, String, LiveTrayChoice, bool)>[
      for (final reaction in LiveReaction.values) ...[
        (
          reaction.emoji,
          labelFor(context, reaction),
          LiveTrayReaction(reaction),
          false,
        ),
        if (reaction == LiveReaction.love)
          (
            '✋',
            handRaised ? l10n.liveClassLowerHand : l10n.liveClassRaiseHand,
            const LiveTrayHand(),
            handRaised,
          ),
      ],
    ];
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
            for (final (emoji, label, choice, selected) in items)
              Tooltip(
                message: label,
                child: Semantics(
                  button: true,
                  selected: selected,
                  label: label,
                  excludeSemantics: true,
                  child: Material(
                    color: selected
                        ? _amber.withValues(alpha: 0.25)
                        : Colors.white10,
                    shape: CircleBorder(
                      side: selected
                          ? const BorderSide(color: _amber, width: 1.5)
                          : BorderSide.none,
                    ),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        AppHaptics.selection();
                        Navigator.of(context).pop(choice);
                      },
                      child: SizedBox.square(
                        dimension: 56,
                        child: Center(
                          child: Text(
                            emoji,
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
