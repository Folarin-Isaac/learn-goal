import 'package:equatable/equatable.dart';
import 'package:lengoal/features/classes/domain/entities/class_review.dart';

class ClassSession extends Equatable {
  const new({
    required this.id,
    required this.topic,
    required this.startDate,
    required this.endDate,
    this.didClassHold = false,
    this.isClassRecorded = false,
    this.reviews = const [],
  });

  final String id;
  final String topic;
  final DateTime startDate;
  final DateTime endDate;
  final bool didClassHold;
  final bool isClassRecorded;
  final List<ClassReview> reviews;

  @override
  List<Object?> get props => [
    id,
    topic,
    startDate,
    endDate,
    didClassHold,
    isClassRecorded,
    reviews,
  ];
}
