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
    required this._allGoalScopes,
    required this._blocFor,
  });

  final AuthRepository _authRepository;
  final NetworkInfo _networkInfo;
  // Emits each time the active goal settles (null = no goal); goal-scoped
  // lists wait for the first one before loading.
  final Stream<ClassGoalScope?> _goalScopes;
  // Every goal the learner has; the ones not on screen get preloaded so
  // switching to them in the dashboard is instant.
  final Stream<List<ClassGoalScope>> _allGoalScopes;
  final ClassListBloc Function(ClassListSource source) _blocFor;

  StreamSubscription<AuthStatus>? _authSubscription;
  StreamSubscription<bool>? _networkSubscription;
  StreamSubscription<ClassGoalScope?>? _scopeSubscription;
  StreamSubscription<List<ClassGoalScope>>? _allScopesSubscription;

  void start() {
    _authSubscription ??= _authRepository.authStatusStream.listen(_onStatus);
    _networkSubscription ??= _networkInfo.onConnectionChanged.listen(
      _onConnectionChanged,
    );
    _scopeSubscription ??= _goalScopes.listen(_onScope);
    _allScopesSubscription ??= _allGoalScopes.listen(_onAllScopes);
    _onStatus(_authRepository.currentAuthStatus);
  }

  Future<void> dispose() async {
    await _authSubscription?.cancel();
    await _networkSubscription?.cancel();
    await _scopeSubscription?.cancel();
    await _allScopesSubscription?.cancel();
    _authSubscription = null;
    _networkSubscription = null;
    _scopeSubscription = null;
    _allScopesSubscription = null;
  }

  void _onAllScopes(List<ClassGoalScope> scopes) {
    if (scopes.length < 2) return;
    for (final source in ClassListSource.values) {
      if (!source.isGoalScoped) continue;
      final bloc = _blocFor(source);
      unawaited(
        _whenSettled(bloc).then((_) {
          if (!bloc.isClosed) bloc.add(ClassListPrefetchRequested(scopes));
        }),
      );
    }
  }

  // Preloading waits for the on-screen goal to finish first, so it never
  // slows down what the learner is actually looking at.
  Future<void> _whenSettled(ClassListBloc bloc) async {
    bool settled(ClassListState s) =>
        s.scopeResolved &&
        (s.status == ClassListStatus.loaded ||
            s.status == ClassListStatus.failure);
    if (settled(bloc.state)) return;
    await bloc.stream
        .firstWhere(settled)
        .timeout(const Duration(seconds: 30), onTimeout: () => bloc.state);
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
