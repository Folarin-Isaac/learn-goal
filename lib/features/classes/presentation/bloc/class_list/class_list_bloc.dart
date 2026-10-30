import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/classes/domain/entities/lengoal_class.dart';
import 'package:lengoal/features/classes/domain/usecases/get_recommended_classes_usecase.dart';
import 'package:lengoal/features/classes/domain/usecases/get_saved_classes_usecase.dart';
import 'package:lengoal/features/classes/domain/usecases/get_subscribed_classes_usecase.dart';

part 'class_list_event.dart';
part 'class_list_state.dart';

enum ClassListSource { subscribed, recommended, saved }

// One bloc type serves every class list; each screen section creates its
// own instance bound to the endpoint it shows.
class ClassListBloc extends Bloc<ClassListEvent, ClassListState> {
  new({
    required this.source,
    required GetSubscribedClassesUseCase getSubscribedClassesUseCase,
    required GetRecommendedClassesUseCase getRecommendedClassesUseCase,
    required GetSavedClassesUseCase getSavedClassesUseCase,
  }) : _getSubscribedClassesUseCase = getSubscribedClassesUseCase,
       _getRecommendedClassesUseCase = getRecommendedClassesUseCase,
       _getSavedClassesUseCase = getSavedClassesUseCase,
       super(const ClassListState()) {
    on<ClassListRequested>(_onRequested);
    on<ClassListCleared>((event, emit) => emit(const ClassListState()));
  }

  // Data younger than this is served as-is when a screen asks again;
  // pull-to-refresh bypasses it.
  static const Duration freshFor = Duration(minutes: 3);

  final ClassListSource source;
  final GetSubscribedClassesUseCase _getSubscribedClassesUseCase;
  final GetRecommendedClassesUseCase _getRecommendedClassesUseCase;
  final GetSavedClassesUseCase _getSavedClassesUseCase;

  Future<void> _onRequested(
    ClassListRequested event,
    Emitter<ClassListState> emit,
  ) async {
    if (state.status == ClassListStatus.loading || state.isRefreshing) return;
    final loadedAt = state.loadedAt;
    final isFresh =
        state.status == ClassListStatus.loaded &&
        loadedAt != null &&
        DateTime.now().difference(loadedAt) < freshFor;
    if (isFresh && !event.force) return;

    // A refresh keeps the current rows on screen instead of flashing
    // back to the skeleton.
    final hadData = state.status == ClassListStatus.loaded;
    emit(
      hadData
          ? state.copyWith(isRefreshing: true)
          : state.copyWith(status: ClassListStatus.loading),
    );
    final result = await _fetch();
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
          loadedAt: DateTime.now(),
          isRefreshing: false,
        ),
      ),
    );
  }

  Future<Either<Failure, List<LengoalClass>>> _fetch() {
    return switch (source) {
      ClassListSource.subscribed => _getSubscribedClassesUseCase(),
      ClassListSource.recommended => _getRecommendedClassesUseCase(),
      ClassListSource.saved => _getSavedClassesUseCase(),
    };
  }
}
