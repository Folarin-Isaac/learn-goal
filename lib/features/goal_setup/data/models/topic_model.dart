import 'package:lengoal/features/goal_setup/domain/entities/topic.dart';

class TopicModel extends Topic {
  const new({required super.id, required super.name});

  factory fromJson(Map<String, dynamic> json) {
    return TopicModel(id: json['id'] as String, name: json['name'] as String);
  }
}
