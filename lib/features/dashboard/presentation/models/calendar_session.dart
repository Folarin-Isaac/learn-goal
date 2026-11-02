enum CalendarSessionStatus { ongoing, concluded, upcoming }

class CalendarSession {
  const new({
    required this.title,
    required this.day,
    required this.dateLabel,
    required this.timeRange,
    required this.status,
    required this.meetingUrl,
    this.host,
    this.id,
    this.hasReplay = false,
  });

  final String title;
  final int day;
  final String dateLabel;
  final String timeRange;
  final CalendarSessionStatus status;
  final String meetingUrl;
  final String? host;
  final String? id;
  final bool hasReplay;
}
