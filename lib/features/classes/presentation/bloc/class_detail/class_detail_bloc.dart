import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lengoal/core/utils/logger.dart';
import 'package:lengoal/features/classes/domain/entities/class_educator.dart';
import 'package:lengoal/features/classes/domain/entities/class_replay.dart';
import 'package:lengoal/features/classes/domain/entities/lengoal_class.dart';
import 'package:lengoal/features/classes/domain/usecases/generate_class_referral_usecase.dart';
import 'package:lengoal/features/classes/domain/usecases/get_class_replay_usecase.dart';
import 'package:lengoal/features/classes/domain/usecases/get_class_usecase.dart';
import 'package:lengoal/features/explore/domain/entities/educator_profile.dart';
import 'package:lengoal/features/explore/domain/usecases/get_explore_feed_usecases.dart';
import 'package:lengoal/features/payments/domain/usecases/class_payment_usecases.dart';

part 'class_detail_event.dart';
part 'class_detail_state.dart';

// Seeded with the list row the user tapped (list endpoints already return
// the full class shape) so the page renders instantly; GetClass then
// refreshes it in place.
class ClassDetailBloc extends Bloc<ClassDetailEvent, ClassDetailState> {
  new({
    required LengoalClass initial,
    required this._getClassUseCase,
    required this._getEducatorProfileUseCase,
    required this._getClassReplayUseCase,
    required this._generateClassReferralUseCase,
    required this._enrollInFreeClassUseCase,
    bool subscriptionKnown = true,
  }) : super(
         ClassDetailState(
           lengoalClass: initial,
           subscriptionKnown: subscriptionKnown || initial.isSubscribed,
         ),
       ) {
    on<ClassDetailRefreshRequested>(_onRefreshRequested);
    on<ClassDetailShareRequested>(_onShareRequested);
    on<ClassDetailReplayRequested>(_onReplayRequested);
    on<ClassDetailReplayClosed>(_onReplayClosed);
    on<ClassDetailReplayRetried>(_onReplayRetried);
    on<_ClassDetailReplayPolled>(_onReplayPolled);
    on<_ClassDetailScheduleTicked>(_onScheduleTicked);
    on<ClassDetailPaymentCompleted>(_onPaymentCompleted);
    on<ClassDetailFreeEnrollRequested>(_onFreeEnrollRequested);
  }

  final GetClassUseCase _getClassUseCase;
  final GetEducatorProfileUseCase _getEducatorProfileUseCase;
  final GetClassReplayUseCase _getClassReplayUseCase;
  final GenerateClassReferralUseCase _generateClassReferralUseCase;
  final EnrollInFreeClassUseCase _enrollInFreeClassUseCase;

  Future<void> _onRefreshRequested(
    ClassDetailRefreshRequested event,
    Emitter<ClassDetailState> emit,
  ) async {
    emit(state.copyWith(isRefreshing: true));
    final id = state.lengoalClass.id;
    final subscribed = state.lengoalClass.isSubscribed;
    final seedEducatorId = state.lengoalClass.educatorId;
    final educatorRequest = _loadEducator(seedEducatorId);
    // The class is emitted as soon as it arrives (not after the educator),
    // because it settles whether the learner owns it, and the header waits
    // on that. The backend's isSubscribed flag isn't reliable; once a list
    // has established the learner is subscribed, a refresh can't undo that.
    final classResult = await _getClassUseCase(id);
    final fresh = classResult.getRight().toNullable();
    emit(
      state.copyWith(
        lengoalClass: subscribed ? fresh?.asSubscribed() : fresh,
        subscriptionKnown: true,
      ),
    );
    final educator = await educatorRequest;
    final educatorId = fresh?.educatorId;
    final resolved =
        educator ??
        (educatorId == seedEducatorId ? null : await _loadEducator(educatorId));
    emit(
      state.copyWith(
        isRefreshing: false,
        educators: resolved == null ? null : [resolved],
      ),
    );
    await _loadFeaturedReplay(emit);
  }

  // Mirrors the web: the header card shows the most recent session that
  // has ended and has a recording. isClassRecorded isn't trusted (the web
  // calls class-replay regardless), so ended sessions are tried newest
  // first, a few at most. Only subscribers can watch replays.
  //
  // When no video is found, replayBadge says why, based on the newest
  // ended session: the check failed, it didn't hold, or it is processing.
  // Unlike the web, a failed check isn't shown as "processing".
  static const int _maxReplayLookups = 3;
  static const Duration _pollInterval = Duration(seconds: 15);

