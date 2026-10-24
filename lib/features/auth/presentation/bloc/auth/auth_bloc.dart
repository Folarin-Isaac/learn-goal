import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lengoal/features/auth/domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

// Separate from AuthRepository's raw stream (which the router uses) —
// this bloc is for widgets reacting via BlocBuilder/BlocListener.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  new({required this._authRepository}) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoggedOut>(_onLoggedOut);
  }

  final AuthRepository _authRepository;

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.checkAuthStatus();
    emit(
      _authRepository.currentAuthStatus == AuthStatus.authenticated
          ? const AuthAuthenticated()
          : const AuthUnauthenticated(),
    );
  }

  Future<void> _onLoggedOut(
    AuthLoggedOut event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(const AuthUnauthenticated());
  }
}
