import 'package:lengoal/features/goal_setup/data/models/exam_goal_model.dart';
import 'package:lengoal/features/goal_setup/data/models/goal_category_model.dart';
import 'package:lengoal/features/goal_setup/domain/entities/exam_goal.dart';

abstract class GoalRemoteDataSource {
  Future<List<GoalCategoryModel>> getCategories({String? searchTerm});

  Future<List<ExamGoalModel>> getGoals({
    required String categoryId,
    String? searchTerm,
  });

  Future<List<ExamGoalModel>> getLearnerGoals({required String learnerId});

  // `levels` carry only the subjects the learner ticked.
  Future<void> addLearnerGoal({
    required String goalId,
    required DateTime targetDate,
    List<GoalLevel> levels = const [],
    List<GoalSubject> subjects = const [],
  });
}
