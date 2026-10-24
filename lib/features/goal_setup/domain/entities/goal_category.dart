import 'package:equatable/equatable.dart';

class GoalCategory extends Equatable {
  const new({
    required this.id,
    required this.name,
    this.description,
    this.noOfGoals = 0,
  });

  final String id;
  final String name;
  final String? description;
  final int noOfGoals;

  @override
  List<Object?> get props => [id, name, description, noOfGoals];
}
