import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/auth/domain/entities/user_entity.dart';
import 'package:lengoal/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  new(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }
}
