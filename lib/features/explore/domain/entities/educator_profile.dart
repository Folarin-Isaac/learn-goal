import 'package:equatable/equatable.dart';
import 'package:lengoal/features/explore/domain/entities/explore_class.dart';

class EducatorProfile extends Equatable {
  const new({
    required this.id,
    required this.name,
    this.photoUrl,
    this.bgColorKey,
    this.tierName,
    this.rating = 0,
    this.reviewCount = 0,
    this.yearsOfExperience = 0,
    this.experiencePeriod,
    this.highlights,
    this.summary,
    this.categories = const [],
    this.badges = const [],
    this.activeCohorts = const [],
    this.hoursTaught = 0,
    this.learnersTaught = 0,
    this.cohortsDelivered = 0,
  });

  final String id;
  final String name;
  final String? photoUrl;
  final String? bgColorKey;
  final String? tierName;
  final double rating;
  final int reviewCount;
  final int yearsOfExperience;
  final String? experiencePeriod;
  final String? highlights;
  final String? summary;
  final List<String> categories;
  final List<String> badges;
  final List<ExploreClass> activeCohorts;
  final double hoursTaught;
  final int learnersTaught;
  final int cohortsDelivered;

  @override
  List<Object?> get props => [
    id,
    name,
    photoUrl,
    bgColorKey,
    tierName,
    rating,
    reviewCount,
    yearsOfExperience,
    experiencePeriod,
    highlights,
    summary,
    categories,
    badges,
    activeCohorts,
    hoursTaught,
    learnersTaught,
    cohortsDelivered,
  ];
}
