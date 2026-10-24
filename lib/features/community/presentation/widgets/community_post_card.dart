import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/community/presentation/models/community_post.dart';

class CommunityPostCard extends StatelessWidget {
  const new({required this.post, this.onTap, super.key});

  final CommunityPost post;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final mutedStyle = context.textTheme.bodySmall?.copyWith(
      color: context.colors.onSurfaceVariant,
    );

    final card = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: post.avatarColor,
              foregroundColor: Colors.white,
              child: Text(
                post.authorInitial,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const Gap(AppSpacing.s8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          post.authorName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Gap(AppSpacing.s4),
                      Text('•', style: mutedStyle),
                      const Gap(AppSpacing.s4),
                      Expanded(
                        child: Text(
                          post.timestamp,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: mutedStyle,
                        ),
                      ),
                    ],
                  ),
                  if (post.authorTag.isNotEmpty)
                    Text(post.authorTag, style: mutedStyle),
                ],
              ),
            ),
          ],
        ),
        const Gap(AppSpacing.s8),
        Text(post.body, style: context.textTheme.bodyMedium),
        const Gap(AppSpacing.s8),
        Row(
          children: [
            Assets.icons.communityLikeIcon.svg(width: 18, height: 18),
            const Gap(4),
            Text('${post.likeCount}', style: mutedStyle),
            const Gap(AppSpacing.s16),
            Assets.icons.communityCommentIcon.svg(
              width: 18,
              height: 18,
              colorFilter: ColorFilter.mode(
                context.colors.onSurfaceVariant,
                BlendMode.srcIn,
              ),
            ),
            const Gap(4),
            Text('${post.commentCount}', style: mutedStyle),
            const Gap(AppSpacing.s16),
            Assets.icons.communityShareIcon.svg(
              width: 18,
              height: 18,
              colorFilter: ColorFilter.mode(
                context.colors.onSurfaceVariant,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ],
    );

    if (onTap == null) return card;
    return Pressable(
      child: InkWell(onTap: onTap, child: card),
    );
  }
}
