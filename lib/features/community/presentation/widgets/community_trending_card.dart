import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/community/presentation/models/trending_conversation.dart';

class CommunityTrendingCard extends StatelessWidget {
  const new({required this.conversation, required this.width, super.key});

  final TrendingConversation conversation;
  final double width;

  static const _avatarColors = [
    Color(0xFF8B5E3C),
    Color(0xFF4A3B2A),
    Color(0xFF002F8C),
    Color(0xFFF5B400),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.r16),
        ),
        child: Pressable(
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.r16),
            onTap: () {
              AppHaptics.selection();
              AppSnackbar.info(context.l10n.dashboardComingSoon);
            },
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(AppSpacing.s8),
                  Text.rich(
                    TextSpan(
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                      children: [
                        TextSpan(
                          text: conversation.commentsLabel,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(
                          text: ' ${context.l10n.communityCommentsSuffix}',
                        ),
                      ],
                    ),
                  ),
                  const Gap(AppSpacing.s16),
                  SizedBox(
                    height: 28,
                    child: Stack(
                      children: [
                        for (
                          var i = 0;
                          i < conversation.participantInitials.length;
                          i++
                        )
                          Positioned(
                            left: i * 20.0,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor:
                                    _avatarColors[i % _avatarColors.length],
                                foregroundColor: Colors.white,
                                child: Text(
                                  conversation.participantInitials[i],
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Gap(AppSpacing.s8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.l10n.communityJoin,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 18),
                    ],
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
