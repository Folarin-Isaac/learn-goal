import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/classes/domain/entities/class_goal_scope.dart';
import 'package:lengoal/features/classes/domain/entities/lengoal_class.dart';
import 'package:lengoal/features/classes/domain/usecases/get_recommended_classes_usecase.dart';
import 'package:lengoal/features/classes/domain/usecases/get_saved_classes_usecase.dart';
import 'package:lengoal/features/classes/domain/usecases/get_subscribed_classes_usecase.dart';
import 'package:lengoal/features/classes/domain/usecases/set_class_saved_usecase.dart';

part 'class_list_event.dart';
part 'class_list_state.dart';

enum ClassListSource {
  // Full library, used by the My Classes tab.
  subscribed,
  // Dashboard's "My Classes": subscriptions for the active goal only.
  goalSubscribed,
  recommended,
  saved;

  bool get isGoalScoped =>
      this == ClassListSource.goalSubscribed ||
      this == ClassListSource.recommended;
}

// One long-lived bloc per list, shared by every screen showing that list.
// Goal-scoped lists hold off until the active goal is known, then reload
// whenever it changes. The saved list also owns save/unsave, so every
// heart and "Save class" button reads from the same source of truth.
class ClassListBloc extends Bloc<ClassListEvent, ClassListState> {
  new({
    required this.source,
    required GetSubscribedClassesUseCase getSubscribedClassesUseCase,
    required GetRecommendedClassesUseCase getRecommendedClassesUseCase,
    required GetSavedClassesUseCase getSavedClassesUseCase,
    required SetClassSavedUseCase setClassSavedUseCase,
  }) : _getSubscribedClassesUseCase = getSubscribedClassesUseCase,
       _getRecommendedClassesUseCase = getRecommendedClassesUseCase,
       _getSavedClassesUseCase = getSavedClassesUseCase,
       _setClassSavedUseCase = setClassSavedUseCase,
       super(const ClassListState()) {
    on<ClassListRequested>(_onRequested);
    on<ClassListScopeChanged>(_onScopeChanged);
    on<ClassSaveToggled>(_onSaveToggled);
    on<ClassListPrefetchRequested>(_onPrefetchRequested);
    on<ClassListCleared>((event, emit) {
      _byScope.clear();
      emit(const ClassListState());
    });
  }

  // Data younger than this is served as-is when a screen asks again;
  // pull-to-refresh bypasses it.
  static const Duration freshFor = Duration(minutes: 3);

  // Last rows loaded per goal, so switching back to a goal is instant and
  // other goals can be preloaded. Only goal-scoped lists use more than the
  // single null-scope entry.
  final Map<ClassGoalScope?, ({List<LengoalClass> classes, DateTime at})>
  _byScope = {};

  static bool _isFresh(DateTime at) => DateTime.now().difference(at) < freshFor;

  final ClassListSource source;
  final GetSubscribedClassesUseCase _getSubscribedClassesUseCase;
  final GetRecommendedClassesUseCase _getRecommendedClassesUseCase;
  final GetSavedClassesUseCase _getSavedClassesUseCase;
  final SetClassSavedUseCase _setClassSavedUseCase;

  bool get _waitingForScope => source.isGoalScoped && !state.scopeResolved;

  Future<void> _onRequested(
    ClassListRequested event,
    Emitter<ClassListState> emit,
  ) async {
    if (_waitingForScope) return;
    if (state.status == ClassListStatus.loading || state.isRefreshing) return;
    final loadedAt = state.loadedAt;
    final isFresh =
        state.status == ClassListStatus.loaded &&
        loadedAt != null &&
        DateTime.now().difference(loadedAt) < freshFor;
    if (isFresh && !event.force) return;
    await _load(emit);
  }

  Future<void> _onScopeChanged(
    ClassListScopeChanged event,
    Emitter<ClassListState> emit,
  ) async {
    if (state.scopeResolved && state.scope == event.scope) return;
    final cached = _byScope[event.scope];
    if (cached == null) {
      // A goal never loaded before starts from the skeleton rather than
      // briefly showing the previous goal's classes.
      emit(ClassListState(scope: event.scope, scopeResolved: true));
      await _load(emit);
      return;
    }
    emit(
      ClassListState(
        scope: event.scope,
        scopeResolved: true,
        status: ClassListStatus.loaded,
        classes: cached.classes,
        loadedAt: cached.at,
      ),
    );
    if (!_isFresh(cached.at)) await _load(emit);
  }

  // Warms the cache for goals other than the active one, one at a time so
  // the active goal's own requests aren't competing with a burst.
  Future<void> _onPrefetchRequested(
    ClassListPrefetchRequested event,
    Emitter<ClassListState> emit,
  ) async {
    for (final scope in event.scopes) {
      if (isClosed || scope == state.scope) continue;
      final cached = _byScope[scope];
      if (cached != null && _isFresh(cached.at)) continue;
      final result = await _fetch(scope);
      result.match(
        (_) {},
        (classes) => _byScope[scope] = (classes: classes, at: DateTime.now()),
      );
    }
  }

  Future<void> _load(Emitter<ClassListState> emit) async {
    final scope = state.scope;
    // A refresh keeps the current rows on screen instead of flashing
    // back to the skeleton.
    final hadData = state.status == ClassListStatus.loaded;
    emit(
      hadData
          ? state.copyWith(isRefreshing: true)
          : state.copyWith(status: ClassListStatus.loading),
    );
    final result = await _fetch(scope);
    final loadedAt = DateTime.now();
    result.match(
      (_) {},
      (classes) => _byScope[scope] = (classes: classes, at: loadedAt),
    );
    // The goal changed while this request was in flight; its rows are
    // cached for that goal but must not replace the current goal's.
    if (state.scope != scope) return;
    result.match(
      (failure) => emit(
        state.copyWith(
          status: hadData ? ClassListStatus.loaded : ClassListStatus.failure,
          isRefreshing: false,
          errorMessage: failure.message,
        ),
      ),
      (classes) => emit(
        state.copyWith(
          status: ClassListStatus.loaded,
          classes: classes,
          loadedAt: loadedAt,
          isRefreshing: false,
        ),
      ),
    );
  }

  // Optimistic: the list changes immediately and is rolled back if the
  // server refuses, so hearts respond instantly even on slow networks.
  Future<void> _onSaveToggled(
    ClassSaveToggled event,
    Emitter<ClassListState> emit,
  ) async {
    final target = event.lengoalClass;
    final before = state.classes;
    final without = before.where((c) => c.id != target.id).toList();
    if (state.status == ClassListStatus.loaded) {
      emit(
        state.copyWith(classes: event.save ? [target, ...without] : without),
      );
    }
    final result = await _setClassSavedUseCase(target.id, saved: event.save);
    result.match((failure) {
      if (state.status == ClassListStatus.loaded) {
        emit(state.copyWith(classes: before));
      }
      event.completer?.complete(failure);
    }, (_) => event.completer?.complete());
  }

  Future<Either<Failure, List<LengoalClass>>> _fetch(ClassGoalScope? scope) {
    return switch (source) {
      ClassListSource.subscribed => _getSubscribedClassesUseCase(),
      ClassListSource.goalSubscribed => _getSubscribedClassesUseCase(
        goalId: scope?.goalId,
      ),
      ClassListSource.recommended => _getRecommendedClassesUseCase(
        categoryId: scope?.categoryId,
        goalName: scope?.goalName,
      ),
      ClassListSource.saved => _getSavedClassesUseCase(),
    };
  }
}
