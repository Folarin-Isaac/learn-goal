import 'package:intl/intl.dart';
import 'package:lengoal/core/core.dart';

class ChatTime {
  const new();

  static String relative(BuildContext context, DateTime utc, DateTime now) {
    final l10n = context.l10n;
    final local = utc.toLocal();
    final diff = now.difference(local);
    if (diff.inMinutes < 1) return l10n.chatsJustNow;
    if (diff.inMinutes < 60) return l10n.chatsMinutesAgo(diff.inMinutes);
    if (isSameDay(local, now)) return l10n.chatsHoursAgo(diff.inHours);
    if (isSameDay(local, now.subtract(const Duration(days: 1)))) {
      return l10n.chatsYesterday;
    }
    final locale = Localizations.localeOf(context).toLanguageTag();
    final pattern = local.year == now.year ? 'MMM d' : 'MMM d, y';
    return DateFormat(pattern, locale).format(local);
  }

  static String day(BuildContext context, DateTime local, DateTime now) {
    final l10n = context.l10n;
    if (isSameDay(local, now)) return l10n.chatsToday;
    if (isSameDay(local, now.subtract(const Duration(days: 1)))) {
      return l10n.chatsYesterday;
    }
    final locale = Localizations.localeOf(context).toLanguageTag();
    final pattern = local.year == now.year ? 'EEEE, MMM d' : 'MMM d, y';
    return DateFormat(pattern, locale).format(local);
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
