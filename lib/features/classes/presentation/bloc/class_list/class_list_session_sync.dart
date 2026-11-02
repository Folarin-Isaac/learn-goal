import 'dart:async';

import 'package:lengoal/core/network/network_info.dart';
import 'package:lengoal/features/auth/domain/repositories/auth_repository.dart';
import 'package:lengoal/features/classes/domain/entities/class_goal_scope.dart';
import 'package:lengoal/features/classes/presentation/bloc/class_list/class_list_bloc.dart';

// The class-list blocs are app-wide caches, so they must follow the
// session: warm the dashboard lists once signed in, wipe every list on
// sign-out so the next account never sees the previous one's classes,
// and retry lists that failed while the device was offline once the
// connection returns.
class ClassListSessionSync {
  new({
    required this._authRepository,
    required this._networkInfo,
    required this._goalScopes,
    required this._blocFor,
  });

  final AuthRepository _authRepository;
  final NetworkInfo _networkInfo;
  // Emits each time the active goal settles (null = no goal); goal-scoped
  // lists wait for the first one before loading.
  final Stream<ClassGoalScope?> _goalScopes;
  final ClassListBloc Function(ClassListSource source) _blocFor;

  StreamSubscription<AuthStatus>? _authSubscription;
  StreamSubscription<bool>? _networkSubscription;
  StreamSubscription<ClassGoalScope?>? _scopeSubscription;

  void start() {
    _authSubscription ??= _authRepository.authStatusStream.listen(_onStatus);
    _networkSubscription ??= _networkInfo.onConnectionChanged.listen(
      _onConnectionChanged,
    );
    _scopeSubscription ??= _goalScopes.listen(_onScope);
    _onStatus(_authRepository.currentAuthStatus);
  }

  Future<void> dispose() async {
    await _authSubscription?.cancel();
    await _networkSubscription?.cancel();
    await _scopeSubscription?.cancel();
    _authSubscription = null;
    _networkSubscription = null;
    _scopeSubscription = null;
  }

  void _onScope(ClassGoalScope? scope) {
    for (final source in ClassListSource.values) {
      if (source.isGoalScoped) {
        _blocFor(source).add(ClassListScopeChanged(scope));
      }
    }
  }

  void _onStatus(AuthStatus status) {
    switch (status) {
      case AuthStatus.authenticated:
        _blocFor(ClassListSource.subscribed).add(const ClassListRequested());
        _blocFor(ClassListSource.saved).add(const ClassListRequested());
      case AuthStatus.unauthenticated:
        for (final source in ClassListSource.values) {
          _blocFor(source).add(const ClassListCleared());
        }
      case AuthStatus.unknown:
        break;
    }
  }

  // A plain request is a no-op for lists that are loaded and fresh, so
  // only lists that failed (or went stale) actually refetch.
  void _onConnectionChanged(bool connected) {
    if (!connected) return;
    if (_authRepository.currentAuthStatus != AuthStatus.authenticated) return;
    for (final source in ClassListSource.values) {
      final bloc = _blocFor(source);
      if (bloc.state.status == ClassListStatus.initial) continue;
      bloc.add(const ClassListRequested());
    }
  }
}
