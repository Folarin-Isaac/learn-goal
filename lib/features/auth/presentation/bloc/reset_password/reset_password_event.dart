part of 'reset_password_bloc.dart';

sealed class ResetPasswordEvent extends Equatable {
  const new();

  @override
  List<Object?> get props => [];
}

class ResetPasswordChanged extends ResetPasswordEvent {
  const new(this.password);
  final String password;

  @override
  List<Object?> get props => [password];
}

class ResetPasswordConfirmChanged extends ResetPasswordEvent {
  const new(this.confirmPassword);
  final String confirmPassword;

  @override
  List<Object?> get props => [confirmPassword];
}

class ResetPasswordSubmitted extends ResetPasswordEvent {
  const new();
}
