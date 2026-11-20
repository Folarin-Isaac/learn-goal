import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/domain/entities/discussion_post.dart';
import 'package:lengoal/features/classes/presentation/bloc/class_discussion/class_discussion_cubit.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_details/discussion_message.dart';
import 'package:lengoal/features/community/presentation/widgets/community_composer.dart';

class DiscussionPostCard extends StatefulWidget {
  const new({
    required this.post,
    required this.isExpanded,
    required this.canParticipate,
    required this.isSendingReply,
    required this.onToggleReplies,
    required this.onReply,
    this.replies,
    super.key,
  });

  final DiscussionPost post;
  final DiscussionReplies? replies;
  final bool isExpanded;
  final bool canParticipate;
  final bool isSendingReply;
  final VoidCallback onToggleReplies;
  final Future<bool> Function(String message) onReply;

  @override
  State<DiscussionPostCard> createState() => _DiscussionPostCardState();
}

class _DiscussionPostCardState extends State<DiscussionPostCard> {
  final TextEditingController _replyController = TextEditingController();

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _sendReply() async {
    FocusScope.of(context).unfocus();
    if (await widget.onReply(_replyController.text)) _replyController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final muted = context.textTheme.bodySmall?.copyWith(
      color: context.colors.onSurfaceVariant,
    );
    final l10n = context.l10n;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DiscussionMessage(post: widget.post),
            const Gap(12),
            Row(
              children: [
                // Hidden until POST /ClassDiscussion/like stops returning a
                // server error.
                // Assets.icons.communityLikeIcon.svg(width: 18, height: 18),
                // const Gap(AppSpacing.s4),
                // Text('${widget.post.likeCount}', style: muted),
                // const Gap(AppSpacing.s16),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    AppHaptics.selection();
                    widget.onToggleReplies();
                  },
                  child: Row(
                    children: [
                      Assets.icons.communityCommentIcon.svg(
                        width: 18,
                        height: 18,
                        colorFilter: ColorFilter.mode(
                          context.colors.onSurfaceVariant,
                          BlendMode.srcIn,
                        ),
                      ),
                      const Gap(AppSpacing.s4),
                      Text(
                        widget.isExpanded
                            ? l10n.classDiscussionHideReplies
                            : l10n.classDiscussionViewReplies,
                        style: muted?.copyWith(
                          color: context.accentForeground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            AnimatedSize(
              duration: AppMotion.base,
              curve: AppMotion.standard,
              alignment: Alignment.topCenter,
              child: widget.isExpanded
                  ? _thread(context)
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thread(BuildContext context) {
    final replies = widget.replies;
    final l10n = context.l10n;
    final muted = context.textTheme.bodySmall?.copyWith(
      color: context.colors.onSurfaceVariant,
    );
    final Widget body;
    if (replies == null || replies.status == DiscussionStatus.loading) {
      body = const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.s8),
        child: Center(
          child: SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    } else if (replies.status == DiscussionStatus.failure) {
      body = Text(l10n.classDiscussionRepliesFailed, style: muted);
    } else if (replies.items.isEmpty) {
      body = Text(l10n.classDiscussionNoReplies, style: muted);
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < replies.items.length; i++) ...[
            if (i > 0) const Gap(AppSpacing.s16),
            DiscussionMessage(post: replies.items[i], avatarRadius: 16),
          ],
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(left: 12),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: context.colors.outlineVariant, width: 2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            body,
            if (widget.canParticipate) ...[
              const Gap(AppSpacing.s16),
              CommunityComposer(
                controller: _replyController,
                hint: l10n.classDiscussionReplyHint,
                onSubmit: widget.isSendingReply ? () {} : _sendReply,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
