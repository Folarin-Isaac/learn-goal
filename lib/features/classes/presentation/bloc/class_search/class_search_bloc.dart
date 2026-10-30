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
  }

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
    final result = await _searchClassesUseCase(query);
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
      (classes) => emit(
        ClassSearchState(
          query: query,
          status: ClassSearchStatus.loaded,
          results: classes,
        ),
      ),
    );
  }
}
