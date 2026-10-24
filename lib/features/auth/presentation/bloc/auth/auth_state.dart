part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const new();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const new();
}

class AuthAuthenticated extends AuthState {
  const new();
}

class AuthUnauthenticated extends AuthState {
  const new();
}
