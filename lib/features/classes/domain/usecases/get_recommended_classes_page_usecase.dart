import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/classes/domain/entities/class_page.dart';
import 'package:lengoal/features/classes/domain/repositories/class_repository.dart';

class GetRecommendedClassesPageUseCase {
  new(this._repository);

  final ClassRepository _repository;

  Future<Either<Failure, ClassPage>> call({
    required int page,
    required int pageSize,
    String? categoryId,
  }) {
    return _repository.getRecommendedClassesPage(
      page: page,
      pageSize: pageSize,
      categoryId: categoryId,
    );
  }
}
