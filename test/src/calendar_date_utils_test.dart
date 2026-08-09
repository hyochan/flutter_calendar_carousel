import 'package:flutter_calendar_carousel/src/calendar_date_utils.dart';
import 'package:flutter_calendar_carousel/src/calendar_pager.dart';
import 'package:flutter_calendar_carousel/src/calendar_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('civil date arithmetic', () {
    test('advances dates without assuming 24-hour days', () {
      expect(addCalendarDays(DateTime(2026, 3, 8), 1), DateTime(2026, 3, 9));
      expect(addCalendarDays(DateTime(2026, 3, 9), -1), DateTime(2026, 3, 8));
      expect(addCalendarDays(DateTime(2026, 11, 1), 1), DateTime(2026, 11, 2));
      expect(addCalendarDays(DateTime(2026, 11, 2), -1), DateTime(2026, 11, 1));
    });

    test('preserves dates skipped by a complete timezone offset jump', () {
      final samoaSkippedDate = addCalendarDays(DateTime(2011, 12, 29), 1);
      final kwajaleinSkippedDate = addCalendarDays(DateTime(1993, 8, 20), 1);

      expect(_civilDate(samoaSkippedDate), (2011, 12, 30));
      expect(_civilDate(addCalendarDays(samoaSkippedDate, 1)), (2011, 12, 31));
      expect(_civilDate(kwajaleinSkippedDate), (1993, 8, 21));
      expect(_civilDate(addCalendarDays(kwajaleinSkippedDate, 1)), (
        1993,
        8,
        22,
      ));
    });

    test('uses local dates when the civil date is locally representable', () {
      final normalized = dateOnly(DateTime.utc(2026, 5, 13, 23, 59));

      expect(_civilDate(normalized), (2026, 5, 13));
      expect(normalized.isUtc, isFalse);
      expect(normalized.hour, 0);
    });

    test('keeps the local carrier when a transition skips midnight', () {
      final localCarrier = DateTime(2018, 11, 4);
      final normalized = dateOnly(DateTime.utc(2018, 11, 4, 12));

      expect(_civilDate(normalized), (2018, 11, 4));
      expect(normalized, localCarrier);
      expect(normalized.isUtc, isFalse);

      // The dedicated America/Sao_Paulo CI run exercises its 2018 transition,
      // where Dart normalizes the nonexistent midnight to 01:00.
      if (localCarrier.hour != 0) {
        expect(localCarrier.hour, 1);
      }
    });
  });

  group('startOfWeek', () {
    test('honors Sunday and Monday starts across a year boundary', () {
      final newYear = DateTime(2026, 1, 1);

      expect(startOfWeek(newYear, 0), DateTime(2025, 12, 28));
      expect(startOfWeek(newYear, 1), DateTime(2025, 12, 29));
    });

    test('rejects invalid intl weekday indexes', () {
      expect(() => startOfWeek(DateTime(2026), -1), throwsArgumentError);
      expect(() => startOfWeek(DateTime(2026), 7), throwsArgumentError);
    });
  });

  group('CalendarMonthLayout', () {
    test('does not add a seventh row for a Monday-first month', () {
      final layout = CalendarMonthLayout(
        month: DateTime(2026, 8),
        firstDayOfWeek: 1,
        forceSixWeeks: false,
      );

      expect(layout.firstVisibleDate, DateTime(2026, 7, 27));
      expect(layout.itemCount, 42);
      expect(layout.dateAt(41), DateTime(2026, 9, 6));
    });

    test('uses only the rows a month needs unless six weeks are forced', () {
      final compact = CalendarMonthLayout(
        month: DateTime(2026, 2),
        firstDayOfWeek: 0,
        forceSixWeeks: false,
      );
      final fixed = CalendarMonthLayout(
        month: DateTime(2026, 2),
        firstDayOfWeek: 0,
        forceSixWeeks: true,
      );

      expect(compact.itemCount, 28);
      expect(fixed.itemCount, 42);
    });
  });

  group('CalendarPager', () {
    test('maps bounded month pages without precomputing every date', () {
      final pager = CalendarPager(
        view: CalendarView.month,
        minimumDate: DateTime(2025, 11, 20),
        maximumDate: DateTime(2026, 2, 3),
        firstDayOfWeek: 1,
      );

      expect(pager.pageCount, 4);
      expect(pager.pageFor(DateTime(2026, 1, 12)), 2);
      expect(pager.anchorForPage(2), DateTime(2026, 1));
    });

    test('maps Monday-first week pages without gaps or overlaps', () {
      final pager = CalendarPager(
        view: CalendarView.week,
        minimumDate: DateTime(2025, 12, 30),
        maximumDate: DateTime(2026, 1, 13),
        firstDayOfWeek: 1,
      );

      expect(pager.firstAnchor, DateTime(2025, 12, 29));
      expect(pager.pageCount, 3);
      expect(pager.datesForWeekPage(1), <DateTime>[
        DateTime(2026, 1, 5),
        DateTime(2026, 1, 6),
        DateTime(2026, 1, 7),
        DateTime(2026, 1, 8),
        DateTime(2026, 1, 9),
        DateTime(2026, 1, 10),
        DateTime(2026, 1, 11),
      ]);
      expect(pager.pageFor(DateTime(2026, 1, 13)), 2);
    });

    test('week pages retain civil dates skipped by the local timezone', () {
      for (final testCase
          in <({DateTime start, DateTime end, (int, int, int) skipped})>[
            (
              start: DateTime(2011, 12, 25),
              end: DateTime(2012, 1, 7),
              skipped: (2011, 12, 30),
            ),
            (
              start: DateTime(1993, 8, 15),
              end: DateTime(1993, 8, 28),
              skipped: (1993, 8, 21),
            ),
          ]) {
        final pager = CalendarPager(
          view: CalendarView.week,
          minimumDate: testCase.start,
          maximumDate: testCase.end,
          firstDayOfWeek: 0,
        );
        final pages = <List<DateTime>>[
          for (var page = 0; page < pager.pageCount; page++)
            pager.datesForWeekPage(page),
        ];
        final dates = pages.expand((page) => page).toList(growable: false);

        expect(dates.map(_civilDate), contains(testCase.skipped));
        for (var page = 0; page < pages.length; page++) {
          expect(
            pages[page].map(_civilDate).toSet(),
            hasLength(DateTime.daysPerWeek),
          );
          for (final date in pages[page]) {
            if (_isCivilDateWithin(date, testCase.start, testCase.end)) {
              expect(pager.pageFor(date), page);
            }
          }
        }
      }
    });

    for (var firstDayOfWeek = 0; firstDayOfWeek < 7; firstDayOfWeek++) {
      test('week pages round-trip without gaps for first day '
          '$firstDayOfWeek', () {
        final minimum = DateTime(2025, 12, 28);
        final maximum = DateTime(2026, 1, 17);
        final pager = CalendarPager(
          view: CalendarView.week,
          minimumDate: minimum,
          maximumDate: maximum,
          firstDayOfWeek: firstDayOfWeek,
        );

        expect(intlWeekday(pager.firstAnchor), firstDayOfWeek);
        for (var page = 0; page < pager.pageCount; page++) {
          final dates = pager.datesForWeekPage(page);
          expect(dates, hasLength(DateTime.daysPerWeek));
          expect(dates.first, pager.anchorForPage(page));
          for (var index = 1; index < dates.length; index++) {
            expect(dates[index], addCalendarDays(dates[index - 1], 1));
          }
          for (final date in dates.where(
            (date) => !date.isBefore(minimum) && !date.isAfter(maximum),
          )) {
            expect(pager.pageFor(date), page);
          }
          if (page > 0) {
            expect(
              pager.anchorForPage(page),
              addCalendarDays(pager.anchorForPage(page - 1), 7),
            );
          }
        }
        expect(pager.pageFor(minimum), 0);
        expect(pager.pageFor(maximum), pager.pageCount - 1);
      });
    }

    test('rejects an inverted selectable range', () {
      expect(
        () => CalendarPager(
          view: CalendarView.month,
          minimumDate: DateTime(2026, 2),
          maximumDate: DateTime(2026, 1),
          firstDayOfWeek: 0,
        ),
        throwsArgumentError,
      );
    });

    test('rejects week-date access from a month pager', () {
      final pager = CalendarPager(
        view: CalendarView.month,
        minimumDate: DateTime(2026, 1),
        maximumDate: DateTime(2026, 12, 31),
        firstDayOfWeek: 0,
      );

      expect(() => pager.datesForWeekPage(0), throwsStateError);
      expect(() => pager.anchorForPage(pager.pageCount), throwsRangeError);
    });
  });
}

(int, int, int) _civilDate(DateTime date) => (date.year, date.month, date.day);

bool _isCivilDateWithin(DateTime date, DateTime first, DateTime last) {
  final value = DateTime.utc(date.year, date.month, date.day);
  final minimum = DateTime.utc(first.year, first.month, first.day);
  final maximum = DateTime.utc(last.year, last.month, last.day);
  return !value.isBefore(minimum) && !value.isAfter(maximum);
}
