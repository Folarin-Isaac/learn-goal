import 'package:equatable/equatable.dart';

class GoalSubject extends Equatable {
  const new({required this.id, required this.name});

  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}

// A level of a goal that has levels (e.g. CIPM "FOUNDATION"), with the
// subjects taught at that level.
class GoalLevel extends Equatable {
  const new({required this.id, required this.name, this.subjects = const []});

  final String id;
  final String name;
  final List<GoalSubject> subjects;

  @override
  List<Object?> get props => [id, name, subjects];
}

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
    this.levels = const [],
    this.subjects = const [],
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

  // From the catalogue these are every level/subject the goal offers; on a
  // learner's own goals they are the ones that learner picked.
  final List<GoalLevel> levels;
  final List<GoalSubject> subjects;

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
    levels,
    subjects,
  ];
}
