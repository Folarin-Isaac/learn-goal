import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  new(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, Unit>> call({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phoneNumber,
  }) {
    return _repository.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      phoneNumber: phoneNumber,
    );
  }
}
