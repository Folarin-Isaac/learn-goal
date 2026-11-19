import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lengoal/features/classes/domain/entities/live_class_access.dart';
import 'package:lengoal/features/classes/domain/entities/live_class_status.dart';
import 'package:lengoal/features/classes/domain/usecases/get_live_class_status_usecase.dart';
import 'package:lengoal/features/classes/domain/usecases/join_live_class_usecase.dart';

// lobby → joining → inRoom, then ended (the educator closed the room) or
// dropped (connection lost for good, offered a rejoin). Leaving on
// purpose just pops the page, so it has no phase.
enum LiveClassPhase { lobby, joining, inRoom, ended, dropped }

class LiveClassState extends Equatable {
  const new({
    this.phase = LiveClassPhase.lobby,
    this.status,
    this.micOn = false,
    this.cameraOn = false,
    this.access,
    this.error,
    this.errorCount = 0,
  });

  final LiveClassPhase phase;

  // Lobby info from recording-status; null until (or unless) it loads.
  final LiveClassStatus? status;

  // What the learner chose in the lobby. Applied after connecting, and
  // only if the room lets learners publish.
  final bool micOn;
  final bool cameraOn;

  // Set while inRoom. Each join fetches a fresh token.
  final LiveClassAccess? access;

  // One-off error for a snackbar; errorCount bumps so a repeat still fires.
  final String? error;
  final int errorCount;

  LiveClassState copyWith({
    LiveClassPhase? phase,
    LiveClassStatus? status,
    bool? micOn,
    bool? cameraOn,
    LiveClassAccess? access,
  }) {
    return LiveClassState(
      phase: phase ?? this.phase,
      status: status ?? this.status,
      micOn: micOn ?? this.micOn,
      cameraOn: cameraOn ?? this.cameraOn,
      access: access ?? this.access,
      error: error,
      errorCount: errorCount,
    );
  }

  LiveClassState withError(String message, {required LiveClassPhase phase}) {
    return LiveClassState(
      phase: phase,
      status: status,
      micOn: micOn,
      cameraOn: cameraOn,
      error: message,
      errorCount: errorCount + 1,
    );
  }

  @override
  List<Object?> get props => [
    phase,
    status,
    micOn,
    cameraOn,
    access,
    error,
    errorCount,
  ];
}

class LiveClassCubit extends Cubit<LiveClassState> {
  new({
    required this.sessionId,
    required this._joinLiveClass,
    required this._getLiveClassStatus,
  }) : super(const LiveClassState());

  final String sessionId;
  final JoinLiveClassUseCase _joinLiveClass;
  final GetLiveClassStatusUseCase _getLiveClassStatus;

  // Best effort: the lobby works without it.
  Future<void> loadStatus() async {
    final result = await _getLiveClassStatus(sessionId);
    final status = result.getRight().toNullable();
    if (status == null || isClosed) return;
    emit(state.copyWith(status: status));
  }

  void toggleMic() => emit(state.copyWith(micOn: !state.micOn));

  void toggleCamera() => emit(state.copyWith(cameraOn: !state.cameraOn));

  Future<void> join() async {
    if (state.phase == LiveClassPhase.joining) return;
    final retryPhase = state.phase == LiveClassPhase.dropped
        ? LiveClassPhase.dropped
        : LiveClassPhase.lobby;
    emit(state.copyWith(phase: LiveClassPhase.joining));
    final result = await _joinLiveClass(sessionId);
    if (isClosed) return;
    result.match(
      (failure) => emit(state.withError(failure.message, phase: retryPhase)),
      (access) =>
          emit(state.copyWith(phase: LiveClassPhase.inRoom, access: access)),
    );
  }

  void roomClosed({required bool classEnded}) {
    emit(
      state.copyWith(
        phase: classEnded ? LiveClassPhase.ended : LiveClassPhase.dropped,
      ),
    );
  }

  void roomFailed(String message) {
    emit(state.withError(message, phase: LiveClassPhase.dropped));
  }
}
