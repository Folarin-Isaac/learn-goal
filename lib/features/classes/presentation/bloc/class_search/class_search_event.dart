part of 'class_search_bloc.dart';

sealed class ClassSearchEvent extends Equatable {
  const new();

  @override
  List<Object?> get props => [];
}

final class ClassSearchQueryChanged extends ClassSearchEvent {
  const new(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}
