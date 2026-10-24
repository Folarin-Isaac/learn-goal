part of 'otp_bloc.dart';

enum OtpStatus { initial, submitting, success, failure }

enum OtpResendStatus { idle, sending, sent, failure }

class OtpState extends Equatable {
  const new({
    required this.email,
    this.code = '',
    this.length = 6,
    this.status = OtpStatus.initial,
    this.resendStatus = OtpResendStatus.idle,
    this.resendCooldown = 0,
    this.errorMessage,
  });

  final String email;
  final String code;
  final int length;
  final OtpStatus status;
  final OtpResendStatus resendStatus;

  // Seconds left before resend is allowed; 0 means it's tappable.
  final int resendCooldown;
  final String? errorMessage;

  bool get isComplete => code.length == length;

  bool get canResend =>
      resendStatus != OtpResendStatus.sending && resendCooldown == 0;

  OtpState copyWith({
    String? code,
    OtpStatus? status,
    OtpResendStatus? resendStatus,
    int? resendCooldown,
    String? errorMessage,
  }) {
    return OtpState(
      email: email,
      code: code ?? this.code,
      length: length,
      status: status ?? this.status,
      resendStatus: resendStatus ?? this.resendStatus,
      resendCooldown: resendCooldown ?? this.resendCooldown,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    email,
    code,
    length,
    status,
    resendStatus,
    resendCooldown,
    errorMessage,
  ];
}
