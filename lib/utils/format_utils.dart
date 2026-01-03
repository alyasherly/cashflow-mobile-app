import 'package:intl/intl.dart';

/// Utility class for formatting numbers, dates, and currencies
class FormatUtils {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );



  static final _dateFormat = DateFormat('dd MMM yyyy');
  static final _dateTimeFormat = DateFormat('dd MMM yyyy, HH:mm');
  static final _monthYearFormat = DateFormat('MMMM yyyy');
  static final _dayMonthFormat = DateFormat('dd MMM');

  /// Format amount as currency (Rp 1.000.000)
  static String currency(double amount) {
    return _currencyFormat.format(amount);
  }

  /// Format amount as compact (1.5 jt)
  static String compact(double amount) {
    if (amount.abs() >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)} M';
    } else if (amount.abs() >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)} jt';
    } else if (amount.abs() >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)} rb';
    }
    return amount.toStringAsFixed(0);
  }

  /// Format date as "01 Jan 2024"
  static String date(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Format date as "01 Jan 2024, 14:30"
  static String dateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }

  /// Format as "January 2024"
  static String monthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  /// Format as "01 Jan"
  static String dayMonth(DateTime date) {
    return _dayMonthFormat.format(date);
  }

  /// Get relative date string (Today, Yesterday, This Week, etc.)
  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final difference = today.difference(dateOnly).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '$difference days ago';
    if (difference < 30) return '${(difference / 7).floor()} weeks ago';
    return _dateFormat.format(date);
  }

  /// Group date label for lists
  static String groupLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final difference = today.difference(dateOnly).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return 'This Week';
    if (difference < 30) return 'This Month';
    return _monthYearFormat.format(date);
  }
}
