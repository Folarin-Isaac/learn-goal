part of 'class_detail_bloc.dart';

sealed class ClassDetailEvent extends Equatable {
  const new();

  @override
  List<Object?> get props => [];
}

final class ClassDetailRefreshRequested extends ClassDetailEvent {
  const new();
}
