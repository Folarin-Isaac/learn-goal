import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/classes/domain/entities/live_class_access.dart';
import 'package:lengoal/features/classes/domain/repositories/class_repository.dart';

class JoinLiveClassUseCase {
  new(this._repository);

  final ClassRepository _repository;

  Future<Either<Failure, LiveClassAccess>> call(String classOutlineId) {
    return _repository.joinLiveClass(classOutlineId);
  }
}
