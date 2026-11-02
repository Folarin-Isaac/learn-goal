part of 'class_list_bloc.dart';

enum ClassListStatus { initial, loading, loaded, failure }

// Lets copyWith tell "leave pagedCategoryId alone" from "set it to null".
const Object _keep = Object();

class ClassListState extends Equatable {
  const new({
    this.status = ClassListStatus.initial,
    this.classes = const [],
    this.loadedAt,
    this.isRefreshing = false,
    this.errorMessage,
    this.scope,
    this.scopeResolved = false,
    this.hasMore = false,
    this.nextPage = 1,
    this.pagedCategoryId,
    this.isLoadingMore = false,
    this.loadMoreFailed = false,
  });

  final ClassListStatus status;
  final List<LengoalClass> classes;
  final DateTime? loadedAt;
  final bool isRefreshing;
  final String? errorMessage;
  final ClassGoalScope? scope;
  final bool scopeResolved;

  // Infinite scroll (paged lists only).
  final bool hasMore;
  final int nextPage;
  // The category the pages are actually being read from; null once the
  // goal's own category turned out empty and the full feed took over.
  final String? pagedCategoryId;
  final bool isLoadingMore;
  final bool loadMoreFailed;

  bool get isLoading =>
      status == ClassListStatus.initial || status == ClassListStatus.loading;

  Set<String> get classIds => {for (final c in classes) c.id};

  ClassListState copyWith({
    ClassListStatus? status,
    List<LengoalClass>? classes,
    DateTime? loadedAt,
    bool? isRefreshing,
    String? errorMessage,
    bool? hasMore,
    int? nextPage,
    Object? pagedCategoryId = _keep,
    bool? isLoadingMore,
    bool? loadMoreFailed,
  }) {
    return ClassListState(
      status: status ?? this.status,
      classes: classes ?? this.classes,
      loadedAt: loadedAt ?? this.loadedAt,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage,
      scope: scope,
      scopeResolved: scopeResolved,
      hasMore: hasMore ?? this.hasMore,
      nextPage: nextPage ?? this.nextPage,
      pagedCategoryId: identical(pagedCategoryId, _keep)
          ? this.pagedCategoryId
          : pagedCategoryId as String?,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
    );
  }

  @override
  List<Object?> get props => [
    status,
    classes,
    loadedAt,
    isRefreshing,
    errorMessage,
    scope,
    scopeResolved,
    hasMore,
    nextPage,
    pagedCategoryId,
    isLoadingMore,
    loadMoreFailed,
  ];
}
