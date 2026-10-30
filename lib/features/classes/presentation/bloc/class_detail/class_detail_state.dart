part of 'class_detail_bloc.dart';

enum ClassDetailEffectKind { share, open, error }

class ClassDetailEffect extends Equatable {
  const ClassDetailEffect.share(this.value)
    : kind = ClassDetailEffectKind.share;

  const ClassDetailEffect.open(this.value) : kind = ClassDetailEffectKind.open;

  const ClassDetailEffect.error(this.value)
    : kind = ClassDetailEffectKind.error;

  final ClassDetailEffectKind kind;
  final String value;

  @override
  List<Object?> get props => [kind, value];
}

class ClassDetailState extends Equatable {
  const new({
    required this.lengoalClass,
    this.educators = const [],
    this.isRefreshing = false,
    this.isSharing = false,
    this.loadingReplayId,
    this.effect,
    this.effectCount = 0,
  });

  final LengoalClass lengoalClass;
  final List<ClassEducator> educators;
  final bool isRefreshing;
  final bool isSharing;
  final String? loadingReplayId;

  // One-off action for the page to perform (share sheet, open URL,
  // snackbar). effectCount bumps on every emission so the same effect
  // twice in a row still triggers the listener.
  final ClassDetailEffect? effect;
  final int effectCount;

  ClassDetailState copyWith({
    LengoalClass? lengoalClass,
    List<ClassEducator>? educators,
    bool? isRefreshing,
    bool? isSharing,
    String? loadingReplayId,
  }) {
    return ClassDetailState(
      lengoalClass: lengoalClass ?? this.lengoalClass,
      educators: educators ?? this.educators,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isSharing: isSharing ?? this.isSharing,
      loadingReplayId: loadingReplayId ?? this.loadingReplayId,
      effect: effect,
      effectCount: effectCount,
    );
  }

  ClassDetailState withEffect(ClassDetailEffect effect, {bool? sharing}) {
    return ClassDetailState(
      lengoalClass: lengoalClass,
      educators: educators,
      isRefreshing: isRefreshing,
      isSharing: sharing ?? isSharing,
      effect: effect,
      effectCount: effectCount + 1,
    );
  }

  @override
  List<Object?> get props => [
    lengoalClass,
    educators,
    isRefreshing,
    isSharing,
    loadingReplayId,
    effect,
    effectCount,
  ];
}
