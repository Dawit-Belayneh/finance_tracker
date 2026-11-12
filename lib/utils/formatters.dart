const List<String> _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

const List<String> _fullMonthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// Global active currency symbol used by [money].
String activeCurrencySymbol = '\$';

/// Whether [money] formats values with two decimal places.
bool activeShowDecimals = true;

/// Formats a numeric value using the active currency symbol (e.g. `$120.00`).
String money(double value) =>
    '$activeCurrencySymbol${value.toStringAsFixed(activeShowDecimals ? 2 : 0)}';

/// Formats a [DateTime] as `D/M/YYYY`.
String formatShortDate(DateTime date) =>
    '${date.day}/${date.month}/${date.year}';

/// Formats a [DateTime] as `Mon D, YYYY` (e.g. `Nov 8, 2026`).
String formatFullDate(DateTime date) =>
    '${_monthNames[date.month - 1]} ${date.day}, ${date.year}';

/// Formats a [DateTime] as `Month YYYY` (e.g. `November 2026`).
String formatMonthYear(DateTime date) =>
    '${_fullMonthNames[date.month - 1]} ${date.year}';

/// Formats a 7-day week starting at [weekStart] as `Mon D – Mon D, YYYY`.
String formatWeekRange(DateTime weekStart) {
  final end = weekStart.add(const Duration(days: 6));
  final startLabel = '${_monthNames[weekStart.month - 1]} ${weekStart.day}';
  final endLabel = '${_monthNames[end.month - 1]} ${end.day}';
  if (weekStart.year != end.year) {
    return '$startLabel, ${weekStart.year} – $endLabel, ${end.year}';
  }
  return '$startLabel – $endLabel, ${end.year}';
}

/// Formats the time portion of a [DateTime] in 12-hour format (e.g. `2:05 PM`).
String formatTime(DateTime date) {
  final hour24 = date.hour;
  final period = hour24 >= 12 ? 'PM' : 'AM';
  final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour12:$minute $period';
}
