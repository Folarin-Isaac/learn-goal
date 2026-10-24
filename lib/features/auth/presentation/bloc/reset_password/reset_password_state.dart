part of 'reset_password_bloc.dart';

enum ResetPasswordStatus { initial, submitting, success, failure }

class ResetPasswordState extends Equatable {
  const new({
    required this.email,
    required this.token,
    this.password = '',
    this.confirmPassword = '',
    this.status = ResetPasswordStatus.initial,
    this.errorMessage,
  });

  final String email;
  final String token;
  final String password;
  final String confirmPassword;
  final ResetPasswordStatus status;
  final String? errorMessage;

  bool get isValid => password.length >= 8 && password == confirmPassword;

  ResetPasswordState copyWith({
    String? password,
    String? confirmPassword,
    ResetPasswordStatus? status,
    String? errorMessage,
  }) {
    return ResetPasswordState(
      email: email,
      token: token,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    email,
    token,
    password,
    confirmPassword,
    status,
    errorMessage,
  ];
}
