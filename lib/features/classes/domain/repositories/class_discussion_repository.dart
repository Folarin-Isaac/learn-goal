import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/classes/domain/entities/discussion_post.dart';

abstract class ClassDiscussionRepository {
  Future<Either<Failure, List<DiscussionPost>>> getPosts(String classId);

  Future<Either<Failure, List<DiscussionPost>>> getReplies({
    required String classId,
    required String postId,
  });

  Future<Either<Failure, Unit>> postMessage({
    required String classId,
    required String message,
    String? parentPostId,
  });
}
