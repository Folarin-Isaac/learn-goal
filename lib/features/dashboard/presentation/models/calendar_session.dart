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

const mockCalendarSessions = [
  CalendarSession(
    title: 'Anatomy of Head',
    day: 21,
    dateLabel: 'Jun 21',
    timeRange: '03:00 - 03:30 am WAT',
    status: CalendarSessionStatus.ongoing,
    meetingUrl: 'https://www.googlemeet.com/43fe',
    host: 'Ayodeji Oloruntoba',
  ),
  CalendarSession(
    title: 'Anatomy of Head',
    day: 21,
    dateLabel: 'Jun 21',
    timeRange: '07:00 - 09:30 am WAT',
    status: CalendarSessionStatus.concluded,
    meetingUrl: 'https://www.googlemeet.com/43fe',
    host: 'Ayodeji Oloruntoba',
  ),
  CalendarSession(
    title: 'Anatomy of Head',
    day: 21,
    dateLabel: 'Jun 21',
    timeRange: '01:00 - 03:30 pm WAT',
    status: CalendarSessionStatus.upcoming,
    meetingUrl: 'https://www.googlemeet.com/43fe',
  ),
  CalendarSession(
    title: 'Anatomy of Head',
    day: 21,
    dateLabel: 'Jun 21',
    timeRange: '03:30 - 04:30 pm WAT',
    status: CalendarSessionStatus.upcoming,
    meetingUrl: 'https://www.googlemeet.com/43fe',
  ),
  CalendarSession(
    title: 'Anatomy of Head',
    day: 21,
    dateLabel: 'Jun 21',
    timeRange: '04:30 - 05:30 pm WAT',
    status: CalendarSessionStatus.upcoming,
    meetingUrl: 'https://www.googlemeet.com/43fe',
  ),
];
