import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/auth/domain/repositories/auth_repository.dart';

class ResendOtpUseCase {
  new(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, Unit>> call({required String email}) {
    return _repository.resendOtp(email: email);
  }
}
