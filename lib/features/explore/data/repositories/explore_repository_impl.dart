import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/exceptions.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/core/network/network_info.dart';
import 'package:lengoal/features/explore/data/datasources/explore_remote_data_source.dart';
import 'package:lengoal/features/explore/domain/entities/explore_category.dart';
import 'package:lengoal/features/explore/domain/entities/explore_class.dart';
import 'package:lengoal/features/explore/domain/entities/top_educator.dart';
import 'package:lengoal/features/explore/domain/repositories/explore_repository.dart';

class ExploreRepositoryImpl implements ExploreRepository {
  new({required this._remoteDataSource, required this._networkInfo});

  final ExploreRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  // The feed lists every category; Explore only offers the ones a learner
  // can actually join a class in.
  @override
  Future<Either<Failure, List<ExploreCategory>>> getCategories() {
    return _guard(() async {
      final categories = await _remoteDataSource.getCategories();
      return categories
          .where((c) => c.id.isNotEmpty && c.activeClassCount > 0)
          .toList();
    });
  }

  @override
  Future<Either<Failure, List<ExploreClass>>> getCategoryClasses({
    String? categoryId,
  }) {
    return _guard(
      () => _remoteDataSource.getCategoryClasses(categoryId: categoryId),
    );
  }

  @override
  Future<Either<Failure, List<ExploreClass>>> getOngoingClasses() {
    return _guard(_remoteDataSource.getOngoingClasses);
  }

  @override
  Future<Either<Failure, List<ExploreClass>>> getUpcomingClasses() {
    return _guard(_remoteDataSource.getUpcomingClasses);
  }

  @override
  Future<Either<Failure, List<TopEducator>>> getTopEducators() {
    return _guard(_remoteDataSource.getTopEducators);
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
