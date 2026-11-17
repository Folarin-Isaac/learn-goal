import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/classes/domain/entities/discussion_post.dart';
import 'package:lengoal/features/classes/domain/repositories/class_discussion_repository.dart';

class GetDiscussionPostsUseCase {
  new(this._repository);

  final ClassDiscussionRepository _repository;

  Future<Either<Failure, List<DiscussionPost>>> call(String classId) =>
      _repository.getPosts(classId);
}

class GetDiscussionRepliesUseCase {
  new(this._repository);

  final ClassDiscussionRepository _repository;

  Future<Either<Failure, List<DiscussionPost>>> call({
    required String classId,
    required String postId,
  }) => _repository.getReplies(classId: classId, postId: postId);
}

class PostDiscussionMessageUseCase {
  new(this._repository);

  final ClassDiscussionRepository _repository;

  Future<Either<Failure, Unit>> call({
    required String classId,
    required String message,
    String? parentPostId,
  }) => _repository.postMessage(
    classId: classId,
    message: message,
    parentPostId: parentPostId,
  );
}
