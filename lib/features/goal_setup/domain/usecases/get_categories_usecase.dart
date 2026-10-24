import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/goal_setup/domain/entities/goal_category.dart';
import 'package:lengoal/features/goal_setup/domain/repositories/goal_repository.dart';

class GetCategoriesUseCase {
  new(this._repository);

  final GoalRepository _repository;

  Future<Either<Failure, List<GoalCategory>>> call({String? searchTerm}) =>
      _repository.getCategories(searchTerm: searchTerm);
}
