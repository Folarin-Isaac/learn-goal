part of 'class_discussion_cubit.dart';

enum DiscussionStatus { loading, loaded, failure }

class DiscussionReplies extends Equatable {
  const new({this.status = DiscussionStatus.loading, this.items = const []});

  final DiscussionStatus status;
  final List<DiscussionPost> items;

  @override
  List<Object?> get props => [status, items];
}

class ClassDiscussionState extends Equatable {
  const new({
    this.status = DiscussionStatus.loading,
    this.posts = const [],
    this.replies = const {},
    this.expandedPostIds = const {},
    this.sendingTo,
  });

  final DiscussionStatus status;
  final List<DiscussionPost> posts;
  final Map<String, DiscussionReplies> replies;
  final Set<String> expandedPostIds;

  // The post a message is being sent to: '' for a new top-level post, a
  // post id for a reply, null when nothing is sending.
  final String? sendingTo;

  static const String newPostKey = '';

  bool isSending(String? parentPostId) =>
      sendingTo == (parentPostId ?? newPostKey);

  ClassDiscussionState copyWith({
    DiscussionStatus? status,
    List<DiscussionPost>? posts,
    Map<String, DiscussionReplies>? replies,
    Set<String>? expandedPostIds,
    String? Function()? sendingTo,
  }) {
    return ClassDiscussionState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      replies: replies ?? this.replies,
      expandedPostIds: expandedPostIds ?? this.expandedPostIds,
      sendingTo: sendingTo == null ? this.sendingTo : sendingTo(),
    );
  }

  @override
  List<Object?> get props => [
    status,
    posts,
    replies,
    expandedPostIds,
    sendingTo,
  ];
}
