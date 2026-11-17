import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/exceptions.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/core/network/network_info.dart';
import 'package:lengoal/features/classes/data/datasources/class_discussion_remote_data_source.dart';
import 'package:lengoal/features/classes/domain/entities/discussion_post.dart';
import 'package:lengoal/features/classes/domain/repositories/class_discussion_repository.dart';

class ClassDiscussionRepositoryImpl implements ClassDiscussionRepository {
  new({required this._remoteDataSource, required this._networkInfo});

  final ClassDiscussionRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  // The feed mixes replies in with top-level posts; replies are dropped
  // here because they're shown under their post via get-replies. It also
  // arrives oldest first, while the discussion reads newest first.
  @override
  Future<Either<Failure, List<DiscussionPost>>> getPosts(String classId) {
    return _guard(() async {
      final posts = await _remoteDataSource.getPosts(classId);
      return posts.where((post) => post.parentPostId == null).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  // Replies read as a conversation, oldest first.
  @override
  Future<Either<Failure, List<DiscussionPost>>> getReplies({
    required String classId,
    required String postId,
  }) {
    return _guard(() async {
      final replies = await _remoteDataSource.getReplies(
        classId: classId,
        postId: postId,
      );
      return replies..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    });
  }

  @override
  Future<Either<Failure, Unit>> postMessage({
    required String classId,
    required String message,
    String? parentPostId,
  }) {
    return _guard(() async {
      await _remoteDataSource.postMessage(
        classId: classId,
        message: message,
        parentPostId: parentPostId,
      );
      return unit;
    });
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      return right(await action());
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}
