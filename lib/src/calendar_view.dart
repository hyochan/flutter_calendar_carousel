import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/src/calendar_theme.dart';

/// The calendar page layout.
enum CalendarView {
  /// One complete month grid per page.
  month,

  /// One seven-day row per page.
  week,
}

/// A civil weekday in Sunday-first order.
enum CalendarWeekday {
  /// Sunday (`0` in the package's Sunday-based representation).
  sunday(0),

  /// Monday.
  monday(1),

  /// Tuesday.
  tuesday(2),

  /// Wednesday.
  wednesday(3),

  /// Thursday.
  thursday(4),

  /// Friday.
  friday(5),

  /// Saturday.
  saturday(6);

  const CalendarWeekday(this.sundayBasedIndex);

  /// Index from `0` (Sunday) through `6` (Saturday).
  final int sundayBasedIndex;

  /// Dart's weekday value from `1` (Monday) through `7` (Sunday).
  int get dartWeekday =>
      sundayBasedIndex == 0 ? DateTime.sunday : sundayBasedIndex;

  /// Resolves a Sunday-based weekday index.
  static CalendarWeekday fromSundayBasedIndex(int index) {
    RangeError.checkValidIndex(index, values, 'index');
    return values[index];
  }
}

/// A month's date position relative to the page's anchor month.
///
/// Week pages report [CalendarMonthPosition.current] for all seven dates.
enum CalendarMonthPosition {
  /// The date precedes the page's anchor month.
  previous,

  /// The date belongs to the page's anchor month.
  current,

  /// The date follows the page's anchor month.
  next,
}

/// Localized weekday-label width.
enum CalendarWeekdayFormat {
  /// Full weekday name used in formatted dates.
  full,

  /// Full weekday name intended to stand alone.
  standaloneFull,

  /// Abbreviated weekday name used in formatted dates.
  short,

  /// Abbreviated weekday name intended to stand alone.
  standaloneShort,

  /// Narrow weekday name used in formatted dates.
  narrow,

  /// Narrow weekday name intended to stand alone.
  standaloneNarrow,
}

/// Named state supplied to day, marker, and style builders.
@immutable
class CalendarDayDetails<T> {
  /// Creates the immutable state for one visible day.
  const CalendarDayDetails({
    required this.date,
    required this.events,
    required this.isEnabled,
    required this.isSelected,
    required this.isToday,
    required this.isWeekend,
    required this.monthPosition,
    required this.pageAnchor,
    required this.style,
  });

  /// Local civil date represented by this cell.
  final DateTime date;

  /// Events resolved for [date]. Callers must not mutate this list.
  final List<T> events;

  /// Whether the date accepts selection callbacks.
  final bool isEnabled;

  /// Whether [date] is selected.
  final bool isSelected;

  /// Whether [date] is today's local civil date.
  final bool isToday;

  /// Whether the locale considers [date] a weekend day.
  final bool isWeekend;

  /// Position relative to [pageAnchor]'s month in month view.
  ///
  /// This is always [CalendarMonthPosition.current] in week view.
  final CalendarMonthPosition monthPosition;

  /// First day of the represented month or week page.
  final DateTime pageAnchor;

  /// Fully resolved visual style for this day.
  final CalendarDayStyle style;

  /// Whether [date] is outside [pageAnchor]'s month in month view.
  ///
  /// This is always false in week view.
  bool get isOutsideMonth => monthPosition != CalendarMonthPosition.current;
}

/// Information supplied to a custom calendar header.
@immutable
class CalendarHeaderDetails {
  /// Creates immutable state and actions for a custom header.
  const CalendarHeaderDetails({
    required this.pageAnchor,
    required this.label,
    required this.view,
    required this.style,
    this.onPrevious,
    this.onNext,
    this.onTitlePressed,
  });

  /// First civil date represented by the visible page.
  final DateTime pageAnchor;

  /// Localized label produced for the visible page.
  final String label;

  /// Current month or week layout.
  final CalendarView view;

  /// Fully resolved header style.
  final CalendarHeaderStyle style;

  /// Navigates to the previous page, or null at the configured boundary.
  final VoidCallback? onPrevious;

  /// Navigates to the next page, or null at the configured boundary.
  final VoidCallback? onNext;

  /// Runs the configured title action, or null when the title is inert.
  final VoidCallback? onTitlePressed;
}

/// Information supplied for one localized weekday label.
@immutable
class CalendarWeekdayDetails {
  /// Creates immutable state for one localized weekday label.
  const CalendarWeekdayDetails({
    required this.weekday,
    required this.position,
    required this.label,
    required this.isWeekend,
    required this.style,
  });

  /// Civil weekday represented by the label.
  final CalendarWeekday weekday;

  /// Visible position from zero through six after applying the first weekday.
  final int position;

  /// Localized and optionally uppercased label.
  final String label;

  /// Whether the locale considers [weekday] part of its weekend.
  final bool isWeekend;

  /// Fully resolved weekday-row style.
  final CalendarWeekdayStyle style;
}

/// Builds custom content for one calendar day.
typedef CalendarDayBuilder<T> =
    Widget? Function(BuildContext context, CalendarDayDetails<T> day);

/// Builds the marker layer for a day with events.
typedef CalendarMarkerBuilder<T> =
    Widget? Function(BuildContext context, CalendarDayDetails<T> day);

/// Resolves a date-specific style merged before today, disabled, and selected.
typedef CalendarDayStyleResolver<T> =
    CalendarDayStyle? Function(BuildContext context, CalendarDayDetails<T> day);

/// Builds a replacement header.
typedef CalendarHeaderBuilder =
    Widget Function(BuildContext context, CalendarHeaderDetails details);

/// Builds one replacement weekday label.
typedef CalendarWeekdayBuilder =
    Widget? Function(BuildContext context, CalendarWeekdayDetails details);
