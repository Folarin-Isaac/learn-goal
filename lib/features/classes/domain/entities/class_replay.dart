import 'package:equatable/equatable.dart';

// A recorded session. The web player streams [streamUrl] (adaptive HLS),
// so the app does too; [fileUrl] is the raw MP4 kept as a fallback.
class ClassReplay extends Equatable {
  const new({
    this.streamUrl,
    this.fileUrl,
    this.posterUrl,
    this.topic,
    this.startDate,
  });

  final String? streamUrl;
  final String? fileUrl;
  final String? posterUrl;
  final String? topic;
  final DateTime? startDate;

  List<String> get sources => [?streamUrl, ?fileUrl];

  @override
  List<Object?> get props => [streamUrl, fileUrl, posterUrl, topic, startDate];
}
