import 'dart:async';

import 'package:lengoal/features/auth/domain/repositories/auth_repository.dart';
import 'package:lengoal/features/classes/presentation/bloc/class_list/class_list_bloc.dart';

// The class-list blocs are app-wide caches, so they must follow the
// session: warm the dashboard lists once signed in, and wipe every list
// on sign-out so the next account never sees the previous one's classes.
class ClassListSessionSync {
  new({required this._authRepository, required this._blocFor});

  final AuthRepository _authRepository;
  final ClassListBloc Function(ClassListSource source) _blocFor;

  StreamSubscription<AuthStatus>? _subscription;

  void start() {
    _subscription ??= _authRepository.authStatusStream.listen(_onStatus);
    _onStatus(_authRepository.currentAuthStatus);
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  void _onStatus(AuthStatus status) {
    switch (status) {
      case AuthStatus.authenticated:
        _blocFor(ClassListSource.subscribed).add(const ClassListRequested());
        _blocFor(ClassListSource.recommended).add(const ClassListRequested());
      case AuthStatus.unauthenticated:
        for (final source in ClassListSource.values) {
          _blocFor(source).add(const ClassListCleared());
        }
      case AuthStatus.unknown:
        break;
    }
  }
}
