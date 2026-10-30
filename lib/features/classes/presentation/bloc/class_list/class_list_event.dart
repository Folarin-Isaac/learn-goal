part of 'class_list_bloc.dart';

sealed class ClassListEvent extends Equatable {
  const new();

  @override
  List<Object?> get props => [];
}

final class ClassListRequested extends ClassListEvent {
  const new();
}
