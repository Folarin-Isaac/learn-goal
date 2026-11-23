// Reads a date-time from the Lengoal API.
//
// The backend stores UTC but is inconsistent about saying so: some fields
// carry a zone ("2026-10-30T16:16:42.863Z"), many don't
// ("2026-04-22T19:14:37"). Dart reads the zone-less form as device-local
// time, which shows class times an hour early in Nigeria (WAT = UTC+1).
// Every server date-time therefore goes through here: zone-less values are
// treated as UTC, and the result is converted to the device's local time.
//
// A date with no time part ("2026-12-01") is a calendar date, not an
// instant, so it's kept as that local date without any shift.

final RegExp _hasZone = RegExp(r'(Z|[+-]\d{2}:?\d{2})$', caseSensitive: false);

DateTime? parseServerDate(String? raw) {
  final value = raw?.trim();
  if (value == null || value.isEmpty) return null;
  if (!value.contains('T') && !value.contains(' ')) {
    return DateTime.tryParse(value);
  }
  final parsed = DateTime.tryParse(
    _hasZone.hasMatch(value) ? value : '${value}Z',
  );
  return parsed?.toLocal();
}
