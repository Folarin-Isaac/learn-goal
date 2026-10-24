import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lengoal/features/profile/domain/entities/learner_profile.dart';
import 'package:lengoal/features/profile/domain/usecases/get_learner_profile_usecase.dart';
import 'package:lengoal/features/profile/domain/usecases/update_learner_profile_usecase.dart';
import 'package:lengoal/features/profile/domain/usecases/upload_file_usecase.dart';

part 'update_profile_event.dart';
part 'update_profile_state.dart';

class UpdateProfileBloc extends Bloc<UpdateProfileEvent, UpdateProfileState> {
  new({
    required GetLearnerProfileUseCase getLearnerProfileUseCase,
    required UpdateLearnerProfileUseCase updateLearnerProfileUseCase,
    required UploadFileUseCase uploadFileUseCase,
  }) : _getLearnerProfileUseCase = getLearnerProfileUseCase,
       _updateLearnerProfileUseCase = updateLearnerProfileUseCase,
       _uploadFileUseCase = uploadFileUseCase,
       super(const UpdateProfileState()) {
    on<UpdateProfileStarted>(_onStarted);
    on<UpdateProfileAvatarPicked>(_onAvatarPicked);
    on<UpdateProfileSubmitted>(_onSubmitted);
  }

  final GetLearnerProfileUseCase _getLearnerProfileUseCase;
  final UpdateLearnerProfileUseCase _updateLearnerProfileUseCase;
  final UploadFileUseCase _uploadFileUseCase;

  Future<void> _onStarted(
    UpdateProfileStarted event,
    Emitter<UpdateProfileState> emit,
  ) async {
    // Already warmed by the session prefetch in the common case, so this
    // resolves without a request and without flashing a loading state.
    final cached = _getLearnerProfileUseCase.cached;
    if (cached != null) {
      emit(
        state.copyWith(loadStatus: ProfileLoadStatus.loaded, profile: cached),
      );
      return;
    }

    emit(state.copyWith(loadStatus: ProfileLoadStatus.loading));
    final result = await _getLearnerProfileUseCase();
    result.match(
      (failure) => emit(
        state.copyWith(
          loadStatus: ProfileLoadStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (profile) => emit(
        state.copyWith(loadStatus: ProfileLoadStatus.loaded, profile: profile),
      ),
    );
  }

  // The picked file is uploaded straight away so that Save only ever has
  // to send a URL. The local path is kept so the avatar can update on
  // screen while the upload is still in flight.
  Future<void> _onAvatarPicked(
    UpdateProfileAvatarPicked event,
    Emitter<UpdateProfileState> emit,
  ) async {
    emit(
      state.copyWith(
        pendingAvatarPath: event.filePath,
        saveStatus: ProfileSaveStatus.uploading,
      ),
    );
    final result = await _uploadFileUseCase(filePath: event.filePath);
    result.match(
      (failure) => emit(
        state.copyWith(
          saveStatus: ProfileSaveStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (url) => emit(
        state.copyWith(
          saveStatus: ProfileSaveStatus.initial,
          uploadedAvatarUrl: url,
        ),
      ),
    );
  }

  Future<void> _onSubmitted(
    UpdateProfileSubmitted event,
    Emitter<UpdateProfileState> emit,
  ) async {
    emit(state.copyWith(saveStatus: ProfileSaveStatus.saving));
    final result = await _updateLearnerProfileUseCase(
      firstName: event.firstName,
      lastName: event.lastName,
      phoneNumber: event.phoneNumber,
      avatarUrl: state.effectiveAvatarUrl,
    );
    result.match(
      (failure) => emit(
        state.copyWith(
          saveStatus: ProfileSaveStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(state.copyWith(saveStatus: ProfileSaveStatus.success)),
    );
  }
}
