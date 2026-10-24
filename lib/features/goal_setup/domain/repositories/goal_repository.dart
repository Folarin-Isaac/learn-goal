import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/goal_setup/domain/entities/exam_goal.dart';
import 'package:lengoal/features/goal_setup/domain/entities/exam_stage.dart';
import 'package:lengoal/features/goal_setup/domain/entities/goal_category.dart';
import 'package:lengoal/features/goal_setup/domain/entities/learning_goal.dart';

abstract class GoalRepository {
  Future<Either<Failure, List<GoalCategory>>> getCategories({
    String? searchTerm,
  });

  Future<Either<Failure, List<ExamGoal>>> getGoals({
    required String categoryId,
    String? searchTerm,
  });

  Future<Either<Failure, List<ExamStage>>> getExamStages({
    required String examId,
  });

  Future<Either<Failure, LearningGoal>> saveGoal({
    required String fieldId,
    required String examId,
    required String stageId,
    required List<String> topicIds,
    required DateTime targetDate,
  });
}
