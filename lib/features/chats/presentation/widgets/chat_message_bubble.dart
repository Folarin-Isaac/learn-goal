import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/chats/presentation/models/chat_message.dart';

class ChatMessageBubble extends StatelessWidget {
  const new({required this.message, this.index = 0, super.key});

  final ChatMessage message;
  final int index;

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;

    final bubble = Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: isMine
            ? context.colors.primary
            : context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.r16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            message.text,
            style: context.textTheme.bodyMedium?.copyWith(
              color: isMine ? Colors.white : Colors.black,
            ),
          ),
          const Gap(AppSpacing.s4),
          Text(
            message.timestamp,
            style: context.textTheme.bodySmall?.copyWith(
              color: isMine ? Colors.white70 : context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );

    final badge = isMine
        ? Assets.icons.chatReactionIcon.svg(width: 20, height: 20)
        : Assets.icons.chatReceivedBadgeIcon.svg(width: 24, height: 24);

    return Entrance(
      index: index,
      offset: const Offset(0, 10),
      duration: const Duration(milliseconds: 220),
      child: Column(
        crossAxisAlignment: isMine
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.75,
            ),
            child: bubble,
          ),
          if (!isMine && message.senderName != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.s4),
              child: Text(
                '${message.senderName} | ${message.timestamp}',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.s4),
            child: badge,
          ),
        ],
      ),
    );
  }
}
