import 'package:equatable/equatable.dart';

class LearnerProfile extends Equatable {
  const new({
    required this.learnerId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.avatar,
  });

  final String learnerId;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String? avatar;

  String get fullName => '$firstName $lastName'.trim();

  bool get hasAvatar => avatar != null && avatar!.isNotEmpty;

  @override
  List<Object?> get props => [
    learnerId,
    firstName,
    lastName,
    email,
    phoneNumber,
    avatar,
  ];
}
