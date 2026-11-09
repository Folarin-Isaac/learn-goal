import 'package:equatable/equatable.dart';

class ClassAttendance extends Equatable {
  const new({required this.totalSessions, required this.attendedSessions});

  final int totalSessions;
  final int attendedSessions;

  // Share of the course attended, from the counts rather than the API's
  // attendancePercentage (its 0-1 vs 0-100 scale is unconfirmed).
  //
  // It's unconfirmed whether totalSessions counts every scheduled session
  // or only those held so far. Dividing by the larger of it and the class's
  // own scheduled count means the bar can't read 100% halfway through a
  // course either way.
  double fractionOf(int scheduledSessions) {
    final total = totalSessions > scheduledSessions
        ? totalSessions
        : scheduledSessions;
    if (total <= 0) return 0;
    return (attendedSessions / total).clamp(0, 1).toDouble();
  }

  @override
  List<Object?> get props => [totalSessions, attendedSessions];
}
