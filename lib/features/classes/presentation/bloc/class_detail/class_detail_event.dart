part of 'class_detail_bloc.dart';

sealed class ClassDetailEvent extends Equatable {
  const new();

  @override
  List<Object?> get props => [];
}

final class ClassDetailRefreshRequested extends ClassDetailEvent {
  const new();
}

final class ClassDetailShareRequested extends ClassDetailEvent {
  const new();
}

final class ClassDetailReplayRequested extends ClassDetailEvent {
  const new(this.sessionId);

  final String sessionId;

  @override
  List<Object?> get props => [sessionId];
}

final class ClassDetailReplayClosed extends ClassDetailEvent {
  const new();
}

// Tap on the header pill after a failed replay check.
final class ClassDetailReplayRetried extends ClassDetailEvent {
  const new();
}

// Internal: the 15s re-check while a replay is processing.
final class _ClassDetailReplayPolled extends ClassDetailEvent {
  const new();
}

// Internal: a session just started or ended, so the badge may change.
final class _ClassDetailScheduleTicked extends ClassDetailEvent {
  const new();
}

final class ClassDetailPaymentCompleted extends ClassDetailEvent {
  const new();
}

final class ClassDetailFreeEnrollRequested extends ClassDetailEvent {
  const new();
}
