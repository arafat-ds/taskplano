/// AppDateUtils provides formatting helpers for dates used across the app.
/// Keeping date logic here avoids duplicating format strings in widgets.
class AppDateUtils {
  AppDateUtils._();

  /// Returns a human-readable date string, e.g. "21 May 2026".
  static String formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Returns a short date+time string, e.g. "21 May 2026, 14:30".
  static String formatDateTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${formatDate(date)}, $hour:$minute';
  }

  /// Returns true if [date] is before today (midnight).
  static bool isOverdue(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return date.isBefore(today);
  }

  /// Returns a relative label: "Today", "Tomorrow", or a formatted date.
  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    return formatDate(date);
  }
}
