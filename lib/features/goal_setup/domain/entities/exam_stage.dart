import 'package:equatable/equatable.dart';
import 'package:lengoal/features/goal_setup/domain/entities/topic.dart';

// Topics come embedded on the stage from the API, so picking one in
// the UI is just a client-side reveal, not a second fetch.
class ExamStage extends Equatable {
  const new({required this.id, required this.name, required this.topics});

  final String id;
  final String name;
  final List<Topic> topics;

  @override
  List<Object?> get props => [id, name, topics];
}
