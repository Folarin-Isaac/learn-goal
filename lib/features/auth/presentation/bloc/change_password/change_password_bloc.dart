import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lengoal/features/auth/domain/usecases/change_password_usecase.dart';

part 'change_password_event.dart';
part 'change_password_state.dart';

class ChangePasswordBloc
    extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  new({required ChangePasswordUseCase changePasswordUseCase})
    : _changePasswordUseCase = changePasswordUseCase,
      super(const ChangePasswordState()) {
    on<ChangePasswordSubmitted>(_onSubmitted);
  }

  final ChangePasswordUseCase _changePasswordUseCase;

  Future<void> _onSubmitted(
    ChangePasswordSubmitted event,
    Emitter<ChangePasswordState> emit,
  ) async {
    if (state.status == ChangePasswordStatus.submitting) return;
    emit(const ChangePasswordState(status: ChangePasswordStatus.submitting));

    final result = await _changePasswordUseCase(
      oldPassword: event.oldPassword,
      newPassword: event.newPassword,
    );

    result.match(
      (failure) => emit(
        ChangePasswordState(
          status: ChangePasswordStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) =>
          emit(const ChangePasswordState(status: ChangePasswordStatus.success)),
    );
  }
}
