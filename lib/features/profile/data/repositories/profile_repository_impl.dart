import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/exceptions.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/core/network/network_info.dart';
import 'package:lengoal/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:lengoal/features/profile/domain/entities/learner_profile.dart';
import 'package:lengoal/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  new({required this._remoteDataSource, required this._networkInfo});

  final ProfileRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  final StreamController<LearnerProfile?> _profileController =
      StreamController<LearnerProfile?>.broadcast();

  LearnerProfile? _cachedProfile;
  Future<Either<Failure, LearnerProfile>>? _inFlight;

  @override
  LearnerProfile? get cachedProfile => _cachedProfile;

  @override
  Stream<LearnerProfile?> get profileStream => _profileController.stream;

  @override
  Future<Either<Failure, LearnerProfile>> getLearnerProfile({
    bool forceRefresh = false,
  }) {
    final cached = _cachedProfile;
    if (!forceRefresh && cached != null) return Future.value(right(cached));

    // Two screens asking at once (prefetch racing a page open) must not
    // fire two requests — the second awaits the first.
    final pending = _inFlight;
    if (pending != null) return pending;

    final request = _guard(_remoteDataSource.getLearnerProfile).then((result) {
      result.match((_) {}, _emit);
      return result;
    });
    _inFlight = request;
    return request.whenComplete(() => _inFlight = null);
  }

  @override
  Future<void> prefetchProfile() async {
    if (_cachedProfile != null) return;
    await getLearnerProfile();
  }

  @override
  Future<Either<Failure, Unit>> updateLearnerProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? avatarUrl,
  }) async {
    final result = await _guard(() async {
      await _remoteDataSource.updateLearnerProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        avatarUrl: avatarUrl,
      );
      return unit;
    });

    // The PATCH returns data: null, so rather than re-fetching we fold the
    // values we just sent into the cache. Keeps every listener current in
    // one hop instead of a second round-trip.
    return result.map((success) {
      final current = _cachedProfile;
      _emit(
        LearnerProfile(
          learnerId: current?.learnerId ?? '',
          firstName: firstName,
          lastName: lastName,
          email: current?.email ?? '',
          phoneNumber: phoneNumber,
          avatar: avatarUrl ?? current?.avatar,
        ),
      );
      return success;
    });
  }

  @override
  Future<Either<Failure, String>> uploadFile({required String filePath}) {
    return _guard(() => _remoteDataSource.uploadFile(filePath: filePath));
  }

  @override
  void clearCache() {
    _cachedProfile = null;
    _profileController.add(null);
  }

  void _emit(LearnerProfile profile) {
    _cachedProfile = profile;
    _profileController.add(profile);
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
