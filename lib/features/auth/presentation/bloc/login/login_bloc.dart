import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/core/utils/extensions/string_extensions.dart';
import 'package:lengoal/features/auth/domain/usecases/login_usecase.dart';
import 'package:lengoal/features/auth/domain/usecases/resend_otp_usecase.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  new({
    required LoginUseCase loginUseCase,
    required ResendOtpUseCase resendOtpUseCase,
  }) : _loginUseCase = loginUseCase,
       _resendOtpUseCase = resendOtpUseCase,
       super(const LoginState()) {
    // Resets status to initial on every field change — otherwise a
    // stale status survives and re-fires the listener's old side effect.
    on<LoginEmailChanged>(
      (event, emit) =>
          emit(state.copyWith(email: event.email, status: LoginStatus.initial)),
    );
    on<LoginPasswordChanged>(
      (event, emit) => emit(
        state.copyWith(password: event.password, status: LoginStatus.initial),
      ),
    );
    on<LoginKeepSignedInToggled>(
      (event, emit) => emit(
        state.copyWith(keepSignedIn: event.value, status: LoginStatus.initial),
      ),
    );
    on<LoginSubmitted>(_onSubmitted);
  }

  final LoginUseCase _loginUseCase;
  final ResendOtpUseCase _resendOtpUseCase;

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (!state.isValid) return;
    emit(state.copyWith(status: LoginStatus.submitting));

    final result = await _loginUseCase(
      email: state.email,
      password: state.password,
      keepSignedIn: state.keepSignedIn,
    );

    await result.match((failure) async {
      if (failure is UnconfirmedEmailFailure) {
        // Best-effort resend in case the original OTP expired.
        // If this fails, the Resend link on the OTP screen still works.
        await _resendOtpUseCase(email: failure.email);
        emit(state.copyWith(status: LoginStatus.emailNotConfirmed));
        return;
      }
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: failure.message,
        ),
      );
    }, (_) async => emit(state.copyWith(status: LoginStatus.success)));
  }
}
