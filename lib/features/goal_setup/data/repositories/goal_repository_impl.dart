// features/goal_setup/data/repositories/goal_repository_impl.dart
import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/exceptions.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/core/network/network_info.dart';
import 'package:lengoal/features/goal_setup/data/datasources/goal_remote_data_source.dart';
import 'package:lengoal/features/goal_setup/domain/entities/exam_goal.dart';
import 'package:lengoal/features/goal_setup/domain/entities/exam_stage.dart';
import 'package:lengoal/features/goal_setup/domain/entities/goal_category.dart';
import 'package:lengoal/features/goal_setup/domain/entities/learning_goal.dart';
import 'package:lengoal/features/goal_setup/domain/repositories/goal_repository.dart';

class GoalRepositoryImpl implements GoalRepository {
  new({required this._remoteDataSource, required this._networkInfo});

  final GoalRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, List<GoalCategory>>> getCategories({
    String? searchTerm,
  }) {
    return _guard(
      () => _remoteDataSource.getCategories(searchTerm: searchTerm),
    );
  }

  @override
  Future<Either<Failure, List<ExamGoal>>> getGoals({
    required String categoryId,
    String? searchTerm,
  }) {
    return _guard(
      () => _remoteDataSource.getGoals(
        categoryId: categoryId,
        searchTerm: searchTerm,
      ),
    );
  }

  @override
  Future<Either<Failure, List<ExamStage>>> getExamStages({
    required String examId,
  }) {
    return _guard(() => _remoteDataSource.getExamStages(examId: examId));
  }

  @override
  Future<Either<Failure, LearningGoal>> saveGoal({
    required String fieldId,
    required String examId,
    required String stageId,
    required List<String> topicIds,
    required DateTime targetDate,
  }) {
    return _guard(
      () => _remoteDataSource.saveGoal(
        fieldId: fieldId,
        examId: examId,
        stageId: stageId,
        topicIds: topicIds,
        targetDate: targetDate,
      ),
    );
  }

  // Generic guard shared by every method here for connectivity checks
  // and exception mapping — same idea as auth's _guard.
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
