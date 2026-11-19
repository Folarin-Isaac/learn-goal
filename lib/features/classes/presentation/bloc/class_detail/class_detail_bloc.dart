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
  }) : super(ClassDetailState(lengoalClass: initial)) {
    on<ClassDetailRefreshRequested>(_onRefreshRequested);
    on<ClassDetailShareRequested>(_onShareRequested);
    on<ClassDetailReplayRequested>(_onReplayRequested);
    on<ClassDetailReplayClosed>(_onReplayClosed);
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
    final (classResult, educator) = await (
      _getClassUseCase(id),
      _loadEducator(state.lengoalClass.educatorId),
    ).wait;
    // The backend's isSubscribed flag isn't reliable; once a list has
    // established the learner is subscribed, a refresh can't undo that.
    final fresh = classResult.getRight().toNullable();
    final educatorId = fresh?.educatorId;
    final resolved =
        educator ??
        (educatorId == state.lengoalClass.educatorId
            ? null
            : await _loadEducator(educatorId));
    emit(
      state.copyWith(
        isRefreshing: false,
        lengoalClass: subscribed ? fresh?.asSubscribed() : fresh,
        educators: resolved == null ? null : [resolved],
      ),
    );
    await _loadFeaturedReplay(emit);
  }

  // Mirrors the web: the header card shows the most recent session that
  // has ended and has a recording. isClassRecorded isn't trusted (the web
  // calls class-replay regardless), so ended sessions are tried newest
  // first, a few at most. Only subscribers can watch replays; a failure
  // just leaves the cover image in place.
  static const int _maxReplayLookups = 3;

  Future<void> _loadFeaturedReplay(Emitter<ClassDetailState> emit) async {
    final lengoalClass = state.lengoalClass;
    if (!lengoalClass.isSubscribed) {
      AppLogger.d('[replay] skipped: not subscribed (${lengoalClass.id})');
      return;
    }
    if (state.featuredReplay != null) return;
    final now = DateTime.now();
    final ended =
        lengoalClass.sessions.where((s) => now.isAfter(s.endDate)).toList()
          ..sort((a, b) => b.endDate.compareTo(a.endDate));
    AppLogger.d(
      '[replay] ${lengoalClass.sessions.length} sessions, '
      '${ended.length} ended: '
      '${ended.map((s) => '${s.topic}(recorded=${s.isClassRecorded})')}',
    );
    for (final session in ended.take(_maxReplayLookups)) {
      final result = await _getClassReplayUseCase(session.id);
      final replay = result.getRight().toNullable();
      final outcome = replay == null
          ? 'none (${result.getLeft().toNullable()?.message})'
          : '${replay.sources}';
      AppLogger.d('[replay] ${session.topic}: $outcome');
      if (replay == null) continue;
      if (state.featuredReplay == null) emit(state.withFeaturedReplay(replay));
      return;
    }
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
        state
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
