import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lengoal/features/classes/domain/entities/lengoal_class.dart';
import 'package:lengoal/features/classes/domain/usecases/get_class_usecase.dart';

part 'class_detail_event.dart';
part 'class_detail_state.dart';

// Seeded with the list row the user tapped (list endpoints already return
// the full class shape) so the page renders instantly; GetClass then
// refreshes it in place.
class ClassDetailBloc extends Bloc<ClassDetailEvent, ClassDetailState> {
  new({required LengoalClass initial, required GetClassUseCase getClassUseCase})
    : _getClassUseCase = getClassUseCase,
      super(ClassDetailState(lengoalClass: initial)) {
    on<ClassDetailRefreshRequested>(_onRefreshRequested);
  }

  final GetClassUseCase _getClassUseCase;

  Future<void> _onRefreshRequested(
    ClassDetailRefreshRequested event,
    Emitter<ClassDetailState> emit,
  ) async {
    emit(state.copyWith(isRefreshing: true));
    final result = await _getClassUseCase(state.lengoalClass.id);
    result.match(
      (failure) => emit(
        state.copyWith(isRefreshing: false, errorMessage: failure.message),
      ),
      (lengoalClass) =>
          emit(state.copyWith(isRefreshing: false, lengoalClass: lengoalClass)),
    );
  }
}