  // Session starts/ends further away than this aren't timed; a refresh or
  // reopening the page picks them up.
  static const Duration _maxScheduleWait = Duration(hours: 12);

  Timer? _pollTimer;
  Timer? _scheduleTimer;
  String? _pollSessionId;
  bool _polling = false;

  // Bumped on every reload so answers from an older run are ignored.
  int _replayRun = 0;

  Future<void> _loadFeaturedReplay(Emitter<ClassDetailState> emit) async {
    final run = ++_replayRun;
    _stopPolling();
    _armScheduleTimer();
    final lengoalClass = state.lengoalClass;
    final now = DateTime.now();
    final live = lengoalClass.sessions.any(
      (s) => !now.isBefore(s.startDate) && now.isBefore(s.endDate),
    );
    if (live && state.featuredReplay == null) {
      emit(state.copyWith(replayBadge: ReplayBadge.live));
      return;
    }
    if (!lengoalClass.isSubscribed) {
      AppLogger.d('[replay] skipped: not subscribed (${lengoalClass.id})');
      emit(state.copyWith(replayBadge: ReplayBadge.none));
      return;
    }
    if (state.featuredReplay != null) {
      emit(state.copyWith(replayBadge: ReplayBadge.none));
      return;
    }
    final ended =
        lengoalClass.sessions.where((s) => now.isAfter(s.endDate)).toList()
          ..sort((a, b) => b.endDate.compareTo(a.endDate));
    AppLogger.d(
      '[replay] ${lengoalClass.sessions.length} sessions, '
      '${ended.length} ended: '
      '${ended.map((s) => '${s.topic}(held=${s.didClassHold})')}',
    );
    if (ended.isEmpty) {
      emit(state.copyWith(replayBadge: ReplayBadge.none));
      return;
    }
    emit(state.copyWith(replayBadge: ReplayBadge.loading));
    var newestFailed = false;
    for (final session in ended.take(_maxReplayLookups)) {
      final result = await _getClassReplayUseCase(session.id);
      if (isClosed || run != _replayRun) return;
      final failure = result.getLeft().toNullable();
      final replay = result.getRight().toNullable();
      final outcome = failure != null
          ? 'failed (${failure.message})'
          : replay == null
          ? 'not ready'
          : '${replay.sources}';
      AppLogger.d('[replay] ${session.topic}: $outcome');
      if (failure != null && session == ended.first) newestFailed = true;
      if (replay == null) continue;
      if (state.featuredReplay == null) {
        emit(
          state
              .withFeaturedReplay(replay)
              .copyWith(replayBadge: ReplayBadge.none),
        );
      }
      return;
    }
    final newest = ended.first;
    if (newestFailed) {
      emit(state.copyWith(replayBadge: ReplayBadge.failed));
      return;
    }
    emit(
      state.copyWith(
        replayBadge: newest.didClassHold
            ? ReplayBadge.processing
            : ReplayBadge.notHeld,
      ),
    );
    // Polled even when didClassHold is false, in case the flag is wrong:
    // a video that turns up still replaces the message.
    _startPolling(newest.id);
  }

  void _startPolling(String sessionId) {
    _pollSessionId = sessionId;
    _pollTimer = Timer.periodic(
      _pollInterval,
      (_) => add(const _ClassDetailReplayPolled()),
    );
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _pollSessionId = null;
  }

  Future<void> _onReplayPolled(
    _ClassDetailReplayPolled event,
    Emitter<ClassDetailState> emit,
  ) async {
    final sessionId = _pollSessionId;
    if (sessionId == null || _polling) return;
    _polling = true;
    final run = _replayRun;
    final result = await _getClassReplayUseCase(sessionId);
    _polling = false;
    if (isClosed || run != _replayRun) return;
    // A failed poll keeps the current message; the next tick tries again.
    final replay = result.getRight().toNullable();
    if (replay == null) return;
    AppLogger.d('[replay] poll found: ${replay.sources}');
    _stopPolling();
    if (state.featuredReplay != null) return;
    emit(
      state.withFeaturedReplay(replay).copyWith(replayBadge: ReplayBadge.none),
    );
  }

