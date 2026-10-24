import 'package:lengoal/features/goal_setup/domain/entities/exam_goal.dart';

class ExamGoalModel extends ExamGoal {
  const new({
    required super.id,
    required super.categoryId,
    required super.goalName,
    super.examBody,
    super.description,
    super.examTargetDate,
    super.goalsHaveLevel,
    super.goalsHaveSubject,
    super.numberOfLevels,
  });

  factory fromJson(Map<String, dynamic> json) {
    final rawDate = json['examTargetDate'] as String?;
    return ExamGoalModel(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String? ?? '',
      goalName:
          json['goalName'] as String? ?? json['examBody'] as String? ?? '',
      examBody: json['examBody'] as String?,
      description: json['description'] as String?,
      examTargetDate: rawDate == null ? null : DateTime.tryParse(rawDate),
      goalsHaveLevel: json['goalsHaveLevel'] as bool? ?? false,
      goalsHaveSubject: json['goalsHaveSubject'] as bool? ?? false,
      numberOfLevels: json['numberOfLevels'] as int? ?? 0,
    );
  }
}
