import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/goal_setup/domain/entities/exam_goal.dart';
import 'package:lengoal/features/goal_setup/domain/repositories/goal_repository.dart';

// Learner/AddLearnerGoal: adds one goal to the learner's goals.
class SaveGoalUseCase {
  new(this._repository);

  final GoalRepository _repository;

  Future<Either<Failure, Unit>> call({
    required String goalId,
    required DateTime targetDate,
    List<GoalLevel> levels = const [],
    List<GoalSubject> subjects = const [],
  }) {
    return _repository.addLearnerGoal(
      goalId: goalId,
      targetDate: targetDate,
      levels: levels,
      subjects: subjects,
    );
  }
}
