import 'package:lengoal/features/profile/domain/entities/learner_profile.dart';

class LearnerProfileModel extends LearnerProfile {
  const new({
    required super.learnerId,
    required super.firstName,
    required super.lastName,
    required super.email,
    super.phoneNumber,
    super.avatar,
  });

  factory fromJson(Map<String, dynamic> json) {
    return LearnerProfileModel(
      learnerId: json['learnerId'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String?,
      avatar: json['avatar'] as String?,
    );
  }
}
