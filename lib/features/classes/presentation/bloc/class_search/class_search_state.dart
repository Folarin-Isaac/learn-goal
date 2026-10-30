part of 'class_search_bloc.dart';

enum ClassSearchStatus { idle, loading, loaded, failure }

class ClassSearchState extends Equatable {
  const new({
    this.query = '',
    this.status = ClassSearchStatus.idle,
    this.results = const [],
    this.errorMessage,
  });

  final String query;
  final ClassSearchStatus status;
  final List<LengoalClass> results;
  final String? errorMessage;

  @override
  List<Object?> get props => [query, status, results, errorMessage];
}
