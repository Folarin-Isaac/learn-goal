import 'package:equatable/equatable.dart';

class ClassReview extends Equatable {
  const new({
    required this.reviewerName,
    required this.rating,
    this.comment,
    this.createdAt,
  });

  final String reviewerName;
  final double rating;
  final String? comment;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [reviewerName, rating, comment, createdAt];
}
