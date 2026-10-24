part of 'login_bloc.dart';

sealed class LoginEvent extends Equatable {
  const new();

  @override
  List<Object?> get props => [];
}

class LoginEmailChanged extends LoginEvent {
  const new(this.email);
  final String email;

  @override
  List<Object?> get props => [email];
}

class LoginPasswordChanged extends LoginEvent {
  const new(this.password);
  final String password;

  @override
  List<Object?> get props => [password];
}

class LoginKeepSignedInToggled extends LoginEvent {
  const new(this.value);
  final bool value;

  @override
  List<Object?> get props => [value];
}

class LoginSubmitted extends LoginEvent {
  const new();
}
