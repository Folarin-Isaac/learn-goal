import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/classes/domain/repositories/class_repository.dart';

class SetClassSavedUseCase {
  new(this._repository);

  final ClassRepository _repository;

  Future<Either<Failure, Unit>> call(String classId, {required bool saved}) {
    return saved
        ? _repository.saveClass(classId)
        : _repository.unsaveClass(classId);
  }
}
