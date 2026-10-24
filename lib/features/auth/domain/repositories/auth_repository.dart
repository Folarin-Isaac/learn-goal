import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/auth/domain/entities/user_entity.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, Unit>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phoneNumber,
  });

  Future<Either<Failure, Unit>> verifyOtp({
    required String email,
    required String otp,
  });

  Future<Either<Failure, Unit>> resendOtp({required String email});

  // Returns the reset token on success — the API hands it back
  // directly, no emailed link needed.
  Future<Either<Failure, String>> forgotPassword({required String email});

  Future<Either<Failure, Unit>> resetPassword({
    required String email,
    required String token,
    required String password,
  });

  Future<Either<Failure, Unit>> logout();

  AuthStatus get currentAuthStatus;

  Stream<AuthStatus> get authStatusStream;

  Future<void> checkAuthStatus();

  // True when login's isFirstLogin says this account hasn't done goal
  // setup yet. Persisted, cleared via completeGoalSetup().
  bool get needsGoalSetup;

  Future<void> completeGoalSetup();

  // Reads first/last name from the stored token's claims, no network
  // call. id is left blank — the token doesn't carry one.
  Future<UserEntity?> getCurrentUser();
}
