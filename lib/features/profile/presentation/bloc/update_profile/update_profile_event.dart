part of 'update_profile_bloc.dart';

sealed class UpdateProfileEvent extends Equatable {
  const new();

  @override
  List<Object?> get props => [];
}

// Fired when the page mounts — loads the profile the form prefills from.
class UpdateProfileStarted extends UpdateProfileEvent {
  const new();
}

class UpdateProfileAvatarPicked extends UpdateProfileEvent {
  const new(this.filePath);
  final String filePath;

  @override
  List<Object?> get props => [filePath];
}

class UpdateProfileSubmitted extends UpdateProfileEvent {
  const new({
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
  });

  final String firstName;
  final String lastName;
  final String phoneNumber;

  @override
  List<Object?> get props => [firstName, lastName, phoneNumber];
}
