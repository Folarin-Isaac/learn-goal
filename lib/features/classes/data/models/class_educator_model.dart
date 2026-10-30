import 'package:lengoal/features/classes/domain/entities/class_educator.dart';

class ClassEducatorModel extends ClassEducator {
  const new({
    required super.id,
    required super.firstName,
    required super.lastName,
    super.avatar,
    super.profileSummary,
    super.yearsOfExperience,
    super.averageRating,
    super.reviewCount,
  });

  factory fromJson(Map<String, dynamic> json) {
    final user = json['appUser'] as Map<String, dynamic>? ?? const {};
    final reviews = json['reviews'] as List<dynamic>? ?? const [];
    return ClassEducatorModel(
      id: json['appUserId'] as String? ?? user['id'] as String? ?? '',
      firstName: user['firstName'] as String? ?? '',
      lastName: user['lastName'] as String? ?? '',
      avatar: user['avatar'] as String?,
      profileSummary: json['profileSummary'] as String?,
      yearsOfExperience: json['yearsOfExperience'] as int? ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      reviewCount: reviews.length,
    );
  }
}
