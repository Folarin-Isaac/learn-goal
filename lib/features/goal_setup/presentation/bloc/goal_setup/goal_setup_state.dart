part of 'goal_setup_bloc.dart';

enum GoalOptionsStatus { initial, loading, loaded, failure }

enum GoalSaveStatus { initial, saving, success, failure }

class GoalSetupState extends Equatable {
  const new({
    this.categoriesStatus = GoalOptionsStatus.initial,
    this.categories = const [],
    this.categoryQuery = '',
    this.selectedCategory,
    this.goalsStatus = GoalOptionsStatus.initial,
    this.goals = const [],
    this.goalQuery = '',
    this.selectedGoal,
    this.stagesStatus = GoalOptionsStatus.initial,
    this.stages = const [],
    this.selectedStage,
    this.selectedTopicIds = const {},
    this.targetDate,
    this.saveStatus = GoalSaveStatus.initial,
    this.errorMessage,
  });

  final GoalOptionsStatus categoriesStatus;
  final List<GoalCategory> categories;
  final String categoryQuery;
  final GoalCategory? selectedCategory;

  final GoalOptionsStatus goalsStatus;
  final List<ExamGoal> goals;
  final String goalQuery;
  final ExamGoal? selectedGoal;

  final GoalOptionsStatus stagesStatus;
  final List<ExamStage> stages;
  final ExamStage? selectedStage;
  final Set<String> selectedTopicIds;
  final DateTime? targetDate;

  final GoalSaveStatus saveStatus;
  final String? errorMessage;

  List<GoalCategory> get filteredCategories => categoryQuery.isEmpty
      ? categories
      : categories
            .where(
              (c) => c.name.toLowerCase().contains(categoryQuery.toLowerCase()),
            )
            .toList();

  List<ExamGoal> get filteredGoals => goalQuery.isEmpty
      ? goals
      : goals
            .where(
              (g) => g.goalName.toLowerCase().contains(goalQuery.toLowerCase()),
            )
            .toList();

  bool get canSave => selectedGoal != null && targetDate != null;

  GoalSetupState copyWith({
    GoalOptionsStatus? categoriesStatus,
    List<GoalCategory>? categories,
    String? categoryQuery,
    GoalCategory? selectedCategory,
    GoalOptionsStatus? goalsStatus,
    List<ExamGoal>? goals,
    String? goalQuery,
    ExamGoal? selectedGoal,
    GoalOptionsStatus? stagesStatus,
    List<ExamStage>? stages,
    ExamStage? selectedStage,
    Set<String>? selectedTopicIds,
    DateTime? targetDate,
    GoalSaveStatus? saveStatus,
    String? errorMessage,
  }) {
    return GoalSetupState(
      categoriesStatus: categoriesStatus ?? this.categoriesStatus,
      categories: categories ?? this.categories,
      categoryQuery: categoryQuery ?? this.categoryQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      goalsStatus: goalsStatus ?? this.goalsStatus,
      goals: goals ?? this.goals,
      goalQuery: goalQuery ?? this.goalQuery,
      selectedGoal: selectedGoal ?? this.selectedGoal,
      stagesStatus: stagesStatus ?? this.stagesStatus,
      stages: stages ?? this.stages,
      selectedStage: selectedStage ?? this.selectedStage,
      selectedTopicIds: selectedTopicIds ?? this.selectedTopicIds,
      targetDate: targetDate ?? this.targetDate,
      saveStatus: saveStatus ?? this.saveStatus,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    categoriesStatus,
    categories,
    categoryQuery,
    selectedCategory,
    goalsStatus,
    goals,
    goalQuery,
    selectedGoal,
    stagesStatus,
    stages,
    selectedStage,
    selectedTopicIds,
    targetDate,
    saveStatus,
    errorMessage,
  ];
}
