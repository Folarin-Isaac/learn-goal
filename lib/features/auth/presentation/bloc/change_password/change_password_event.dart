part of 'change_password_bloc.dart';

sealed class ChangePasswordEvent extends Equatable {
  const new();

  @override
  List<Object?> get props => [];
}

class ChangePasswordSubmitted extends ChangePasswordEvent {
  const new({required this.oldPassword, required this.newPassword});

  final String oldPassword;
  final String newPassword;

  @override
  List<Object?> get props => [oldPassword, newPassword];
}
