import 'package:equatable/equatable.dart';

class ExamGoal extends Equatable {
  const new({
    required this.id,
    required this.categoryId,
    required this.goalName,
    this.examBody,
    this.description,
    this.examTargetDate,
    this.goalsHaveLevel = false,
    this.goalsHaveSubject = false,
    this.numberOfLevels = 0,
  });

  final String id;
  final String categoryId;
  final String goalName;
  final String? examBody;
  final String? description;
  final DateTime? examTargetDate;
  final bool goalsHaveLevel;
  final bool goalsHaveSubject;
  final int numberOfLevels;

  @override
  List<Object?> get props => [
    id,
    categoryId,
    goalName,
    examBody,
    description,
    examTargetDate,
    goalsHaveLevel,
    goalsHaveSubject,
    numberOfLevels,
  ];
}
