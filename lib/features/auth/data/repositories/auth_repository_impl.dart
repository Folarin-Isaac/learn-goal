import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/constants/storage_keys.dart';
import 'package:lengoal/core/error/exceptions.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/core/network/network_info.dart';
import 'package:lengoal/core/storage/secure_storage_service.dart';
import 'package:lengoal/core/utils/jwt_decoder.dart';
import 'package:lengoal/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:lengoal/features/auth/data/models/user_model.dart';
import 'package:lengoal/features/auth/domain/entities/user_entity.dart';
import 'package:lengoal/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  new({
    required this._remoteDataSource,
    required this._secureStorage,
    required this._networkInfo,
  });

  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _secureStorage;
  final NetworkInfo _networkInfo;

  // Matches the real API's 400 "confirm your email" response.
  // Checks both status code and message substring to avoid false positives.
  static const String _unconfirmedEmailMessage = 'confirm your email';
  static const int _unconfirmedEmailStatusCode = 400;

  AuthStatus _status = AuthStatus.unknown;
  final StreamController<AuthStatus> _statusController =
      StreamController<AuthStatus>.broadcast();

  bool _needsGoalSetup = false;

  @override
  AuthStatus get currentAuthStatus => _status;

  @override
  Stream<AuthStatus> get authStatusStream => _statusController.stream;

  @override
  bool get needsGoalSetup => _needsGoalSetup;

  @override
  Future<void> checkAuthStatus() async {
    // Runs once per app launch, so a session the learner chose not to
    // keep is dropped here rather than restored.
    if (await _secureStorage.read(StorageKeys.keepSignedIn) == 'false') {
      await _clearSession();
      _setStatus(AuthStatus.unauthenticated);
      return;
    }
    final token = await _secureStorage.read(StorageKeys.accessToken);
    _needsGoalSetup =
        await _secureStorage.read(StorageKeys.needsGoalSetup) == 'true';
    _setStatus(
      token != null && token.isNotEmpty
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated,
    );
  }

  @override
  Future<void> completeGoalSetup() async {
    _needsGoalSetup = false;
    await _secureStorage.write(StorageKeys.needsGoalSetup, 'false');
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final token = await _secureStorage.read(StorageKeys.accessToken);
    if (token == null || token.isEmpty) return null;
    final claims = JwtDecoder.decodePayload(token);
    return UserModel(
      id: '',
      email: claims['Email'] as String? ?? '',
      firstName: claims['FirstName'] as String? ?? '',
      lastName: claims['LastName'] as String? ?? '',
    );
  }

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
    bool keepSignedIn = true,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final (user, accessToken, refreshToken, isFirstLogin) =
          await _remoteDataSource.login(email: email, password: password);
      await _secureStorage.write(StorageKeys.accessToken, accessToken);
      await _secureStorage.write(StorageKeys.refreshToken, refreshToken);
      await _secureStorage.write(
        StorageKeys.keepSignedIn,
        keepSignedIn.toString(),
      );
      _needsGoalSetup = isFirstLogin;
      await _secureStorage.write(
        StorageKeys.needsGoalSetup,
        isFirstLogin.toString(),
      );
      _setStatus(AuthStatus.authenticated);
      return right(user);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      if (e.statusCode == _unconfirmedEmailStatusCode &&
          e.message.toLowerCase().contains(_unconfirmedEmailMessage)) {
        return Left(UnconfirmedEmailFailure(email: email, message: e.message));
      }
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phoneNumber,
  }) {
    return _guard(
      () => _remoteDataSource.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
      ),
    );
  }

  @override
  Future<Either<Failure, Unit>> verifyOtp({
    required String email,
    required String otp,
  }) {
    return _guard(() => _remoteDataSource.verifyOtp(email: email, otp: otp));
  }

  @override
  Future<Either<Failure, Unit>> resendOtp({required String email}) {
    return _guard(() => _remoteDataSource.resendOtp(email: email));
  }

  @override
  Future<Either<Failure, String>> forgotPassword({required String email}) {
    return _guardValue(() => _remoteDataSource.forgotPassword(email: email));
  }

  @override
  Future<Either<Failure, Unit>> resetPassword({
    required String email,
    required String token,
    required String password,
  }) {
    return _guard(
      () => _remoteDataSource.resetPassword(
        email: email,
        token: token,
        password: password,
      ),
    );
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (_) {}
    await _clearSession();
    _setStatus(AuthStatus.unauthenticated);
    return right(unit);
  }

  Future<void> _clearSession() async {
    await _secureStorage.delete(StorageKeys.accessToken);
    await _secureStorage.delete(StorageKeys.refreshToken);
    await _secureStorage.delete(StorageKeys.needsGoalSetup);
    await _secureStorage.delete(StorageKeys.keepSignedIn);
    _needsGoalSetup = false;
  }

  Future<Either<Failure, Unit>> _guard(Future<void> Function() action) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      await action();
      return right(unit);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  Future<Either<Failure, T>> _guardValue<T>(Future<T> Function() action) async {
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

  void _setStatus(AuthStatus status) {
    _status = status;
    _statusController.add(status);
  }
}
