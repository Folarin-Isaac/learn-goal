import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lengoal/features/auth/domain/usecases/resend_otp_usecase.dart';
import 'package:lengoal/features/auth/domain/usecases/verify_otp_usecase.dart';

part 'otp_event.dart';
part 'otp_state.dart';

// Verification auto-triggers once OtpState.isComplete is true — there's
// no separate submit button on this screen.
class OtpBloc extends Bloc<OtpEvent, OtpState> {
  new({
    required String email,
    required this._verifyOtpUseCase,
    required this._resendOtpUseCase,
  }) : super(OtpState(email: email)) {
    on<OtpDigitEntered>(_onDigitEntered);
    on<OtpDigitRemoved>(_onDigitRemoved);
    on<OtpResendRequested>(_onResendRequested);
    on<_OtpCooldownTicked>(_onCooldownTicked);
  }

  static const int _resendCooldownSeconds = 30;

  final VerifyOtpUseCase _verifyOtpUseCase;
  final ResendOtpUseCase _resendOtpUseCase;
  Timer? _cooldownTimer;

  Future<void> _onDigitEntered(
    OtpDigitEntered event,
    Emitter<OtpState> emit,
  ) async {
    if (state.code.length >= state.length ||
        state.status == OtpStatus.submitting) {
      return;
    }
    final updated = state.code + event.digit;
    emit(state.copyWith(code: updated, status: OtpStatus.initial));

    if (updated.length == state.length) {
      await _verify(emit);
    }
  }

  void _onDigitRemoved(OtpDigitRemoved event, Emitter<OtpState> emit) {
    if (state.code.isEmpty) return;
    emit(state.copyWith(code: state.code.substring(0, state.code.length - 1)));
  }

  Future<void> _verify(Emitter<OtpState> emit) async {
    emit(state.copyWith(status: OtpStatus.submitting));
    final result = await _verifyOtpUseCase(email: state.email, otp: state.code);

    result.match(
      (failure) => emit(
        state.copyWith(
          status: OtpStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(state.copyWith(status: OtpStatus.success)),
    );
  }

  Future<void> _onResendRequested(
    OtpResendRequested event,
    Emitter<OtpState> emit,
  ) async {
    if (!state.canResend) return;
    emit(state.copyWith(resendStatus: OtpResendStatus.sending));

    final result = await _resendOtpUseCase(email: state.email);

    // One-shot signals for the snackbar — reset to idle right after so
    // a later emission can't re-fire the same snackbar.
    result.match(
      (failure) {
        emit(
          state.copyWith(
            resendStatus: OtpResendStatus.failure,
            errorMessage: failure.message,
          ),
        );
        emit(state.copyWith(resendStatus: OtpResendStatus.idle));
      },
      (_) {
        emit(
          state.copyWith(
            code: '',
            resendStatus: OtpResendStatus.sent,
            resendCooldown: _resendCooldownSeconds,
          ),
        );
        emit(state.copyWith(resendStatus: OtpResendStatus.idle));
        _startCooldownTimer();
      },
    );
  }

  void _startCooldownTimer() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(const _OtpCooldownTicked());
    });
  }

  void _onCooldownTicked(_OtpCooldownTicked event, Emitter<OtpState> emit) {
    if (state.resendCooldown <= 1) {
      _cooldownTimer?.cancel();
      _cooldownTimer = null;
      emit(state.copyWith(resendCooldown: 0));
      return;
    }
    emit(state.copyWith(resendCooldown: state.resendCooldown - 1));
  }

  @override
  Future<void> close() {
    _cooldownTimer?.cancel();
    debugPrint('OtpBloc closed');
    return super.close();
  }
}
