import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/goal_setup/domain/entities/exam_goal.dart';
import 'package:lengoal/features/goal_setup/domain/repositories/goal_repository.dart';

class GetLearnerGoalsUseCase {
  new(this._repository);

  final GoalRepository _repository;

  Future<Either<Failure, List<ExamGoal>>> call({required String learnerId}) {
    return _repository.getLearnerGoals(learnerId: learnerId);
  }
}
