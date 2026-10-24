import 'package:lengoal/features/goal_setup/data/models/topic_model.dart';
import 'package:lengoal/features/goal_setup/domain/entities/exam_stage.dart';

class ExamStageModel extends ExamStage {
  const new({required super.id, required super.name, required super.topics});

  factory fromJson(Map<String, dynamic> json) {
    return ExamStageModel(
      id: json['id'] as String,
      name: json['name'] as String,
      topics: (json['topics'] as List<dynamic>)
          .map((topic) => TopicModel.fromJson(topic as Map<String, dynamic>))
          .toList(),
    );
  }
}
