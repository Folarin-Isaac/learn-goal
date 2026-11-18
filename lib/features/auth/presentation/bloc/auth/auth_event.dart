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

// The completer resolves with the failure when sign-out is refused (no
// connection), or null once the learner is signed out.
class AuthLoggedOut extends AuthEvent {
  const new({this.completer});

  final Completer<Failure?>? completer;
}
