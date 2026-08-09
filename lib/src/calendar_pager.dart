import 'package:flutter_calendar_carousel/src/calendar_date_utils.dart';
import 'package:flutter_calendar_carousel/src/calendar_view.dart';

/// Pure page/date mapping shared by month and week views.
class CalendarPager {
  CalendarPager({
    required CalendarView view,
    required DateTime minimumDate,
    required DateTime maximumDate,
    required int firstDayOfWeek,
  }) : view = view,
       minimumDate = dateOnly(minimumDate),
       maximumDate = dateOnly(maximumDate),
       firstDayOfWeek = validateFirstDayOfWeek(firstDayOfWeek) {
    if (this.minimumDate.isAfter(this.maximumDate)) {
      throw ArgumentError.value(
        minimumDate,
        'minimumDate',
        'must be on or before maximumDate',
      );
    }

    _firstAnchor = view == CalendarView.month
        ? firstDayOfMonth(this.minimumDate)
        : startOfWeek(this.minimumDate, this.firstDayOfWeek);
    final lastAnchor = view == CalendarView.month
        ? firstDayOfMonth(this.maximumDate)
        : startOfWeek(this.maximumDate, this.firstDayOfWeek);
    pageCount = view == CalendarView.month
        ? calendarMonthsBetween(_firstAnchor, lastAnchor) + 1
        : calendarDaysBetween(_firstAnchor, lastAnchor) ~/
                  DateTime.daysPerWeek +
              1;
  }

  final CalendarView view;
  final DateTime minimumDate;
  final DateTime maximumDate;
  final int firstDayOfWeek;
  late final DateTime _firstAnchor;
  late final int pageCount;

  DateTime get firstAnchor => _firstAnchor;

  int pageFor(DateTime date) {
    final boundedDate = clampDate(date, minimumDate, maximumDate);
    final page = view == CalendarView.month
        ? calendarMonthsBetween(_firstAnchor, firstDayOfMonth(boundedDate))
        : calendarDaysBetween(
                _firstAnchor,
                startOfWeek(boundedDate, firstDayOfWeek),
              ) ~/
              DateTime.daysPerWeek;
    return page.clamp(0, pageCount - 1);
  }

  DateTime anchorForPage(int page) {
    RangeError.checkValidIndex(page, this, 'page', pageCount);
    return view == CalendarView.month
        ? addCalendarMonths(_firstAnchor, page)
        : addCalendarDays(_firstAnchor, page * DateTime.daysPerWeek);
  }

  List<DateTime> datesForWeekPage(int page) {
    if (view != CalendarView.week) {
      throw StateError('datesForWeekPage is only available in week view.');
    }
    final anchor = anchorForPage(page);
    return List<DateTime>.generate(
      DateTime.daysPerWeek,
      (index) => addCalendarDays(anchor, index),
      growable: false,
    );
  }
}
