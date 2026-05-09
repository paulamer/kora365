import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  /// Returns today's date as 'yyyy-MM-dd' for API calls
  static String todayForApi() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  /// Returns a human-friendly match time, e.g. "19:45"
  static String matchTime(DateTime utc) {
    final local = utc.toLocal();
    return DateFormat('HH:mm').format(local);
  }

  /// Returns a short date label like "Today", "Tomorrow", or "Mon 12 May"
  static String friendlyDate(DateTime utc) {
    final local = utc.toLocal();
    final now = DateTime.now();
    if (_isSameDay(local, now)) return 'Today';
    if (_isSameDay(local, now.add(const Duration(days: 1)))) return 'Tomorrow';
    return DateFormat('EEE d MMM').format(local);
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Formats match elapsed minutes to "45'" or "90+3'"
  static String elapsedMinutes(int? elapsed, int? extra) {
    if (elapsed == null) return '';
    if (extra != null && extra > 0) return "$elapsed+$extra'";
    return "$elapsed'";
  }

  static String formatDate(DateTime dt) =>
      DateFormat('d MMM yyyy').format(dt.toLocal());
}
