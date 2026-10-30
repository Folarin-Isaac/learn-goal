import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/exceptions.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/core/network/network_info.dart';
import 'package:lengoal/features/classes/data/datasources/class_remote_data_source.dart';
import 'package:lengoal/features/classes/domain/entities/lengoal_class.dart';
import 'package:lengoal/features/classes/domain/repositories/class_repository.dart';

class ClassRepositoryImpl implements ClassRepository {
  new({required this._remoteDataSource, required this._networkInfo});

  final ClassRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, List<LengoalClass>>> getSubscribedClasses({
    String? searchTerm,
  }) {
    return _guard(
      () => _remoteDataSource.getSubscribedClasses(searchTerm: searchTerm),
    );
  }

  @override
  Future<Either<Failure, List<LengoalClass>>> getAllClasses({
    String? searchTerm,
  }) {
    return _guard(
      () => _remoteDataSource.getAllClasses(searchTerm: searchTerm),
    );
  }

  @override
  Future<Either<Failure, List<LengoalClass>>> getSavedClasses({
    String? searchTerm,
  }) {
    return _guard(
      () => _remoteDataSource.getSavedClasses(searchTerm: searchTerm),
    );
  }

  @override
  Future<Either<Failure, LengoalClass>> getClass(String id) {
    return _guard(() => _remoteDataSource.getClass(id));
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
