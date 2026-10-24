import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lengoal/core/utils/extensions/string_extensions.dart';
import 'package:lengoal/features/auth/domain/usecases/register_usecase.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc({required RegisterUseCase registerUseCase})
    : _registerUseCase = registerUseCase,
      super(const RegisterState()) {
    // Resets status to initial on every field change, so a stale
    // status can't re-trigger the listener (see LoginBloc for why).
    on<RegisterFirstNameChanged>(
      (event, emit) => emit(
        state.copyWith(
          firstName: event.firstName,
          status: RegisterStatus.initial,
        ),
      ),
    );
    on<RegisterLastNameChanged>(
      (event, emit) => emit(
        state.copyWith(
          lastName: event.lastName,
          status: RegisterStatus.initial,
        ),
      ),
    );
    on<RegisterEmailChanged>(
      (event, emit) => emit(
        state.copyWith(email: event.email, status: RegisterStatus.initial),
      ),
    );
    on<RegisterPhoneNumberChanged>(
      (event, emit) => emit(
        state.copyWith(
          phoneNumber: event.phoneNumber,
          status: RegisterStatus.initial,
        ),
      ),
    );
    on<RegisterPasswordChanged>(
      (event, emit) => emit(
        state.copyWith(
          password: event.password,
          status: RegisterStatus.initial,
        ),
      ),
    );
    on<RegisterConfirmPasswordChanged>(
      (event, emit) => emit(
        state.copyWith(
          confirmPassword: event.confirmPassword,
          status: RegisterStatus.initial,
        ),
      ),
    );
    on<RegisterSubmitted>(_onSubmitted);
  }

  final RegisterUseCase _registerUseCase;

  Future<void> _onSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    if (!state.isValid) return;
    emit(state.copyWith(status: RegisterStatus.submitting));

    final result = await _registerUseCase(
      firstName: state.firstName,
      lastName: state.lastName,
      email: state.email,
      password: state.password,
      phoneNumber: state.phoneNumber,
    );

    result.match(
      (failure) => emit(
        state.copyWith(
          status: RegisterStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(state.copyWith(status: RegisterStatus.success)),
    );
  }
}
