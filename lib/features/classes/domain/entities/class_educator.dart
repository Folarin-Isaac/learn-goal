import 'package:equatable/equatable.dart';

class ClassEducator extends Equatable {
  const new({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.avatar,
    this.profileSummary,
    this.yearsOfExperience = 0,
    this.averageRating = 0,
    this.reviewCount = 0,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String? avatar;
  final String? profileSummary;
  final int yearsOfExperience;
  final double averageRating;
  final int reviewCount;

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    avatar,
    profileSummary,
    yearsOfExperience,
    averageRating,
    reviewCount,
  ];
}
