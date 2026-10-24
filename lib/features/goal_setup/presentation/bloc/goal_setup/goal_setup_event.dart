part of 'goal_setup_bloc.dart';

sealed class GoalSetupEvent extends Equatable {
  const new();

  @override
  List<Object?> get props => [];
}

// Fired once when the category-selection page mounts.
class GoalSetupStarted extends GoalSetupEvent {
  const new();
}

class GoalCategoryQueryChanged extends GoalSetupEvent {
  const new(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

class GoalCategorySelected extends GoalSetupEvent {
  const new(this.category);
  final GoalCategory category;

  @override
  List<Object?> get props => [category];
}

// Fired when the exam page mounts — loads the goals for the selected
// category.
class GoalStepTwoEntered extends GoalSetupEvent {
  const new();
}

class GoalQueryChanged extends GoalSetupEvent {
  const new(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

class GoalSelected extends GoalSetupEvent {
  const new(this.goal);
  final ExamGoal goal;

  @override
  List<Object?> get props => [goal];
}

// Fired when the stage page mounts — loads stages for the selected goal.
class GoalStageStepEntered extends GoalSetupEvent {
  const new();
}

class GoalStageSelected extends GoalSetupEvent {
  const new(this.stage);
  final ExamStage stage;

  @override
  List<Object?> get props => [stage];
}

class GoalTopicToggled extends GoalSetupEvent {
  const new(this.topicId);
  final String topicId;

  @override
  List<Object?> get props => [topicId];
}

class GoalTargetDateChanged extends GoalSetupEvent {
  const new(this.date);
  final DateTime date;

  @override
  List<Object?> get props => [date];
}

class GoalSaveRequested extends GoalSetupEvent {
  const new();
}
