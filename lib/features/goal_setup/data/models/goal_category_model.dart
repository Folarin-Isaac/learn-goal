import 'package:lengoal/features/goal_setup/domain/entities/goal_category.dart';

class GoalCategoryModel extends GoalCategory {
  const new({
    required super.id,
    required super.name,
    super.description,
    super.noOfGoals,
  });

  factory fromJson(Map<String, dynamic> json) {
    return GoalCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      noOfGoals: json['noOfGoals'] as int? ?? 0,
    );
  }
}
