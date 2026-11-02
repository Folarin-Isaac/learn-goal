part of 'class_list_bloc.dart';

enum ClassListStatus { initial, loading, loaded, failure }

class ClassListState extends Equatable {
  const new({
    this.status = ClassListStatus.initial,
    this.classes = const [],
    this.loadedAt,
    this.isRefreshing = false,
    this.errorMessage,
    this.scope,
    this.scopeResolved = false,
  });

  final ClassListStatus status;
  final List<LengoalClass> classes;
  final DateTime? loadedAt;
  final bool isRefreshing;
  final String? errorMessage;
  final ClassGoalScope? scope;
  final bool scopeResolved;

  bool get isLoading =>
      status == ClassListStatus.initial || status == ClassListStatus.loading;

  Set<String> get classIds => {for (final c in classes) c.id};

  ClassListState copyWith({
    ClassListStatus? status,
    List<LengoalClass>? classes,
    DateTime? loadedAt,
    bool? isRefreshing,
    String? errorMessage,
  }) {
    return ClassListState(
      status: status ?? this.status,
      classes: classes ?? this.classes,
      loadedAt: loadedAt ?? this.loadedAt,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage,
      scope: scope,
      scopeResolved: scopeResolved,
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
  ];
}
