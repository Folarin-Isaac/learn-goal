part of 'class_detail_bloc.dart';

enum ClassDetailEffectKind {
  share,
  open,
  error,
  showReplay,
  replayNotReady,
  enrolled,
}

// The pill on the header cover. Set from what is actually known: the
// session times, the class-replay answer and didClassHold.
enum ReplayBadge {
  // Nothing to say: no session has ended yet, or a replay is showing.
  none,
  // A session is running now (by its schedule), as on the web.
  live,
  // class-replay is being asked for the first time.
  loading,
  // The session ended and held, but the server has no video yet. The bloc
  // re-checks every 15s, like the web.
  processing,
  // The latest session ended without being held (didClassHold: false).
  notHeld,
  // The check itself failed (offline, 5xx). Tapping the pill retries.
  failed,
}

class ClassDetailEffect extends Equatable {
  const new share(this.value) : kind = ClassDetailEffectKind.share;

  const new open(this.value) : kind = ClassDetailEffectKind.open;

  const new error(this.value) : kind = ClassDetailEffectKind.error;

  const new showReplay() : kind = ClassDetailEffectKind.showReplay, value = '';

  const new replayNotReady()
    : kind = ClassDetailEffectKind.replayNotReady,
      value = '';

  const new enrolled() : kind = ClassDetailEffectKind.enrolled, value = '';

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
    this.isEnrolling = false,
    this.subscriptionKnown = true,
    this.loadingReplayId,
    this.featuredReplay,
    this.activeReplay,
    this.autoPlayReplay = false,
    this.replayBadge = ReplayBadge.none,
    this.effect,
    this.effectCount = 0,
  });

  final LengoalClass lengoalClass;
  final List<ClassEducator> educators;
  final bool isRefreshing;
  final bool isSharing;
  final bool isEnrolling;

  // False while it isn't yet clear whether the learner owns the class (the
  // row they tapped came from a list that doesn't say, and their library
  // hasn't loaded). The header holds back Buy/Save until GetClass answers,
  // so an owner never sees a flash of purchase buttons.
  final bool subscriptionKnown;
  final String? loadingReplayId;

  // The latest recorded session, shown on the header card (poster + play
  // button) when the page opens, as on the web.
  final ClassReplay? featuredReplay;

  // What the header card shows in place of the cover. autoPlayReplay is
  // true when the learner picked it from the Schedule tab.
  final ClassReplay? activeReplay;
  final bool autoPlayReplay;
  final ReplayBadge replayBadge;

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
    bool? isEnrolling,
    bool? subscriptionKnown,
    String? loadingReplayId,
    ReplayBadge? replayBadge,
  }) {
    return ClassDetailState(
      lengoalClass: lengoalClass ?? this.lengoalClass,
      educators: educators ?? this.educators,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isSharing: isSharing ?? this.isSharing,
      isEnrolling: isEnrolling ?? this.isEnrolling,
      subscriptionKnown: subscriptionKnown ?? this.subscriptionKnown,
      loadingReplayId: loadingReplayId ?? this.loadingReplayId,
      featuredReplay: featuredReplay,
      activeReplay: activeReplay,
      autoPlayReplay: autoPlayReplay,
      replayBadge: replayBadge ?? this.replayBadge,
      effect: effect,
      effectCount: effectCount,
    );
  }

  // A found replay replaces whatever the badge was saying.
  ClassDetailState withFeaturedReplay(ClassReplay replay) {
    final showIt = activeReplay == null;
    return ClassDetailState(
      lengoalClass: lengoalClass,
      educators: educators,
      isRefreshing: isRefreshing,
      isSharing: isSharing,
      isEnrolling: isEnrolling,
      subscriptionKnown: subscriptionKnown,
      loadingReplayId: loadingReplayId,
      featuredReplay: replay,
      activeReplay: showIt ? replay : activeReplay,
      autoPlayReplay: !showIt && autoPlayReplay,
      effect: effect,
      effectCount: effectCount,
    );
  }

  ClassDetailState withActiveReplay(
    ClassReplay? replay, {
    required bool autoPlay,
  }) {
    return ClassDetailState(
      lengoalClass: lengoalClass,
      educators: educators,
      isRefreshing: isRefreshing,
      isSharing: isSharing,
      isEnrolling: isEnrolling,
      subscriptionKnown: subscriptionKnown,
      loadingReplayId: loadingReplayId,
      featuredReplay: featuredReplay,
      activeReplay: replay,
      autoPlayReplay: autoPlay,
      replayBadge: replayBadge,
      effect: effect,
      effectCount: effectCount,
    );
  }

  ClassDetailState withEffect(
    ClassDetailEffect effect, {
    bool? sharing,
    bool? enrolling,
  }) {
    return ClassDetailState(
      lengoalClass: lengoalClass,
      educators: educators,
      isRefreshing: isRefreshing,
      isSharing: sharing ?? isSharing,
      isEnrolling: enrolling ?? isEnrolling,
      subscriptionKnown: subscriptionKnown,
      featuredReplay: featuredReplay,
      activeReplay: activeReplay,
      autoPlayReplay: autoPlayReplay,
      replayBadge: replayBadge,
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
    isEnrolling,
    subscriptionKnown,
    loadingReplayId,
    featuredReplay,
    activeReplay,
    autoPlayReplay,
    replayBadge,
    effect,
    effectCount,
  ];
}
