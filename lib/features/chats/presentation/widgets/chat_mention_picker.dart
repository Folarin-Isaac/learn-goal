import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/chats/presentation/models/chat_mention.dart';
import 'package:lengoal/features/chats/presentation/widgets/chat_message_bubble.dart';

class ChatMentionPicker extends StatelessWidget {
  const new({
    required this.members,
    required this.showEveryone,
    required this.onPick,
    super.key,
  });

  final List<ChatMember> members;
  final bool showEveryone;
  final ValueChanged<String> onPick;

  static const double rowHeight = 60;
  static const double maxVisibleRows = 4.5;
  static const double _avatarSize = 36;

  @override
  Widget build(BuildContext context) {
    final count = members.length + (showEveryone ? 1 : 0);
    final visible = count < maxVisibleRows ? count.toDouble() : maxVisibleRows;
    return TextFieldTapRegion(
      child: Material(
        color: context.colors.surfaceContainerHigh,
        elevation: 4,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(AppSpacing.r8),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: visible * rowHeight,
          child: Scrollbar(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemExtent: rowHeight,
              itemCount: count,
              itemBuilder: (context, index) {
                if (showEveryone && index == 0) {
                  return _row(
                    context,
                    leading: CircleAvatar(
                      radius: _avatarSize / 2,
                      backgroundColor: context.colors.primary.withValues(
                        alpha: 0.12,
                      ),
                      child: Icon(
                        Icons.groups_outlined,
                        size: 20,
                        color: context.colors.primary,
                      ),
                    ),
                    title: ChatMentionQuery.everyone,
                    subtitle: context.l10n.chatsMentionAllSubtitle,
                    value: ChatMentionQuery.everyone,
                  );
                }
                final member = members[index - (showEveryone ? 1 : 0)];
                return _row(
                  context,
                  leading: ChatSenderAvatar(
                    name: member.name,
                    photoUrl: member.photoUrl,
                    size: _avatarSize,
                  ),
                  title: member.name,
                  value: member.name,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context, {
    required Widget leading,
    required String title,
    required String value,
    String? subtitle,
  }) {
    return InkWell(
      onTap: () {
        AppHaptics.selection();
        onPick(value);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
        child: Row(
          children: [
            leading,
            const Gap(12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleSmall,
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
