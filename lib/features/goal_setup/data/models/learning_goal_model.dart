import 'package:lengoal/features/goal_setup/domain/entities/learning_goal.dart';

class LearningGoalModel extends LearningGoal {
  const new({
    required super.id,
    required super.fieldId,
    required super.examId,
    required super.stageId,
    required super.topicIds,
    required super.targetDate,
  });

  factory fromJson(Map<String, dynamic> json) {
    return LearningGoalModel(
      id: json['id'] as String,
      fieldId: json['fieldId'] as String,
      examId: json['examId'] as String,
      stageId: json['stageId'] as String,
      topicIds: (json['topicIds'] as List<dynamic>).cast<String>(),
      targetDate: DateTime.parse(json['targetDate'] as String),
    );
  }
}
