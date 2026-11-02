import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lengoal/features/classes/domain/entities/lengoal_class.dart';
import 'package:lengoal/features/classes/domain/usecases/search_classes_usecase.dart';

part 'class_search_event.dart';
part 'class_search_state.dart';

class ClassSearchBloc extends Bloc<ClassSearchEvent, ClassSearchState> {
  new({required SearchClassesUseCase searchClassesUseCase})
    : _searchClassesUseCase = searchClassesUseCase,
      super(const ClassSearchState()) {
    on<ClassSearchQueryChanged>(_onQueryChanged);
    on<ClassSearchMoreRequested>(_onMoreRequested);
  }

  static const int pageSize = 15;

  final SearchClassesUseCase _searchClassesUseCase;

  Future<void> _onQueryChanged(
    ClassSearchQueryChanged event,
    Emitter<ClassSearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(const ClassSearchState());
      return;
    }
    emit(
      ClassSearchState(
        query: query,
        status: ClassSearchStatus.loading,
        results: state.results,
      ),
    );
    final result = await _searchClassesUseCase(
      query,
      page: 1,
      pageSize: pageSize,
    );
    // Handlers run concurrently, so a slower earlier search can finish
    // after a newer one; drop anything that no longer matches the box.
    if (state.query != query) return;
    result.match(
      (failure) => emit(
        ClassSearchState(
          query: query,
          status: ClassSearchStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (page) => emit(
        ClassSearchState(
          query: query,
          status: ClassSearchStatus.loaded,
          results: page.items,
          hasMore: page.hasMore,
          nextPage: 2,
        ),
      ),
    );
  }

  Future<void> _onMoreRequested(
    ClassSearchMoreRequested event,
    Emitter<ClassSearchState> emit,
  ) async {
    if (state.status != ClassSearchStatus.loaded ||
        !state.hasMore ||
        state.isLoadingMore) {
      return;
    }
    final query = state.query;
    final page = state.nextPage;
    emit(state.copyWith(isLoadingMore: true, loadMoreFailed: false));
    final result = await _searchClassesUseCase(
      query,
      page: page,
      pageSize: pageSize,
    );
    // The learner typed a new search (or this page already landed).
    if (state.query != query || state.nextPage != page) return;
    result.match(
      (_) => emit(state.copyWith(isLoadingMore: false, loadMoreFailed: true)),
      (more) {
        final seen = {for (final c in state.results) c.id};
        emit(
          state.copyWith(
            results: [
              ...state.results,
              ...more.items.where((c) => !seen.contains(c.id)),
            ],
            hasMore: more.hasMore,
            nextPage: page + 1,
            isLoadingMore: false,
          ),
        );
      },
    );
  }
}
