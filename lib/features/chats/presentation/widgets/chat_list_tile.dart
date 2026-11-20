import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/chats/presentation/bloc/chat_list/chat_list_cubit.dart';
import 'package:lengoal/features/chats/presentation/models/chat_time.dart';
import 'package:lengoal/features/chats/presentation/widgets/chat_message_text.dart';

class ChatListTile extends StatelessWidget {
  const new({
    required this.preview,
    required this.now,
    required this.onTap,
    super.key,
  });

  final ChatPreview preview;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final latest = preview.latest;
    final isDark = context.isDarkMode;
    final accent = context.colors.primary;
    final String previewText;
    if (!preview.isLoaded) {
      previewText = '';
    } else if (latest == null) {
      previewText = l10n.chatsNoMessagesPreview;
    } else if (ChatMessageText.withoutMention(latest.text).trim().isNotEmpty) {
      previewText = ChatMessageText.withoutMention(latest.text).trim();
    } else if (latest.text.trim().isNotEmpty && !latest.hasMedia) {
      previewText = latest.text.trim();
    } else {
      previewText = l10n.chatsAttachmentPreview;
    }

    return Pressable(
      child: Material(
        color: context.colors.primary.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.r8),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.r8),
          onTap: () {
            AppHaptics.selection();
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          preview.lengoalClass.cohortName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (latest != null) ...[
                        const Gap(AppSpacing.s8),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: constraints.maxWidth * 0.4,
                          ),
                          child: Text(
                            ChatTime.relative(context, latest.createdOn, now),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: accent,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Gap(AppSpacing.s4),
                if (preview.hasDraft)
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${l10n.chatsDraft} ',
                          style: const TextStyle(
                            color: AppColors.errorRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: preview.draft.trim()),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  )
                else if (!preview.isLoaded)
                  const Shimmer(child: SkeletonBox(width: 140))
                else
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          previewText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: latest == null
                                ? context.colors.onSurfaceVariant
                                : accent,
                            fontWeight: preview.isUnread
                                ? FontWeight.w700
                                : null,
                          ),
                        ),
                      ),
                      if (preview.isUnread) ...[
                        const Gap(AppSpacing.s8),
                        Semantics(
                          label: l10n.chatsUnreadSemantics,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
