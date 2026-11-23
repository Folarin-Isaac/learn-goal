import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/bloc/live_class/live_room_signals.dart';

class LiveReactionPicker extends StatelessWidget {
  const new({required this.handRaised, required this.onReact, super.key});

  final bool handRaised;
  final ValueChanged<LiveReaction> onReact;

  static const Color _amber = Color(0xFFF59E0B);

  static Future<bool> show(
    BuildContext context, {
    required bool handRaised,
    required ValueChanged<LiveReaction> onReact,
  }) async {
    final hand = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      backgroundColor: const Color(0xFF1C1C22),
      builder: (_) =>
          LiveReactionPicker(handRaised: handRaised, onReact: onReact),
    );
    return hand ?? false;
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
    final hand = _EmojiButton(
      emoji: '✋',
      label: handRaised ? l10n.liveClassLowerHand : l10n.liveClassRaiseHand,
      selected: handRaised,
      onTap: () => Navigator.of(context).pop(true),
    );
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
            for (final reaction in LiveReaction.values) ...[
              _EmojiButton(
                emoji: reaction.emoji,
                label: labelFor(context, reaction),
                selected: false,
                onTap: () => onReact(reaction),
              ),
              if (reaction == LiveReaction.love) hand,
            ],
          ],
        ),
      ),
    );
  }
}

class _EmojiButton extends StatelessWidget {
  const new({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const amber = LiveReactionPicker._amber;
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        excludeSemantics: true,
        child: Material(
          color: selected ? amber.withValues(alpha: 0.25) : Colors.white10,
          shape: CircleBorder(
            side: selected
                ? const BorderSide(color: amber, width: 1.5)
                : BorderSide.none,
          ),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              AppHaptics.selection();
              onTap();
            },
            child: SizedBox.square(
              dimension: 56,
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
