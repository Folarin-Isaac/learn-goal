import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/goal_setup/domain/entities/learning_goal.dart';
import 'package:lengoal/features/goal_setup/domain/repositories/goal_repository.dart';

class SaveGoalUseCase {
  new(this._repository);

  final GoalRepository _repository;

  Future<Either<Failure, LearningGoal>> call({
    required String fieldId,
    required String examId,
    required String stageId,
    required List<String> topicIds,
    required DateTime targetDate,
  }) {
    return _repository.saveGoal(
      fieldId: fieldId,
      examId: examId,
      stageId: stageId,
      topicIds: topicIds,
      targetDate: targetDate,
    );
  }
}
