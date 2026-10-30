import 'package:intl/intl.dart';
import 'package:lengoal/features/classes/domain/entities/class_material_file.dart';
import 'package:lengoal/features/classes/domain/entities/class_session.dart';
import 'package:lengoal/features/classes/domain/entities/lengoal_class.dart';
import 'package:lengoal/features/classes/presentation/models/class_material.dart';
import 'package:lengoal/features/classes/presentation/models/class_quiz.dart';
import 'package:lengoal/features/classes/presentation/models/class_summary.dart';
import 'package:lengoal/features/dashboard/presentation/models/calendar_session.dart';

class ClassDetail {
  const new({
    required this.source,
    required this.item,
    required this.rating,
    required this.reviewCount,
    required this.outline,
    required this.instructorTitle,
    required this.sessions,
    required this.quizzes,
    required this.materials,
    required this.hasCertificate,
  });

  factory fromClass(
    LengoalClass lengoalClass, {
    bool isFavorite = false,
    DateTime? now,
  }) {
    final reviews = lengoalClass.reviews;
    final rating = reviews.isEmpty
        ? 0.0
        : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
    final host = lengoalClass.educatorName.isEmpty
        ? null
        : lengoalClass.educatorName;
    final current = now ?? DateTime.now();

    return ClassDetail(
      source: lengoalClass,
      item: ClassSummary.fromClass(lengoalClass, isFavorite: isFavorite),
      rating: rating,
      reviewCount: reviews.length,
      outline: htmlToPlainText(lengoalClass.description ?? ''),
      instructorTitle: lengoalClass.educatorTierName ?? '',
      sessions: [
        for (final session in lengoalClass.sessions)
          _toCalendarSession(session, host, current),
      ],
      quizzes: const [],
      materials: lengoalClass.materials.map(_toMaterial).toList(),
      hasCertificate: false,
    );
  }

  final LengoalClass source;
  final ClassSummary item;
  final double rating;
  final int reviewCount;
  final String outline;
  final String instructorTitle;
  final List<CalendarSession> sessions;
  final List<ClassQuiz> quizzes;
  final List<ClassMaterial> materials;
  final bool hasCertificate;
}

CalendarSession _toCalendarSession(
  ClassSession session,
  String? host,
  DateTime now,
) {
  final time = DateFormat('h:mm a');
  final status = now.isAfter(session.endDate)
      ? CalendarSessionStatus.concluded
      : now.isBefore(session.startDate)
      ? CalendarSessionStatus.upcoming
      : CalendarSessionStatus.ongoing;
  return CalendarSession(
    title: session.topic,
    day: session.startDate.day,
    dateLabel: DateFormat('MMM d').format(session.startDate),
    timeRange:
        '${time.format(session.startDate)} - ${time.format(session.endDate)}',
    status: status,
    meetingUrl: '',
    host: host,
  );
}

ClassMaterial _toMaterial(ClassMaterialFile file) {
  final name = file.name.isEmpty ? file.url : file.name;
  return ClassMaterial(
    name: name,
    fileType: materialFileTypeFor('$name ${file.url}'),
    url: file.url,
  );
}

MaterialFileType materialFileTypeFor(String text) {
  final lower = text.toLowerCase();
  if (RegExp(r'\.pdf\b').hasMatch(lower)) return MaterialFileType.pdf;
  if (RegExp(r'\.docx?\b').hasMatch(lower)) return MaterialFileType.word;
  if (RegExp(r'\.(xlsx?|csv)\b').hasMatch(lower)) {
    return MaterialFileType.excel;
  }
  return MaterialFileType.link;
}

String htmlToPlainText(String html) {
  return html
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp('</(p|div|li|h[1-6])>', caseSensitive: false), '\n')
      .replaceAll(RegExp('<[^>]+>'), '')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&amp;', '&')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();
}
