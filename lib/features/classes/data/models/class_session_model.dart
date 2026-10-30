import 'package:lengoal/features/classes/domain/entities/class_review.dart';
import 'package:lengoal/features/classes/domain/entities/class_session.dart';

class ClassSessionModel extends ClassSession {
  const new({
    required super.id,
    required super.topic,
    required super.startDate,
    required super.endDate,
    super.didClassHold,
    super.isClassRecorded,
    super.reviews,
  });

  factory fromJson(Map<String, dynamic> json) {
    final reviews = json['reviews'] as List<dynamic>? ?? const [];
    return ClassSessionModel(
      id: json['id'] as String,
      topic: json['topic'] as String? ?? '',
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      didClassHold: json['didClassHold'] as bool? ?? false,
      isClassRecorded: json['isClassRecorded'] as bool? ?? false,
      reviews: reviews
          .cast<Map<String, dynamic>>()
          .map(
            (review) => ClassReview(
              reviewerName: review['reviewerName'] as String? ?? '',
              rating: (review['rating'] as num?)?.toDouble() ?? 0,
              comment: review['comment'] as String?,
              createdAt: DateTime.tryParse(
                review['createdAt'] as String? ?? '',
              ),
            ),
          )
          .toList(),
    );
  }
}
