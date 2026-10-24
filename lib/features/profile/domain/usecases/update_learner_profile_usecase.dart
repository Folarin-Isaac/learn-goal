import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/profile/domain/repositories/profile_repository.dart';

class UpdateLearnerProfileUseCase {
  new(this._repository);

  final ProfileRepository _repository;

  Future<Either<Failure, Unit>> call({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? avatarUrl,
  }) {
    return _repository.updateLearnerProfile(
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      avatarUrl: avatarUrl,
    );
  }
}
