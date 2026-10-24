import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lengoal/features/auth/domain/usecases/reset_password_usecase.dart';

part 'reset_password_event.dart';
part 'reset_password_state.dart';

class ResetPasswordBloc extends Bloc<ResetPasswordEvent, ResetPasswordState> {
  new({
    required String email,
    required String token,
    required ResetPasswordUseCase resetPasswordUseCase,
  }) : _resetPasswordUseCase = resetPasswordUseCase,
       super(ResetPasswordState(email: email, token: token)) {
    // Every field-changed handler resets status back to initial — see
    // the equivalent comment in LoginBloc for why this matters.
    on<ResetPasswordChanged>(
      (event, emit) => emit(
        state.copyWith(
          password: event.password,
          status: ResetPasswordStatus.initial,
        ),
      ),
    );
    on<ResetPasswordConfirmChanged>(
      (event, emit) => emit(
        state.copyWith(
          confirmPassword: event.confirmPassword,
          status: ResetPasswordStatus.initial,
        ),
      ),
    );
    on<ResetPasswordSubmitted>(_onSubmitted);
  }

  final ResetPasswordUseCase _resetPasswordUseCase;

  Future<void> _onSubmitted(
    ResetPasswordSubmitted event,
    Emitter<ResetPasswordState> emit,
  ) async {
    if (!state.isValid) return;
    emit(state.copyWith(status: ResetPasswordStatus.submitting));

    final result = await _resetPasswordUseCase(
      email: state.email,
      token: state.token,
      password: state.password,
    );

    result.match(
      (failure) => emit(
        state.copyWith(
          status: ResetPasswordStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(state.copyWith(status: ResetPasswordStatus.success)),
    );
  }
}
