import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/classes/domain/entities/class_attendance.dart';
import 'package:lengoal/features/classes/domain/repositories/class_repository.dart';

class GetClassAttendanceUseCase {
  new(this._repository);

  final ClassRepository _repository;

  Future<Either<Failure, ClassAttendance>> call(String classId) {
    return _repository.getClassAttendance(classId);
  }
}
