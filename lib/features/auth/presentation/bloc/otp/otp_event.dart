part of 'otp_bloc.dart';

sealed class OtpEvent extends Equatable {
  const new();

  @override
  List<Object?> get props => [];
}

class OtpDigitEntered extends OtpEvent {
  const new(this.digit);
  final String digit;

  @override
  List<Object?> get props => [digit];
}

class OtpDigitRemoved extends OtpEvent {
  const new();
}

class OtpResendRequested extends OtpEvent {
  const new();
}

// Internal — fired every second by the bloc's cooldown timer, not the UI.
class _OtpCooldownTicked extends OtpEvent {
  const new();
}
