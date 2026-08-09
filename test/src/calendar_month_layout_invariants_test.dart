import 'package:flutter_calendar_carousel/src/calendar_date_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final forceSixWeeks in <bool>[false, true]) {
    for (final targetMonth in <DateTime>[
      DateTime(2026, 4),
      DateTime(2024, 2),
      DateTime(2011, 12),
      DateTime(1993, 8),
    ]) {
      for (
        var firstDayOfWeek = 0;
        firstDayOfWeek < DateTime.daysPerWeek;
        firstDayOfWeek++
      ) {
        test('${targetMonth.year}-${targetMonth.month} layout is complete and '
            'consecutive for first day $firstDayOfWeek with '
            'forceSixWeeks=$forceSixWeeks', () {
          final layout = CalendarMonthLayout(
            month: targetMonth,
            firstDayOfWeek: firstDayOfWeek,
            forceSixWeeks: forceSixWeeks,
          );
          final visibleDates = List<DateTime>.generate(
            layout.itemCount,
            layout.dateAt,
            growable: false,
          );

          expect(layout.itemCount, isPositive);
          expect(layout.itemCount % DateTime.daysPerWeek, 0);
          expect(
            intlWeekday(visibleDates.first),
            firstDayOfWeek,
            reason: 'the first column must use the configured week start',
          );
          expect(
            visibleDates
                .map((date) => (date.year, date.month, date.day))
                .toSet(),
            hasLength(visibleDates.length),
          );

          for (var index = 1; index < visibleDates.length; index++) {
            expect(
              visibleDates[index],
              addCalendarDays(visibleDates[index - 1], 1),
              reason: 'visible dates must be consecutive at index $index',
            );
          }

          final targetMonthDays = visibleDates
              .where(
                (date) =>
                    date.year == targetMonth.year &&
                    date.month == targetMonth.month,
              )
              .map((date) => date.day)
              .toList(growable: false);
          final daysInMonth = DateTime.utc(
            targetMonth.year,
            targetMonth.month + 1,
            0,
          ).day;
          final expectedDays = List<int>.generate(
            daysInMonth,
            (index) => index + 1,
          );

          expect(targetMonthDays, expectedDays);
          if (forceSixWeeks) {
            expect(layout.itemCount, 6 * DateTime.daysPerWeek);
          } else {
            expect(
              layout.itemCount,
              lessThanOrEqualTo(6 * DateTime.daysPerWeek),
            );
          }
        });
      }
    }
  }
}
