import 'package:equatable/equatable.dart';

class ClassAttendance extends Equatable {
  const new({required this.totalSessions, required this.attendedSessions});

  final int totalSessions;
  final int attendedSessions;

  // Derived from the counts rather than the API's attendancePercentage,
  // whose scale (0-1 vs 0-100) hasn't been confirmed.
  double get fraction => totalSessions == 0
      ? 0
      : (attendedSessions / totalSessions).clamp(0, 1).toDouble();

  int get percent => (fraction * 100).round();

  @override
  List<Object?> get props => [totalSessions, attendedSessions];
}
