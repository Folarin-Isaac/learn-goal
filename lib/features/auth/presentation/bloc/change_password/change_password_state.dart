part of 'change_password_bloc.dart';

enum ChangePasswordStatus { initial, submitting, success, failure }

class ChangePasswordState extends Equatable {
  const new({this.status = ChangePasswordStatus.initial, this.errorMessage});

  final ChangePasswordStatus status;
  final String? errorMessage;

  bool get isSubmitting => status == ChangePasswordStatus.submitting;

  @override
  List<Object?> get props => [status, errorMessage];
}
