part of 'class_list_bloc.dart';

enum ClassListStatus { initial, loading, loaded, failure }

class ClassListState extends Equatable {
  const new({
    this.status = ClassListStatus.initial,
    this.classes = const [],
    this.errorMessage,
  });

  final ClassListStatus status;
  final List<LengoalClass> classes;
  final String? errorMessage;

  bool get isLoading =>
      status == ClassListStatus.initial || status == ClassListStatus.loading;

  ClassListState copyWith({
    ClassListStatus? status,
    List<LengoalClass>? classes,
    String? errorMessage,
  }) {
    return ClassListState(
      status: status ?? this.status,
      classes: classes ?? this.classes,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, classes, errorMessage];
}
