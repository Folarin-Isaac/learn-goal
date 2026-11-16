import 'package:equatable/equatable.dart';

class TopEducator extends Equatable {
  const new({
    required this.id,
    required this.name,
    this.photoUrl,
    this.backgroundImageUrl,
    this.bgColorKey,
    this.categories = const [],
    this.rating = 0,
    this.reviewCount = 0,
    this.totalStudents = 0,
    this.activeClassCount = 0,
  });

  final String id;
  final String name;
  final String? photoUrl;
  final String? backgroundImageUrl;
  final String? bgColorKey;
  final List<String> categories;
  final double rating;
  final int reviewCount;
  final int totalStudents;
  final int activeClassCount;

  @override
  List<Object?> get props => [
    id,
    name,
    photoUrl,
    backgroundImageUrl,
    bgColorKey,
    categories,
    rating,
    reviewCount,
    totalStudents,
    activeClassCount,
  ];
}
