import 'package:intl/intl.dart';

String formatAccessDate(DateTime date, String locale) {
  final local = date.toLocal();
  if (!locale.startsWith('en')) {
    return DateFormat.yMMMMd(locale).format(local);
  }
  return '${local.day}${_ordinal(local.day)} '
      '${DateFormat('MMMM y', locale).format(local)}';
}

String _ordinal(int day) {
  if (day >= 11 && day <= 13) return 'th';
  return switch (day % 10) {
    1 => 'st',
    2 => 'nd',
    3 => 'rd',
    _ => 'th',
  };
}
