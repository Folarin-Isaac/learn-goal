import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/auth/domain/repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  new(this._repository);

  final AuthRepository _repository;

  // Returns the reset token on success.
  Future<Either<Failure, String>> call({required String email}) {
    return _repository.forgotPassword(email: email);
  }
}
