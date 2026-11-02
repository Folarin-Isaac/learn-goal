part of 'class_search_bloc.dart';

enum ClassSearchStatus { idle, loading, loaded, failure }

class ClassSearchState extends Equatable {
  const new({
    this.query = '',
    this.status = ClassSearchStatus.idle,
    this.results = const [],
    this.errorMessage,
    this.hasMore = false,
    this.nextPage = 1,
    this.isLoadingMore = false,
    this.loadMoreFailed = false,
  });

  final String query;
  final ClassSearchStatus status;
  final List<LengoalClass> results;
  final String? errorMessage;
  final bool hasMore;
  final int nextPage;
  final bool isLoadingMore;
  final bool loadMoreFailed;

  ClassSearchState copyWith({
    List<LengoalClass>? results,
    bool? hasMore,
    int? nextPage,
    bool? isLoadingMore,
    bool? loadMoreFailed,
  }) {
    return ClassSearchState(
      query: query,
      status: status,
      results: results ?? this.results,
      errorMessage: errorMessage,
      hasMore: hasMore ?? this.hasMore,
      nextPage: nextPage ?? this.nextPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
    );
  }

  @override
  List<Object?> get props => [
    query,
    status,
    results,
    errorMessage,
    hasMore,
    nextPage,
    isLoadingMore,
    loadMoreFailed,
  ];
}
