import 'package:equatable/equatable.dart';

class LearningGoal extends Equatable {
  const new({
    required this.id,
    required this.fieldId,
    required this.examId,
    required this.stageId,
    required this.topicIds,
    required this.targetDate,
  });

  final String id;
  final String fieldId;
  final String examId;
  final String stageId;
  final List<String> topicIds;
  final DateTime targetDate;

  @override
  List<Object?> get props => [
    id,
    fieldId,
    examId,
    stageId,
    topicIds,
    targetDate,
  ];
}
