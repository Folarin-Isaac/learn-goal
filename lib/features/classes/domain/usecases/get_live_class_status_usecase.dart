import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/classes/domain/entities/live_class_status.dart';
import 'package:lengoal/features/classes/domain/repositories/class_repository.dart';

class GetLiveClassStatusUseCase {
  new(this._repository);

  final ClassRepository _repository;

  Future<Either<Failure, LiveClassStatus>> call(String classOutlineId) {
    return _repository.getLiveClassStatus(classOutlineId);
  }
}
