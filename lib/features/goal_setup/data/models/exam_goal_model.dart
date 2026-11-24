import 'package:lengoal/core/utils/server_date.dart';
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
    super.levels,
    super.subjects,
  });

  factory fromJson(Map<String, dynamic> json) {
    return ExamGoalModel(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String? ?? '',
      goalName:
          json['goalName'] as String? ?? json['examBody'] as String? ?? '',
      examBody: json['examBody'] as String?,
      description: json['description'] as String?,
      examTargetDate: parseServerDate(json['examTargetDate'] as String?),
      goalsHaveLevel: json['goalsHaveLevel'] as bool? ?? false,
      goalsHaveSubject: json['goalsHaveSubject'] as bool? ?? false,
      numberOfLevels: json['numberOfLevels'] as int? ?? 0,
      levels: _list(json['levels'], (level) {
        return GoalLevel(
          id: level['id'] as String? ?? '',
          name: level['name'] as String? ?? '',
          subjects: _list(level['subjects'], _subject),
        );
      }),
      subjects: _list(json['subjects'], _subject),
    );
  }

  static GoalSubject _subject(Map<String, dynamic> json) => GoalSubject(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
  );

  static List<T> _list<T>(
    Object? raw,
    T Function(Map<String, dynamic> json) parse,
  ) {
    if (raw is! List) return const [];
    return [
      for (final item in raw)
        if (item is Map<String, dynamic>) parse(item),
    ];
  }
}
