import 'package:equatable/equatable.dart';

// Snapshot of a live session from ClassRoom/recording-status, shown in the
// lobby before the learner joins.
class LiveClassStatus extends Equatable {
  const new({required this.isRecording, required this.participantCount});

  final bool isRecording;
  final int participantCount;

  @override
  List<Object?> get props => [isRecording, participantCount];
}
