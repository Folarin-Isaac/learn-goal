import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/classes/domain/entities/class_referral.dart';
import 'package:lengoal/features/classes/domain/repositories/class_repository.dart';

class GenerateClassReferralUseCase {
  new(this._repository);

  final ClassRepository _repository;

  Future<Either<Failure, ClassReferral>> call(String classId) {
    return _repository.generateClassReferral(classId);
  }
}
