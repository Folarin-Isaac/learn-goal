String formatReplayTime(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);
  final ss = seconds.toString().padLeft(2, '0');
  if (hours > 0) {
    final mm = minutes.toString().padLeft(2, '0');
    return '$hours:$mm:$ss';
  }
  return '$minutes:$ss';
}

String formatReplaySpeed(double speed) {
  final whole = speed == speed.roundToDouble();
  return '${whole ? speed.toStringAsFixed(0) : speed.toString()}x';
}
