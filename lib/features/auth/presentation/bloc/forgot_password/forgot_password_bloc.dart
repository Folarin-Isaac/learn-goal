import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lengoal/features/auth/domain/usecases/forgot_password_usecase.dart';

part 'forgot_password_event.dart';
part 'forgot_password_state.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  new({required ForgotPasswordUseCase forgotPasswordUseCase})
    : _forgotPasswordUseCase = forgotPasswordUseCase,
      super(const ForgotPasswordState()) {
    // Resets status to initial so a stale failure doesn't re-trigger
    // the listener's old snackbar (see LoginBloc for the full reason).
    on<ForgotPasswordEmailChanged>(
      (event, emit) => emit(
        state.copyWith(
          email: event.email,
          status: ForgotPasswordStatus.initial,
        ),
      ),
    );
    on<ForgotPasswordSubmitted>(_onSubmitted);
  }

  final ForgotPasswordUseCase _forgotPasswordUseCase;

  Future<void> _onSubmitted(
    ForgotPasswordSubmitted event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(state.copyWith(status: ForgotPasswordStatus.submitting));

    final result = await _forgotPasswordUseCase(email: state.email);

    result.match(
      (failure) => emit(
        state.copyWith(
          status: ForgotPasswordStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (token) => emit(
        state.copyWith(status: ForgotPasswordStatus.success, resetToken: token),
      ),
    );
  }
}
