import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lengoal/features/classes/domain/entities/class_educator.dart';
import 'package:lengoal/features/classes/domain/entities/lengoal_class.dart';
import 'package:lengoal/features/classes/domain/usecases/generate_class_referral_usecase.dart';
import 'package:lengoal/features/classes/domain/usecases/get_class_educators_usecase.dart';
import 'package:lengoal/features/classes/domain/usecases/get_class_replay_usecase.dart';
import 'package:lengoal/features/classes/domain/usecases/get_class_usecase.dart';

part 'class_detail_event.dart';
part 'class_detail_state.dart';

// Seeded with the list row the user tapped (list endpoints already return
// the full class shape) so the page renders instantly; GetClass then
// refreshes it in place.
class ClassDetailBloc extends Bloc<ClassDetailEvent, ClassDetailState> {
  new({
    required LengoalClass initial,
    required GetClassUseCase getClassUseCase,
    required GetClassEducatorsUseCase getClassEducatorsUseCase,
    required GetClassReplayUseCase getClassReplayUseCase,
    required GenerateClassReferralUseCase generateClassReferralUseCase,
  }) : _getClassUseCase = getClassUseCase,
       _getClassEducatorsUseCase = getClassEducatorsUseCase,
       _getClassReplayUseCase = getClassReplayUseCase,
       _generateClassReferralUseCase = generateClassReferralUseCase,
       super(ClassDetailState(lengoalClass: initial)) {
    on<ClassDetailRefreshRequested>(_onRefreshRequested);
    on<ClassDetailShareRequested>(_onShareRequested);
    on<ClassDetailReplayRequested>(_onReplayRequested);
  }

  final GetClassUseCase _getClassUseCase;
  final GetClassEducatorsUseCase _getClassEducatorsUseCase;
  final GetClassReplayUseCase _getClassReplayUseCase;
  final GenerateClassReferralUseCase _generateClassReferralUseCase;

  Future<void> _onRefreshRequested(
    ClassDetailRefreshRequested event,
    Emitter<ClassDetailState> emit,
  ) async {
    emit(state.copyWith(isRefreshing: true));
    final id = state.lengoalClass.id;
    final (classResult, educatorsResult) = await (
      _getClassUseCase(id),
      _getClassEducatorsUseCase(id),
    ).wait;
    // The backend's isSubscribed flag isn't reliable; once a list has
    // established the learner is subscribed, a refresh can't undo that.
    final fresh = classResult.getRight().toNullable();
    emit(
      state.copyWith(
        isRefreshing: false,
        lengoalClass: state.lengoalClass.isSubscribed
            ? fresh?.asSubscribed()
            : fresh,
        educators: educatorsResult.getRight().toNullable(),
      ),
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
      (replay) =>
          emit(state.withEffect(ClassDetailEffect.open(replay.recordFileUrl))),
    );
  }
}
