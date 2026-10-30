import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/classes/domain/entities/class_educator.dart';
import 'package:lengoal/features/classes/domain/repositories/class_repository.dart';

class GetClassEducatorsUseCase {
  new(this._repository);

  final ClassRepository _repository;

  Future<Either<Failure, List<ClassEducator>>> call(String classId) {
    return _repository.getClassEducators(classId);
  }
}
