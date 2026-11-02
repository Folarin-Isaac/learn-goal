part of 'active_goal_cubit.dart';

enum ActiveGoalStatus { initial, loading, ready, failure }

class ActiveGoalState extends Equatable {
  const new({
    this.status = ActiveGoalStatus.initial,
    this.goals = const [],
    this.activeGoal,
  });

  final ActiveGoalStatus status;
  final List<ExamGoal> goals;
  final ExamGoal? activeGoal;

  // Lists can stop waiting once this is true; on failure they fall back
  // to whatever goal was active before (or none).
  bool get isResolved =>
      status == ActiveGoalStatus.ready || status == ActiveGoalStatus.failure;

  ActiveGoalState copyWith({ActiveGoalStatus? status}) {
    return ActiveGoalState(
      status: status ?? this.status,
      goals: goals,
      activeGoal: activeGoal,
    );
  }

  @override
  List<Object?> get props => [status, goals, activeGoal];
}
