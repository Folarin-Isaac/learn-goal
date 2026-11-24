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

// Step 3, goals with levels: one level at a time (tapping the chosen level
// again clears it), then any of that level's subjects.
class GoalLevelTapped extends GoalSetupEvent {
  const new(this.levelId);
  final String levelId;

  @override
  List<Object?> get props => [levelId];
}

class GoalLevelSubjectToggled extends GoalSetupEvent {
  const new(this.subjectId);
  final String subjectId;

  @override
  List<Object?> get props => [subjectId];
}

// Step 3, goals with subjects (no levels): any number of subjects.
class GoalSubjectToggled extends GoalSetupEvent {
  const new(this.subjectId);
  final String subjectId;

  @override
  List<Object?> get props => [subjectId];
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
