import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/profile/domain/entities/learner_profile.dart';
import 'package:lengoal/features/profile/domain/repositories/profile_repository.dart';

class GetLearnerProfileUseCase {
  new(this._repository);

  final ProfileRepository _repository;

  Future<Either<Failure, LearnerProfile>> call({bool forceRefresh = false}) =>
      _repository.getLearnerProfile(forceRefresh: forceRefresh);

  LearnerProfile? get cached => _repository.cachedProfile;

  Stream<LearnerProfile?> get stream => _repository.profileStream;
}
