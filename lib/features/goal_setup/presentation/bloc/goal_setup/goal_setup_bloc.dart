import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lengoal/features/goal_setup/domain/entities/exam_goal.dart';
import 'package:lengoal/features/goal_setup/domain/entities/goal_category.dart';
import 'package:lengoal/features/goal_setup/domain/usecases/get_categories_usecase.dart';
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
    required SaveGoalUseCase saveGoalUseCase,
  }) : _getCategoriesUseCase = getCategoriesUseCase,
       _getGoalsUseCase = getGoalsUseCase,
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
    on<GoalSelected>(_onGoalSelected);
    on<GoalLevelTapped>(_onLevelTapped);
    on<GoalLevelSubjectToggled>(
      (event, emit) => emit(
        state.copyWith(
          levelSubjectIds: _toggle(state.levelSubjectIds, event.subjectId),
        ),
      ),
    );
    on<GoalSubjectToggled>(
      (event, emit) => emit(
        state.copyWith(subjectIds: _toggle(state.subjectIds, event.subjectId)),
      ),
    );
    on<GoalTargetDateChanged>(
      (event, emit) => emit(state.copyWith(targetDate: () => event.date)),
    );
    on<GoalSaveRequested>(_onSaveRequested);
  }

  final GetCategoriesUseCase _getCategoriesUseCase;
  final GetGoalsUseCase _getGoalsUseCase;
  final SaveGoalUseCase _saveGoalUseCase;

  static Set<String> _toggle(Set<String> ids, String id) {
    final updated = {...ids};
    if (!updated.add(id)) updated.remove(id);
    return updated;
  }

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

  // A different goal has different levels/subjects, so step 3's choices
  // start over.
  void _onGoalSelected(GoalSelected event, Emitter<GoalSetupState> emit) {
    if (state.selectedGoal?.id == event.goal.id) return;
    emit(
      state.copyWith(
        selectedGoal: event.goal,
        selectedLevelId: () => null,
        levelSubjectIds: const {},
        subjectIds: const {},
        targetDate: () => null,
      ),
    );
  }

  // Same as the web: one level at a time; picking another level (or the
  // same one again) clears the ticked subjects.
  void _onLevelTapped(GoalLevelTapped event, Emitter<GoalSetupState> emit) {
    final same = state.selectedLevelId == event.levelId;
    emit(
      state.copyWith(
        selectedLevelId: () => same ? null : event.levelId,
        levelSubjectIds: const {},
      ),
    );
  }

  Future<void> _onSaveRequested(
    GoalSaveRequested event,
    Emitter<GoalSetupState> emit,
  ) async {
    final goal = state.selectedGoal;
    final date = state.targetDate;
    if (goal == null || date == null) return;
    if (state.saveStatus == GoalSaveStatus.saving) return;

    final level = state.selectedLevel;
    emit(state.copyWith(saveStatus: GoalSaveStatus.saving));
    final result = await _saveGoalUseCase(
      goalId: goal.id,
      targetDate: date,
      levels: [
        if (level != null)
          GoalLevel(
            id: level.id,
            name: level.name,
            subjects: level.subjects
                .where((s) => state.levelSubjectIds.contains(s.id))
                .toList(),
          ),
      ],
      subjects: goal.subjects
          .where((s) => state.subjectIds.contains(s.id))
          .toList(),
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
