import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lengoal/features/goal_setup/domain/entities/exam_goal.dart';
import 'package:lengoal/features/goal_setup/domain/entities/exam_stage.dart';
import 'package:lengoal/features/goal_setup/domain/entities/goal_category.dart';
import 'package:lengoal/features/goal_setup/domain/usecases/get_categories_usecase.dart';
import 'package:lengoal/features/goal_setup/domain/usecases/get_exam_stages_usecase.dart';
import 'package:lengoal/features/goal_setup/domain/usecases/get_goals_usecase.dart';
import 'package:lengoal/features/goal_setup/domain/usecases/save_goal_usecase.dart';

part 'goal_setup_event.dart';
part 'goal_setup_state.dart';

// One shared bloc for all 3 steps (not per-page) since each step
// depends on the last. Created via ShellRoute — see app_router.dart.
class GoalSetupBloc extends Bloc<GoalSetupEvent, GoalSetupState> {
  new({
    required GetCategoriesUseCase getCategoriesUseCase,
    required GetGoalsUseCase getGoalsUseCase,
    required GetExamStagesUseCase getExamStagesUseCase,
    required SaveGoalUseCase saveGoalUseCase,
  }) : _getCategoriesUseCase = getCategoriesUseCase,
       _getGoalsUseCase = getGoalsUseCase,
       _getExamStagesUseCase = getExamStagesUseCase,
       _saveGoalUseCase = saveGoalUseCase,
       super(const GoalSetupState()) {
    on<GoalSetupStarted>(_onStarted);
    on<GoalCategoryQueryChanged>(
      (event, emit) => emit(state.copyWith(categoryQuery: event.query)),
    );
    on<GoalCategorySelected>(_onCategorySelected);
    on<GoalStepTwoEntered>(_onStepTwoEntered);
    on<GoalQueryChanged>(
      (event, emit) => emit(state.copyWith(goalQuery: event.query)),
    );
    on<GoalSelected>(
      (event, emit) => emit(state.copyWith(selectedGoal: event.goal)),
    );
    on<GoalStageStepEntered>(_onStageStepEntered);
    on<GoalStageSelected>(_onStageSelected);
    on<GoalTopicToggled>(_onTopicToggled);
    on<GoalTargetDateChanged>(
      (event, emit) => emit(state.copyWith(targetDate: event.date)),
    );
    on<GoalSaveRequested>(_onSaveRequested);
  }

  final GetCategoriesUseCase _getCategoriesUseCase;
  final GetGoalsUseCase _getGoalsUseCase;
  final GetExamStagesUseCase _getExamStagesUseCase;
  final SaveGoalUseCase _saveGoalUseCase;

  Future<void> _onStarted(
    GoalSetupStarted event,
    Emitter<GoalSetupState> emit,
  ) async {
    if (state.categoriesStatus == GoalOptionsStatus.loaded) return;
    emit(state.copyWith(categoriesStatus: GoalOptionsStatus.loading));
    final result = await _getCategoriesUseCase();
    result.match(
      (failure) => emit(
        state.copyWith(
          categoriesStatus: GoalOptionsStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (categories) => emit(
        state.copyWith(
          categoriesStatus: GoalOptionsStatus.loaded,
          categories: categories,
        ),
      ),
    );
  }

  void _onCategorySelected(
    GoalCategorySelected event,
    Emitter<GoalSetupState> emit,
  ) {
    // Picking a different category invalidates the goal list and anything
    // chosen from it, so step 2 has to refetch rather than show stale rows.
    final isSameCategory = state.selectedCategory?.id == event.category.id;
    if (isSameCategory) return;
    emit(
      GoalSetupState(
        categoriesStatus: state.categoriesStatus,
        categories: state.categories,
        categoryQuery: state.categoryQuery,
        selectedCategory: event.category,
      ),
    );
  }

  Future<void> _onStepTwoEntered(
    GoalStepTwoEntered event,
    Emitter<GoalSetupState> emit,
  ) async {
    final category = state.selectedCategory;
    if (category == null || state.goalsStatus == GoalOptionsStatus.loaded) {
      return;
    }
    emit(state.copyWith(goalsStatus: GoalOptionsStatus.loading));
    final result = await _getGoalsUseCase(categoryId: category.id);
    result.match(
      (failure) => emit(
        state.copyWith(
          goalsStatus: GoalOptionsStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (goals) => emit(
        state.copyWith(goalsStatus: GoalOptionsStatus.loaded, goals: goals),
      ),
    );
  }

  Future<void> _onStageStepEntered(
    GoalStageStepEntered event,
    Emitter<GoalSetupState> emit,
  ) async {
    final goal = state.selectedGoal;
    if (goal == null || state.stagesStatus == GoalOptionsStatus.loaded) return;
    emit(state.copyWith(stagesStatus: GoalOptionsStatus.loading));
    final result = await _getExamStagesUseCase(examId: goal.id);
    result.match(
      (failure) => emit(
        state.copyWith(
          stagesStatus: GoalOptionsStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (stages) => emit(
        state.copyWith(stagesStatus: GoalOptionsStatus.loaded, stages: stages),
      ),
    );
  }

  void _onStageSelected(GoalStageSelected event, Emitter<GoalSetupState> emit) {
    // Switching stages resets the topic checklist — a topic id from the
    // previous stage has no meaning against the new one.
    emit(state.copyWith(selectedStage: event.stage, selectedTopicIds: {}));
  }

  void _onTopicToggled(GoalTopicToggled event, Emitter<GoalSetupState> emit) {
    final updated = {...state.selectedTopicIds};
    if (!updated.add(event.topicId)) {
      updated.remove(event.topicId);
    }
    emit(state.copyWith(selectedTopicIds: updated));
  }

  Future<void> _onSaveRequested(
    GoalSaveRequested event,
    Emitter<GoalSetupState> emit,
  ) async {
    final category = state.selectedCategory;
    final goal = state.selectedGoal;
    final date = state.targetDate;
    if (category == null || goal == null || date == null) return;

    emit(state.copyWith(saveStatus: GoalSaveStatus.saving));
    final result = await _saveGoalUseCase(
      fieldId: category.id,
      examId: goal.id,
      stageId: state.selectedStage?.id ?? '',
      topicIds: state.selectedTopicIds.toList(),
      targetDate: date,
    );

    result.match(
      (failure) => emit(
        state.copyWith(
          saveStatus: GoalSaveStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(state.copyWith(saveStatus: GoalSaveStatus.success)),
    );
  }
}