  // Wakes the bloc at the next session start or end, so "live" appears
  // and disappears on time without a refresh.
  void _armScheduleTimer() {
    _scheduleTimer?.cancel();
    _scheduleTimer = null;
    final now = DateTime.now();
    DateTime? next;
    for (final session in state.lengoalClass.sessions) {
      for (final edge in [session.startDate, session.endDate]) {
        if (edge.isAfter(now) && (next == null || edge.isBefore(next))) {
          next = edge;
        }
      }
    }
    if (next == null) return;
    final wait = next.difference(now) + const Duration(seconds: 1);
    if (wait > _maxScheduleWait) return;
    _scheduleTimer = Timer(wait, () => add(const _ClassDetailScheduleTicked()));
  }

  Future<void> _onScheduleTicked(
    _ClassDetailScheduleTicked event,
    Emitter<ClassDetailState> emit,
  ) => _loadFeaturedReplay(emit);

  Future<void> _onReplayRetried(
    ClassDetailReplayRetried event,
    Emitter<ClassDetailState> emit,
  ) async {
    if (state.replayBadge != ReplayBadge.failed) return;
    await _loadFeaturedReplay(emit);
  }

  @override
  Future<void> close() {
    _stopPolling();
    _scheduleTimer?.cancel();
    return super.close();
  }

  Future<ClassEducator?> _loadEducator(String? educatorId) async {
    if (educatorId == null || educatorId.isEmpty) return null;
    final result = await _getEducatorProfileUseCase(educatorId);
    return result.getRight().map(_toClassEducator).toNullable();
  }

  static ClassEducator _toClassEducator(EducatorProfile profile) {
    return ClassEducator(
      id: profile.id,
      firstName: profile.name,
      lastName: '',
      avatar: profile.photoUrl,
      profileSummary: profile.summary,
      yearsOfExperience: profile.yearsOfExperience,
      averageRating: profile.rating,
      reviewCount: profile.reviewCount,
    );
  }

  Future<void> _onShareRequested(
    ClassDetailShareRequested event,
    Emitter<ClassDetailState> emit,
  ) async {
    if (state.isSharing) return;
    emit(state.copyWith(isSharing: true));
    final result = await _generateClassReferralUseCase(state.lengoalClass.id);
    result.match(
      (failure) => emit(
        state.withEffect(
          ClassDetailEffect.error(failure.message),
          sharing: false,
        ),
      ),
      (referral) => emit(
        state.withEffect(
          ClassDetailEffect.share(referral.referralLink),
          sharing: false,
        ),
      ),
    );
  }

  Future<void> _onReplayRequested(
    ClassDetailReplayRequested event,
    Emitter<ClassDetailState> emit,
  ) async {
    if (state.loadingReplayId != null) return;
    emit(state.copyWith(loadingReplayId: event.sessionId));
    final result = await _getClassReplayUseCase(event.sessionId);
    result.match(
      (failure) =>
          emit(state.withEffect(ClassDetailEffect.error(failure.message))),
      (replay) => emit(
        replay == null
            ? state.withEffect(const ClassDetailEffect.replayNotReady())
            : state
                  .withActiveReplay(replay, autoPlay: true)
                  .withEffect(const ClassDetailEffect.showReplay()),
      ),
    );
  }

  void _onPaymentCompleted(
    ClassDetailPaymentCompleted event,
    Emitter<ClassDetailState> emit,
  ) {
    emit(state.copyWith(lengoalClass: state.lengoalClass.asSubscribed()));
    add(const ClassDetailRefreshRequested());
  }

  Future<void> _onFreeEnrollRequested(
    ClassDetailFreeEnrollRequested event,
    Emitter<ClassDetailState> emit,
  ) async {
    if (state.isEnrolling || state.lengoalClass.isSubscribed) return;
    emit(state.copyWith(isEnrolling: true));
    final result = await _enrollInFreeClassUseCase(state.lengoalClass.id);
    result.match(
      (failure) => emit(
        state.withEffect(
          ClassDetailEffect.error(failure.message),
          enrolling: false,
        ),
      ),
      (_) {
        emit(
          state
              .copyWith(lengoalClass: state.lengoalClass.asSubscribed())
              .withEffect(const ClassDetailEffect.enrolled(), enrolling: false),
        );
        add(const ClassDetailRefreshRequested());
      },
    );
  }

  void _onReplayClosed(
    ClassDetailReplayClosed event,
    Emitter<ClassDetailState> emit,
  ) {
    emit(state.withActiveReplay(state.featuredReplay, autoPlay: false));
  }
}
