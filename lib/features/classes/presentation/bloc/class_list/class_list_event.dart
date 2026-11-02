part of 'class_list_bloc.dart';

sealed class ClassListEvent extends Equatable {
  const new();

  @override
  List<Object?> get props => [];
}

final class ClassListRequested extends ClassListEvent {
  const new({this.force = false});

  final bool force;

  @override
  List<Object?> get props => [force];
}

// Next page for infinite-scroll lists; ignored by lists that load whole.
final class ClassListMoreRequested extends ClassListEvent {
  const new();
}

// A null scope means "resolved, no goal": goal-scoped lists then load
// unfiltered.
final class ClassListScopeChanged extends ClassListEvent {
  const new(this.scope);

  final ClassGoalScope? scope;

  @override
  List<Object?> get props => [scope];
}

// Completes with the Failure when the server rejects the change, or with
// null on success, so the caller can show the right message.
final class ClassSaveToggled extends ClassListEvent {
  const new(this.lengoalClass, {required this.save, this.completer});

  final LengoalClass lengoalClass;
  final bool save;
  final Completer<Failure?>? completer;

  @override
  List<Object?> get props => [lengoalClass, save];
}

final class ClassListPrefetchRequested extends ClassListEvent {
  const new(this.scopes);

  final List<ClassGoalScope> scopes;

  @override
  List<Object?> get props => [scopes];
}

final class ClassListCleared extends ClassListEvent {
  const new();
}
