import 'package:equatable/equatable.dart';

// The learner's active goal, as far as class lists care: the goal to
// filter subscriptions by, and its category/name to rank recommendations.
class ClassGoalScope extends Equatable {
  const new({
    required this.goalId,
    required this.categoryId,
    required this.goalName,
  });

  final String goalId;
  final String categoryId;
  final String goalName;

  @override
  List<Object?> get props => [goalId, categoryId, goalName];
}
