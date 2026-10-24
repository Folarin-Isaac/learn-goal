import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/goal_setup/domain/entities/exam_goal.dart';
import 'package:lengoal/features/goal_setup/domain/repositories/goal_repository.dart';

class GetGoalsUseCase {
  new(this._repository);

  final GoalRepository _repository;

  Future<Either<Failure, List<ExamGoal>>> call({
    required String categoryId,
    String? searchTerm,
  }) {
    return _repository.getGoals(categoryId: categoryId, searchTerm: searchTerm);
  }
}
