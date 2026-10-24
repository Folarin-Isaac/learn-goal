import 'package:lengoal/features/goal_setup/data/models/exam_goal_model.dart';
import 'package:lengoal/features/goal_setup/data/models/exam_stage_model.dart';
import 'package:lengoal/features/goal_setup/data/models/goal_category_model.dart';
import 'package:lengoal/features/goal_setup/data/models/learning_goal_model.dart';

abstract class GoalRemoteDataSource {
  Future<List<GoalCategoryModel>> getCategories({String? searchTerm});

  Future<List<ExamGoalModel>> getGoals({
    required String categoryId,
    String? searchTerm,
  });

  // Each returned stage includes its topics — see ExamStageModel.
  Future<List<ExamStageModel>> getExamStages({required String examId});

  Future<LearningGoalModel> saveGoal({
    required String fieldId,
    required String examId,
    required String stageId,
    required List<String> topicIds,
    required DateTime targetDate,
  });
}
