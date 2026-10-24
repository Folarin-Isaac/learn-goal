part of 'forgot_password_bloc.dart';

enum ForgotPasswordStatus { initial, submitting, success, failure }

class ForgotPasswordState extends Equatable {
  const new({
    this.email = '',
    this.resetToken = '',
    this.status = ForgotPasswordStatus.initial,
    this.errorMessage,
  });

  final String email;
  final String resetToken;
  final ForgotPasswordStatus status;
  final String? errorMessage;

  ForgotPasswordState copyWith({
    String? email,
    String? resetToken,
    ForgotPasswordStatus? status,
    String? errorMessage,
  }) {
    return ForgotPasswordState(
      email: email ?? this.email,
      resetToken: resetToken ?? this.resetToken,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [email, resetToken, status, errorMessage];
}
