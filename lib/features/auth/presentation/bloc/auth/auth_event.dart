part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const new();

  @override
  List<Object?> get props => [];
}

// Fired once from app.dart on startup to resolve initial auth state.
class AuthCheckRequested extends AuthEvent {
  const new();
}

class AuthLoggedOut extends AuthEvent {
  const new();
}
