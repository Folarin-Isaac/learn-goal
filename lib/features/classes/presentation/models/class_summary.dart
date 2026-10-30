import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lengoal/features/classes/domain/entities/lengoal_class.dart';

class ClassSummary {
  const new({
    required this.id,
    required this.title,
    required this.instructor,
    required this.dateRange,
    required this.progress,
    required this.thumbnailColor,
    this.imageUrl,
    this.priceLabel,
    this.isFavorite = false,
    this.isSubscribed = false,
  });

  factory fromClass(LengoalClass lengoalClass, {bool isFavorite = false}) {
    return ClassSummary(
      id: lengoalClass.id,
      title: lengoalClass.cohortName,
      instructor: lengoalClass.educatorName,
      dateRange: formatClassDateRange(
        lengoalClass.startDate,
        lengoalClass.endDate,
      ),
      progress: classProgress(lengoalClass),
      thumbnailColor: classThumbnailColor(lengoalClass.bgColorKey),
      imageUrl: lengoalClass.coverImageUrl,
      priceLabel: lengoalClass.isFree
          ? null
          : formatNaira(lengoalClass.effectivePrice),
      isFavorite: isFavorite,
      isSubscribed: lengoalClass.isSubscribed,
    );
  }

  final String id;
  final String title;
  final String instructor;
  final String dateRange;
  final double progress;
  final Color thumbnailColor;
  final String? imageUrl;

  final String? priceLabel;
  final bool isFavorite;
  final bool isSubscribed;
}

String formatNaira(double amount) {
  return NumberFormat.currency(
    symbol: '₦',
    decimalDigits: amount == amount.roundToDouble() ? 0 : 2,
  ).format(amount);
}

String formatClassDateRange(DateTime? start, DateTime? end) {
  if (start == null) return '';
  final full = DateFormat('MMM d, y');
  if (end == null || DateUtils.isSameDay(start, end)) {
    return full.format(start);
  }
  final startFormat = start.year == end.year ? DateFormat('MMM d') : full;
  return '${startFormat.format(start)} - ${full.format(end)}';
}

double classProgress(LengoalClass lengoalClass, {DateTime? now}) {
  final sessions = lengoalClass.sessions;
  if (sessions.isEmpty) return 0;
  final current = now ?? DateTime.now();
  final done = sessions.where((s) => !s.endDate.isAfter(current)).length;
  return done / sessions.length;
}

const _classColors = <String, Color>{
  'green': Color(0xFF0E8C43),
  'blue': Color(0xFF004DE6),
  'red': Color(0xFFD92D20),
  'yellow': Color(0xFFF5B400),
  'orange': Color(0xFFF79009),
  'purple': Color(0xFF7A5AF8),
  'pink': Color(0xFFEE46BC),
  'teal': Color(0xFF15B79E),
  'brown': Color(0xFF4A3B2A),
};

Color classThumbnailColor(String? key) {
  return _classColors[key?.toLowerCase()] ?? const Color(0xFFD9D9D9);
}
