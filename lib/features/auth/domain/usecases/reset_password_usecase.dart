import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/auth/domain/repositories/auth_repository.dart';

class ResetPasswordUseCase {
  new(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, Unit>> call({
    required String email,
    required String token,
    required String password,
  }) {
    return _repository.resetPassword(
      email: email,
      token: token,
      password: password,
    );
  }
}
