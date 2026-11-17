import 'dart:async';

import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/bloc/class_discussion/class_discussion_cubit.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_details/class_details_tab_scroll.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_details/class_enroll_hint.dart';
import 'package:lengoal/features/classes/presentation/widgets/class_details/discussion_post_card.dart';
import 'package:lengoal/features/community/presentation/widgets/community_composer.dart';

class ClassCommunicationsTab extends StatefulWidget {
  const new({required this.isSubscribed, super.key});

  final bool isSubscribed;

  @override
  State<ClassCommunicationsTab> createState() => _ClassCommunicationsTabState();
}

class _ClassCommunicationsTabState extends State<ClassCommunicationsTab> {
  static const String _storageKey = 'classDetailsCommunications';

  final TextEditingController _postController = TextEditingController();

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  Future<bool> _send(String message, {String? parentPostId}) async {
    final error = await context.read<ClassDiscussionCubit>().send(
      message,
      parentPostId: parentPostId,
    );
    if (error != null) {
      AppHaptics.error();
      AppSnackbar.error(error);
      return false;
    }
    AppHaptics.success();
    return true;
  }

  Future<void> _sendPost() async {
    FocusScope.of(context).unfocus();
    if (await _send(_postController.text)) _postController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<ClassDiscussionCubit, ClassDiscussionState>(
      builder: (context, state) {
        final cubit = context.read<ClassDiscussionCubit>();
        final header = SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s24,
            AppSpacing.s24,
            AppSpacing.s24,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: widget.isSubscribed
                ? Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: CommunityComposer(
                        controller: _postController,
                        hint: l10n.classDiscussionPostHint,
                        onSubmit: state.isSending(null) ? () {} : _sendPost,
                      ),
                    ),
                  )
                : ClassEnrollHint(message: l10n.classDiscussionEnrollHint),
          ),
        );

        final Widget content;
        if (state.posts.isEmpty) {
          content = SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: ClassDetailsTabScroll.padding,
                child: switch (state.status) {
                  DiscussionStatus.loading => const CircularProgressIndicator(),
                  DiscussionStatus.failure => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.classDiscussionLoadFailed,
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyMedium,
                      ),
                      const Gap(AppSpacing.s16),
                      AppButton(
                        label: l10n.commonRetry,
                        isOutlined: true,
                        height: 44,
                        onPressed: () => unawaited(cubit.load()),
                      ),
                    ],
                  ),
                  DiscussionStatus.loaded => Text(
                    widget.isSubscribed
                        ? l10n.classDiscussionEmpty
                        : l10n.classDetailsCommunicationsEmpty,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium,
                  ),
                },
              ),
            ),
          );
        } else {
          content = SliverPadding(
            padding: ClassDetailsTabScroll.padding,
            sliver: SliverList.separated(
              itemCount: state.posts.length,
              separatorBuilder: (context, index) => const Gap(AppSpacing.s16),
              itemBuilder: (context, index) {
                final post = state.posts[index];
                return DiscussionPostCard(
                  key: ValueKey(post.id),
                  post: post,
                  replies: state.replies[post.id],
                  isExpanded: state.expandedPostIds.contains(post.id),
                  canParticipate: widget.isSubscribed,
                  isSendingReply: state.isSending(post.id),
                  onToggleReplies: () =>
                      unawaited(cubit.toggleReplies(post.id)),
                  onReply: (message) => _send(message, parentPostId: post.id),
                );
              },
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: cubit.load,
          child: ClassDetailsTabScroll(
            storageKey: _storageKey,
            slivers: [header, content],
          ),
        );
      },
    );
  }
}
