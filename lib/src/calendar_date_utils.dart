/// Date-only helpers used by the calendar pager and layouts.
///
/// Returned dates use the local timezone whenever that timezone can represent
/// the requested civil date. A timezone can exceptionally skip a complete
/// civil day when its UTC offset changes by 24 hours. For that otherwise
/// unrepresentable date, these helpers use UTC midnight as a lossless carrier
/// for the exact year, month, and day.
///
/// Calendar arithmetic is performed with constructors instead of adding
/// 24-hour durations so daylight-saving transitions cannot move a date into
/// the previous or next day. Treat returned values as civil dates rather than
/// instants and compare their year, month, and day components.
DateTime dateOnly(DateTime date) => _civilDate(date.year, date.month, date.day);

bool isSameDate(DateTime first, DateTime second) =>
    first.year == second.year &&
    first.month == second.month &&
    first.day == second.day;

bool isSameMonth(DateTime first, DateTime second) =>
    first.year == second.year && first.month == second.month;

DateTime addCalendarDays(DateTime date, int days) =>
    _civilDate(date.year, date.month, date.day + days);

int calendarDaysBetween(DateTime start, DateTime end) => DateTime.utc(
  end.year,
  end.month,
  end.day,
).difference(DateTime.utc(start.year, start.month, start.day)).inDays;

DateTime clampDate(DateTime date, DateTime minimum, DateTime maximum) {
  final normalized = dateOnly(date);
  if (normalized.isBefore(minimum)) return minimum;
  if (normalized.isAfter(maximum)) return maximum;
  return normalized;
}

/// Converts Dart's weekday to the Sunday-based index used by intl's weekday
/// name arrays and this package's `firstDayOfWeek` API.
int intlWeekday(DateTime date) => date.weekday % DateTime.daysPerWeek;

/// Converts Dart's weekday to the Monday-based CLDR index used by
/// `DateSymbols.WEEKENDRANGE`.
int cldrWeekday(DateTime date) => date.weekday - DateTime.monday;

int validateFirstDayOfWeek(int value) {
  if (value < 0 || value >= DateTime.daysPerWeek) {
    throw ArgumentError.value(
      value,
      'firstDayOfWeek',
      'must be between 0 (Sunday) and 6 (Saturday)',
    );
  }
  return value;
}

DateTime startOfWeek(DateTime date, int firstDayOfWeek) {
  final validatedFirstDay = validateFirstDayOfWeek(firstDayOfWeek);
  final normalized = dateOnly(date);
  final daysFromStart =
      (intlWeekday(normalized) - validatedFirstDay + DateTime.daysPerWeek) %
      DateTime.daysPerWeek;
  return addCalendarDays(normalized, -daysFromStart);
}

DateTime firstDayOfMonth(DateTime date) => _civilDate(date.year, date.month, 1);

DateTime addCalendarMonths(DateTime date, int months) =>
    _civilDate(date.year, date.month + months, 1);

int calendarMonthsBetween(DateTime start, DateTime end) =>
    (end.year - start.year) * 12 + end.month - start.month;

class CalendarMonthLayout {
  CalendarMonthLayout({
    required DateTime month,
    required int firstDayOfWeek,
    required bool forceSixWeeks,
  }) : month = firstDayOfMonth(month),
       firstDayOfWeek = validateFirstDayOfWeek(firstDayOfWeek) {
    leadingDayCount =
        (intlWeekday(this.month) - this.firstDayOfWeek + DateTime.daysPerWeek) %
        DateTime.daysPerWeek;
    firstVisibleDate = addCalendarDays(this.month, -leadingDayCount);

    final daysInMonth = DateTime.utc(
      this.month.year,
      this.month.month + 1,
      0,
    ).day;
    final occupiedCells = leadingDayCount + daysInMonth;
    itemCount = forceSixWeeks
        ? 6 * DateTime.daysPerWeek
        : ((occupiedCells + DateTime.daysPerWeek - 1) ~/ DateTime.daysPerWeek) *
              DateTime.daysPerWeek;
  }

  final DateTime month;
  final int firstDayOfWeek;
  late final int leadingDayCount;
  late final DateTime firstVisibleDate;
  late final int itemCount;

  DateTime dateAt(int index) {
    RangeError.checkValidIndex(index, this, 'index', itemCount);
    return addCalendarDays(firstVisibleDate, index);
  }
}

DateTime _civilDate(int year, int month, int day) {
  final normalized = DateTime.utc(year, month, day);
  final local = DateTime(normalized.year, normalized.month, normalized.day);
  return isSameDate(local, normalized) ? local : normalized;
}
