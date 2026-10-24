import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/auth/auth.dart';
import 'package:lengoal/features/community/presentation/models/community_post.dart';
import 'package:lengoal/features/community/presentation/widgets/community_composer.dart';
import 'package:lengoal/features/community/presentation/widgets/community_post_card.dart';

const _categories = [
  'Timeline',
  'Investment Banking',
  'Taxes',
  'Equity Finance',
];

class CommunityPostDetailPage extends StatefulWidget {
  const new({required this.post, super.key});

  final CommunityPost post;

  @override
  State<CommunityPostDetailPage> createState() =>
      _CommunityPostDetailPageState();
}

class _CommunityPostDetailPageState extends State<CommunityPostDetailPage> {
  final _replyController = TextEditingController();
  late final _replies = List<CommunityPost>.from(widget.post.replies);

  late final Future<UserEntity?> _userFuture = getIt<AuthRepository>()
      .getCurrentUser();

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _submitReply(UserEntity? user) {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;
    AppHaptics.selection();
    final name = (user == null || user.fullName.isEmpty)
        ? 'You'
        : user.fullName;
    setState(() {
      _replies.add(
        CommunityPost(
          authorName: name,
          authorTag: '',
          authorInitial: name[0].toUpperCase(),
          avatarColor: context.colors.primary,
          timestamp: context.l10n.communityJustNow,
          body: text,
          likeCount: 0,
          commentCount: 0,
        ),
      );
      _replyController.clear();
    });
    context.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<UserEntity?>(
          future: _userFuture,
          builder: (context, snapshot) {
            final user = snapshot.data;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s24,
                    AppSpacing.s24,
                    AppSpacing.s24,
                    0,
                  ),
                  child: Row(
                    children: [
                      const AppBackButton(),
                      const Gap(AppSpacing.s8),
                      Expanded(
                        child: Text(
                          context.l10n.communityPostDetailTitle,
                          style: context.textTheme.headlineSmall,
                        ),
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s16,
                  ),
                  child: Row(
                    children: [
                      for (var i = 0; i < _categories.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.s24),
                          child: Text(
                            _categories[i],
                            style: context.textTheme.bodyLarge?.copyWith(
                              color: i == 0
                                  ? context.colors.primary
                                  : context.colors.onSurfaceVariant,
                              fontWeight: i == 0
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const Divider(height: AppSpacing.s24),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.s24),
                    children: [
                      CommunityPostCard(post: widget.post),
                      const Gap(AppSpacing.s24),
                      CommunityComposer(
                        controller: _replyController,
                        hint: context.l10n.communityReplyHint,
                        avatarInitial: (user?.firstName.isNotEmpty ?? false)
                            ? user!.firstName[0].toUpperCase()
                            : '?',
                        avatarColor: context.colors.primary,
                        onSubmit: () => _submitReply(user),
                      ),
                      const Gap(AppSpacing.s24),
                      for (var i = 0; i < _replies.length; i++) ...[
                        CommunityPostCard(post: _replies[i]),
                        const Gap(AppSpacing.s24),
                      ],
                      if (_replies.isNotEmpty)
                        Pressable(
                          child: InkWell(
                            onTap: () {
                              AppHaptics.selection();
                              AppSnackbar.info(
                                context.l10n.dashboardComingSoon,
                              );
                            },
                            child: Text(
                              context.l10n.communityShowMoreReplies,
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: context.colors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
