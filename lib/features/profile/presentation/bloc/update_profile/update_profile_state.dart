part of 'update_profile_bloc.dart';

enum ProfileLoadStatus { initial, loading, loaded, failure }

enum ProfileSaveStatus { initial, uploading, saving, success, failure }

class UpdateProfileState extends Equatable {
  const new({
    this.loadStatus = ProfileLoadStatus.initial,
    this.profile,
    this.saveStatus = ProfileSaveStatus.initial,
    this.pendingAvatarPath,
    this.uploadedAvatarUrl,
    this.errorMessage,
  });

  final ProfileLoadStatus loadStatus;
  final LearnerProfile? profile;
  final ProfileSaveStatus saveStatus;

  // Local file path of a freshly picked image, shown immediately so the
  // avatar updates before the upload round-trip finishes.
  final String? pendingAvatarPath;
  final String? uploadedAvatarUrl;
  final String? errorMessage;

  bool get isBusy =>
      saveStatus == ProfileSaveStatus.uploading ||
      saveStatus == ProfileSaveStatus.saving;

  String? get effectiveAvatarUrl => uploadedAvatarUrl ?? profile?.avatar;

  UpdateProfileState copyWith({
    ProfileLoadStatus? loadStatus,
    LearnerProfile? profile,
    ProfileSaveStatus? saveStatus,
    String? pendingAvatarPath,
    String? uploadedAvatarUrl,
    String? errorMessage,
  }) {
    return UpdateProfileState(
      loadStatus: loadStatus ?? this.loadStatus,
      profile: profile ?? this.profile,
      saveStatus: saveStatus ?? this.saveStatus,
      pendingAvatarPath: pendingAvatarPath ?? this.pendingAvatarPath,
      uploadedAvatarUrl: uploadedAvatarUrl ?? this.uploadedAvatarUrl,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    loadStatus,
    profile,
    saveStatus,
    pendingAvatarPath,
    uploadedAvatarUrl,
    errorMessage,
  ];
}
