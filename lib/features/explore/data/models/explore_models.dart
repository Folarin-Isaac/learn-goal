import 'package:lengoal/features/classes/data/models/lengoal_class_model.dart';
import 'package:lengoal/features/explore/domain/entities/explore_category.dart';
import 'package:lengoal/features/explore/domain/entities/explore_class.dart';
import 'package:lengoal/features/explore/domain/entities/top_educator.dart';

// LandingCategoryDto.
ExploreCategory exploreCategoryFromJson(Map<String, dynamic> json) {
  return ExploreCategory(
    id: json['categoryId'] as String? ?? '',
    name: json['categoryName'] as String? ?? '',
    iconUrl: json['categoryIcon'] as String?,
    activeClassCount: (json['activeClassCount'] as num?)?.toInt() ?? 0,
  );
}

// LandingClassDto. completionPercentage's scale isn't documented, so
// anything above 1 is read as out of 100.
ExploreClass exploreClassFromJson(Map<String, dynamic> json) {
  final raw = (json['completionPercentage'] as num?)?.toDouble();
  return ExploreClass(
    lengoalClass: LengoalClassModel.fromLandingJson(json),
    completion: raw == null ? null : (raw > 1 ? raw / 100 : raw).clamp(0, 1),
    enrollmentLimit: (json['enrollmentLimit'] as num?)?.toInt() ?? 0,
    availableSlots: (json['availableSlots'] as num?)?.toInt() ?? 0,
  );
}

// TopEducatorDto. The feed fills averageRating and starRating
// inconsistently, so whichever is set wins.
TopEducator topEducatorFromJson(Map<String, dynamic> json) {
  final average = (json['averageRating'] as num?)?.toDouble() ?? 0;
  final star = (json['starRating'] as num?)?.toDouble() ?? 0;
  return TopEducator(
    id: json['educatorId'] as String? ?? '',
    name: json['educatorName'] as String? ?? '',
    photoUrl: _nonEmpty(json['educatorProfilePicture']),
    backgroundImageUrl: _nonEmpty(json['educatorBackgroundImage']),
    bgColorKey: json['bgColorKey'] as String?,
    categories: (json['categories'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .where((c) => c.trim().isNotEmpty)
        .toList(),
    rating: average > 0 ? average : star,
    reviewCount: (json['reviews'] as List<dynamic>? ?? const []).length,
    totalStudents: (json['totalStudents'] as num?)?.toInt() ?? 0,
    activeClassCount: (json['activeClassCount'] as num?)?.toInt() ?? 0,
  );
}

String? _nonEmpty(Object? value) =>
    value is String && value.trim().isNotEmpty ? value : null;
