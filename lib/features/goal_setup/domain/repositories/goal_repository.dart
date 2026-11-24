import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/goal_setup/domain/entities/exam_goal.dart';
import 'package:lengoal/features/goal_setup/domain/entities/goal_category.dart';

abstract class GoalRepository {
  Future<Either<Failure, List<GoalCategory>>> getCategories({
    String? searchTerm,
  });

  Future<Either<Failure, List<ExamGoal>>> getGoals({
    required String categoryId,
    String? searchTerm,
  });

  Future<Either<Failure, List<ExamGoal>>> getLearnerGoals({
    required String learnerId,
  });

  // `levels` carry only the subjects the learner ticked.
  Future<Either<Failure, Unit>> addLearnerGoal({
    required String goalId,
    required DateTime targetDate,
    List<GoalLevel> levels = const [],
    List<GoalSubject> subjects = const [],
  });
}
