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

/// Formats a numeric value as a USD currency string (e.g. `$120.00`).
String money(double value) => '\$${value.toStringAsFixed(2)}';

/// Formats a [DateTime] as `D/M/YYYY`.
String formatShortDate(DateTime date) =>
    '${date.day}/${date.month}/${date.year}';

/// Formats a [DateTime] as `Mon D, YYYY` (e.g. `Nov 8, 2026`).
String formatFullDate(DateTime date) =>
    '${_monthNames[date.month - 1]} ${date.day}, ${date.year}';

/// Formats the time portion of a [DateTime] in 12-hour format (e.g. `2:05 PM`).
String formatTime(DateTime date) {
  final hour24 = date.hour;
  final period = hour24 >= 12 ? 'PM' : 'AM';
  final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour12:$minute $period';
}
