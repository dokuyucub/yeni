import 'package:intl/intl.dart';

/// Extension methods for DateTime to simplify date operations and formatting
extension DateExtensions on DateTime {
  /// Returns true if this date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Returns true if this date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Returns true if this date is the same day as [other]
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Returns a DateTime at the start of this day (00:00:00.000)
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  /// Returns a DateTime at the end of this day (23:59:59.999)
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }

  /// Returns the Monday of the week containing this date
  DateTime get startOfWeek {
    final difference = weekday - DateTime.monday;
    return subtract(Duration(days: difference)).startOfDay;
  }

  /// Returns the first day of the month containing this date
  DateTime get startOfMonth {
    return DateTime(year, month, 1);
  }

  /// Returns the number of days in the month containing this date
  int get daysInMonth {
    final nextMonth = month == 12 ? DateTime(year + 1, 1, 1) : DateTime(year, month + 1, 1);
    return nextMonth.subtract(const Duration(days: 1)).day;
  }

  /// Returns the ISO week number of the year (1-53)
  int get weekOfYear {
    final firstDayOfYear = DateTime(year, 1, 1);
    final daysSinceFirstDay = difference(firstDayOfYear).inDays;
    final firstMonday = firstDayOfYear.weekday;

    // Calculate week number
    final weekNumber = ((daysSinceFirstDay + firstMonday - 1) / 7).ceil();

    // Handle edge cases
    if (weekNumber < 1) {
      // This date belongs to the last week of the previous year
      return DateTime(year - 1, 12, 31).weekOfYear;
    }

    if (weekNumber > 52) {
      // Check if this is actually week 1 of next year
      final lastDayOfYear = DateTime(year, 12, 31);
      if (lastDayOfYear.weekday < DateTime.thursday) {
        return 1;
      }
    }

    return weekNumber;
  }

  /// Returns formatted date string like "Jan 15, 2025"
  String get formatted {
    return DateFormat.yMMMd().format(this);
  }

  /// Returns short formatted date string like "Jan 15"
  String get formattedShort {
    return DateFormat.MMMd().format(this);
  }

  /// Returns formatted time string like "8:30 PM"
  String get formattedTime {
    return DateFormat.jm().format(this);
  }

  /// Returns full formatted date string like "Wednesday, January 15, 2025"
  String get formattedFull {
    return DateFormat.yMMMMEEEEd().format(this);
  }

  /// Returns the day name like "Monday"
  String get dayName {
    return DateFormat.EEEE().format(this);
  }

  /// Returns the short day name like "Mon"
  String get dayNameShort {
    return DateFormat.E().format(this);
  }

  /// Returns the month name like "January"
  String get monthName {
    return DateFormat.MMMM().format(this);
  }

  /// Returns the short month name like "Jan"
  String get monthNameShort {
    return DateFormat.MMM().format(this);
  }
}
