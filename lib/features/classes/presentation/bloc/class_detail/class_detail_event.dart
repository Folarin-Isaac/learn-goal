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
