part of 'forgot_password_bloc.dart';

sealed class ForgotPasswordEvent extends Equatable {
  const new();

  @override
  List<Object?> get props => [];
}

class ForgotPasswordEmailChanged extends ForgotPasswordEvent {
  const new(this.email);
  final String email;

  @override
  List<Object?> get props => [email];
}

class ForgotPasswordSubmitted extends ForgotPasswordEvent {
  const new();
}
