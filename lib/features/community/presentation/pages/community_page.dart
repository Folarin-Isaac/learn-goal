import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/auth/auth.dart';
import 'package:lengoal/features/community/presentation/models/community_post.dart';
import 'package:lengoal/features/community/presentation/models/trending_conversation.dart';
import 'package:lengoal/features/community/presentation/widgets/community_composer.dart';
import 'package:lengoal/features/community/presentation/widgets/community_post_card.dart';
import 'package:lengoal/features/community/presentation/widgets/community_trending_card.dart';

const _categories = [
  'Timeline',
  'Investment Banking',
  'Taxes',
  'Equity Finance',
];

class CommunityPage extends StatefulWidget {
  const new({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: _categories.length,
    vsync: this,
  );
  final _composerController = TextEditingController();
  final _posts = List<CommunityPost>.from(mockCommunityPosts);

  late final Future<UserEntity?> _userFuture = getIt<AuthRepository>()
      .getCurrentUser();

  @override
  void dispose() {
    _tabController.dispose();
    _composerController.dispose();
    super.dispose();
  }

  void _submitPost(UserEntity? user) {
    final text = _composerController.text.trim();
    if (text.isEmpty) return;
    AppHaptics.selection();
    final name = (user == null || user.fullName.isEmpty)
        ? 'You'
        : user.fullName;
    setState(() {
      _posts.insert(
        0,
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
      _composerController.clear();
    });
    context.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
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
                  child: Entrance(
                    child: Text(
                      context.l10n.communityTitle,
                      style: context.textTheme.headlineSmall,
                    ),
                  ),
                ),
                Entrance(
                  index: 1,
                  child: AppTabBar(
                    controller: _tabController,
                    labels: _categories,
                    isScrollable: true,
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.s24),
                    children: [
                      Entrance(
                        index: 2,
                        child: CommunityComposer(
                          controller: _composerController,
                          hint: context.l10n.communityShareHint,
                          onSubmit: () => _submitPost(user),
                        ),
                      ),
                      const Gap(AppSpacing.s24),
                      for (var i = 0; i < _posts.length; i++) ...[
                        if (i == 1) ...[
                          const Entrance(index: 3, child: _TrendingSection()),
                          const Gap(AppSpacing.s24),
                        ],
                        Entrance(
                          index: i + 3,
                          child: CommunityPostCard(
                            post: _posts[i],
                            onTap: () {
                              AppHaptics.selection();
                              unawaited(
                                context.pushNamed(
                                  RouteNames.communityPostDetail,
                                  extra: _posts[i],
                                ),
                              );
                            },
                          ),
                        ),
                        if (i != _posts.length - 1) const Gap(AppSpacing.s24),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const DashboardBottomNav(currentIndex: 3),
    );
  }
}

class _TrendingSection extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppSpacing.r16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
            child: Text(
              context.l10n.communityTrendingHeading,
              style: context.textTheme.titleLarge,
            ),
          ),
          const Gap(AppSpacing.s16),
          SizedBox(
            height: 180,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = (constraints.maxWidth / 1.6).clamp(
                  220.0,
                  260.0,
                );
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s16,
                  ),
                  itemCount: mockTrendingConversations.length,
                  separatorBuilder: (context, index) =>
                      const Gap(AppSpacing.s16),
                  itemBuilder: (context, index) => CommunityTrendingCard(
                    conversation: mockTrendingConversations[index],
                    width: cardWidth,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
