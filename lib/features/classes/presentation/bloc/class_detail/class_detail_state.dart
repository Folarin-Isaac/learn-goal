part of 'class_detail_bloc.dart';

class ClassDetailState extends Equatable {
  const new({
    required this.lengoalClass,
    this.isRefreshing = false,
    this.errorMessage,
  });

  final LengoalClass lengoalClass;
  final bool isRefreshing;
  final String? errorMessage;

  ClassDetailState copyWith({
    LengoalClass? lengoalClass,
    bool? isRefreshing,
    String? errorMessage,
  }) {
    return ClassDetailState(
      lengoalClass: lengoalClass ?? this.lengoalClass,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [lengoalClass, isRefreshing, errorMessage];
}
