import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/classes/domain/entities/lengoal_class.dart';
import 'package:lengoal/features/classes/domain/repositories/class_repository.dart';

class GetSubscribedClassesUseCase {
  new(this._repository);

  final ClassRepository _repository;

  Future<Either<Failure, List<LengoalClass>>> call({String? searchTerm}) {
    return _repository.getSubscribedClasses(searchTerm: searchTerm);
  }
}
