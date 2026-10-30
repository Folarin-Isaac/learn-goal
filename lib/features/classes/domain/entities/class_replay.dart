import 'package:equatable/equatable.dart';

class ClassReplay extends Equatable {
  const new({required this.recordFileUrl, this.topic, this.streamId});

  final String recordFileUrl;
  final String? topic;
  final String? streamId;

  @override
  List<Object?> get props => [recordFileUrl, topic, streamId];
}
