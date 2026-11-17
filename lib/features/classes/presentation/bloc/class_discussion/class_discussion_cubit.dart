import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lengoal/features/classes/domain/entities/discussion_post.dart';
import 'package:lengoal/features/classes/domain/usecases/class_discussion_usecases.dart';

part 'class_discussion_state.dart';

// Drives the class Communications tab. Replies are fetched per post the
// first time it's expanded, and refetched after the learner replies.
class ClassDiscussionCubit extends Cubit<ClassDiscussionState> {
  new({
    required this._classId,
    required this._getPosts,
    required this._getReplies,
    required this._postMessage,
  }) : super(const ClassDiscussionState());

  final String _classId;
  final GetDiscussionPostsUseCase _getPosts;
  final GetDiscussionRepliesUseCase _getReplies;
  final PostDiscussionMessageUseCase _postMessage;

  // A failed refresh keeps the posts already on screen.
  Future<void> load() async {
    if (state.posts.isEmpty) {
      emit(state.copyWith(status: DiscussionStatus.loading));
    }
    final result = await _getPosts(_classId);
    if (isClosed) return;
    result.match(
      (_) => emit(
        state.copyWith(
          status: state.posts.isEmpty
              ? DiscussionStatus.failure
              : DiscussionStatus.loaded,
        ),
      ),
      (posts) =>
          emit(state.copyWith(status: DiscussionStatus.loaded, posts: posts)),
    );
    await Future.wait(state.expandedPostIds.map(_loadReplies));
  }

  Future<void> toggleReplies(String postId) async {
    final expanded = {...state.expandedPostIds};
    if (!expanded.remove(postId)) expanded.add(postId);
    emit(state.copyWith(expandedPostIds: expanded));
    final loaded = state.replies[postId]?.status == DiscussionStatus.loaded;
    if (expanded.contains(postId) && !loaded) await _loadReplies(postId);
  }

  // Returns an error message, or null once the message is posted.
  Future<String?> send(String message, {String? parentPostId}) async {
    final text = message.trim();
    if (text.isEmpty || state.sendingTo != null) return null;
    emit(
      state.copyWith(
        sendingTo: () => parentPostId ?? ClassDiscussionState.newPostKey,
      ),
    );
    final result = await _postMessage(
      classId: _classId,
      message: text,
      parentPostId: parentPostId,
    );
    if (isClosed) return null;
    emit(state.copyWith(sendingTo: () => null));
    final error = result.match((failure) => failure.message, (_) => null);
    if (error != null) return error;
    if (parentPostId == null) {
      unawaited(load());
    } else {
      unawaited(_loadReplies(parentPostId));
    }
    return null;
  }

  Future<void> _loadReplies(String postId) async {
    final current = state.replies[postId];
    if (current == null || current.items.isEmpty) {
      _setReplies(postId, const DiscussionReplies());
    }
    final result = await _getReplies(classId: _classId, postId: postId);
    if (isClosed) return;
    result.match(
      (_) => _setReplies(
        postId,
        DiscussionReplies(
          status: (current?.items.isEmpty ?? true)
              ? DiscussionStatus.failure
              : DiscussionStatus.loaded,
          items: current?.items ?? const [],
        ),
      ),
      (items) => _setReplies(
        postId,
        DiscussionReplies(status: DiscussionStatus.loaded, items: items),
      ),
    );
  }

  void _setReplies(String postId, DiscussionReplies replies) {
    emit(state.copyWith(replies: {...state.replies, postId: replies}));
  }
}
