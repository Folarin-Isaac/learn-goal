class LiveClassSession {
  const new({
    required this.sessionId,
    required this.topic,
    required this.className,
    required this.timeLabel,
    this.educatorId,
    this.educatorName,
  });

  final String sessionId;
  final String topic;
  final String className;
  final String timeLabel;
  final String? educatorId;
  final String? educatorName;
}
