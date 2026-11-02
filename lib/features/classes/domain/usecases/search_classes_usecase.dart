import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/classes/domain/entities/class_page.dart';
import 'package:lengoal/features/classes/domain/repositories/class_repository.dart';

class SearchClassesUseCase {
  new(this._repository);

  final ClassRepository _repository;

  Future<Either<Failure, ClassPage>> call(
    String searchTerm, {
    required int page,
    required int pageSize,
  }) {
    return _repository.searchClasses(
      searchTerm,
      page: page,
      pageSize: pageSize,
    );
  }
}
