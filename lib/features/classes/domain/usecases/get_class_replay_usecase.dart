import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/classes/domain/entities/class_replay.dart';
import 'package:lengoal/features/classes/domain/repositories/class_repository.dart';

class GetClassReplayUseCase {
  new(this._repository);

  final ClassRepository _repository;

  Future<Either<Failure, ClassReplay>> call(String classOutlineId) {
    return _repository.getClassReplay(classOutlineId);
  }
}
