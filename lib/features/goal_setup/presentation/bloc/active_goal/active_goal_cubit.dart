import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lengoal/core/constants/storage_keys.dart';
import 'package:lengoal/core/network/network_info.dart';
import 'package:lengoal/core/storage/secure_storage_service.dart';
import 'package:lengoal/features/auth/domain/repositories/auth_repository.dart';
import 'package:lengoal/features/goal_setup/domain/entities/exam_goal.dart';
import 'package:lengoal/features/goal_setup/domain/usecases/get_learner_goals_usecase.dart';
import 'package:lengoal/features/profile/domain/usecases/get_learner_profile_usecase.dart';

part 'active_goal_state.dart';

// App-wide: which of the learner's goals the app is focused on. Driven by
// the session (loads on sign-in, clears on sign-out), persisted so the
// pick survives restarts, and reloaded when connectivity returns after a
// failed load.
class ActiveGoalCubit extends Cubit<ActiveGoalState> {
  new({
    required this._authRepository,
    required this._getLearnerProfileUseCase,
    required this._getLearnerGoalsUseCase,
    required this._secureStorage,
    required this._networkInfo,
  }) : super(const ActiveGoalState());

  final AuthRepository _authRepository;
  final GetLearnerProfileUseCase _getLearnerProfileUseCase;
  final GetLearnerGoalsUseCase _getLearnerGoalsUseCase;
  final SecureStorageService _secureStorage;
  final NetworkInfo _networkInfo;

  StreamSubscription<AuthStatus>? _authSubscription;
  StreamSubscription<bool>? _networkSubscription;

  bool get _signedIn =>
      _authRepository.currentAuthStatus == AuthStatus.authenticated;

  void start() {
    _authSubscription ??= _authRepository.authStatusStream.listen(_onAuth);
    _networkSubscription ??= _networkInfo.onConnectionChanged.listen((online) {
      if (online && _signedIn && state.status == ActiveGoalStatus.failure) {
        unawaited(load());
      }
    });
    _onAuth(_authRepository.currentAuthStatus);
  }

  void _onAuth(AuthStatus status) {
    switch (status) {
      case AuthStatus.authenticated:
        unawaited(load());
      case AuthStatus.unauthenticated:
        emit(const ActiveGoalState());
        unawaited(_secureStorage.delete(StorageKeys.activeGoalId));
      case AuthStatus.unknown:
        break;
    }
  }

  Future<void> load() async {
    if (state.status == ActiveGoalStatus.loading) return;
    emit(state.copyWith(status: ActiveGoalStatus.loading));

    final profile = (await _getLearnerProfileUseCase()).getRight().toNullable();
    if (!_signedIn) return;
    if (profile == null) {
      emit(state.copyWith(status: ActiveGoalStatus.failure));
      return;
    }
    if (profile.learnerId.isEmpty) {
      emit(const ActiveGoalState(status: ActiveGoalStatus.ready));
      return;
    }

    final result = await _getLearnerGoalsUseCase(learnerId: profile.learnerId);
    if (!_signedIn) return;
    final storedId = await _secureStorage.read(StorageKeys.activeGoalId);
    result.match(
      (_) => emit(state.copyWith(status: ActiveGoalStatus.failure)),
      (goals) {
        final keepId = state.activeGoal?.id ?? storedId;
        final active =
            goals.where((g) => g.id == keepId).firstOrNull ?? goals.firstOrNull;
        emit(
          ActiveGoalState(
            status: ActiveGoalStatus.ready,
            goals: goals,
            activeGoal: active,
          ),
        );
      },
    );
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    await _networkSubscription?.cancel();
    await super.close();
  }

  Future<void> select(ExamGoal goal) async {
    if (goal.id == state.activeGoal?.id) return;
    emit(
      ActiveGoalState(
        status: state.status,
        goals: state.goals,
        activeGoal: goal,
      ),
    );
    await _secureStorage.write(StorageKeys.activeGoalId, goal.id);
  }
}
