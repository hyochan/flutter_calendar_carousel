import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_calendar_carousel/src/weekday_row.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' show DateFormat;

void main() {
  final localeDate = DateFormat.yMMM('en_US');

  testWidgets('short format renders Sunday-first localized labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrapped(
        _row(
          localeDate,
          format: CalendarWeekdayFormat.short,
          firstDay: CalendarWeekday.sunday,
        ),
      ),
    );

    for (final label in <String>[
      'Sun',
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(
      tester.getCenter(find.text('Sun')).dx,
      lessThan(tester.getCenter(find.text('Sat')).dx),
    );
  });

  testWidgets('narrow standalone format renders seven compact labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrapped(
        _row(localeDate, format: CalendarWeekdayFormat.standaloneNarrow),
      ),
    );

    expect(find.text('S'), findsNWidgets(2));
    expect(find.text('T'), findsNWidgets(2));
    expect(find.text('M'), findsOneWidget);
    expect(find.text('W'), findsOneWidget);
    expect(find.text('F'), findsOneWidget);
  });

  testWidgets('full standalone format renders full weekday names', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrapped(_row(localeDate, format: CalendarWeekdayFormat.standaloneFull)),
    );

    for (final label in <String>[
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('standalone short format uses abbreviated labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrapped(_row(localeDate, format: CalendarWeekdayFormat.standaloneShort)),
    );

    expect(find.text('Sun'), findsOneWidget);
    expect(find.text('Wed'), findsOneWidget);
    expect(find.text('Sat'), findsOneWidget);
  });

  testWidgets('uppercase preserves the original accessibility label', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _wrapped(
        _row(localeDate, format: CalendarWeekdayFormat.short, uppercase: true),
      ),
    );

    expect(find.text('SUN'), findsOneWidget);
    expect(find.text('MON'), findsOneWidget);
    expect(find.text('Sun'), findsNothing);
    expect(find.bySemanticsLabel('Sun'), findsOneWidget);

    semantics.dispose();
  });

  testWidgets('uppercase honors Turkish dotted-I casing', (tester) async {
    final semantics = tester.ensureSemantics();
    await initializeDateFormatting('tr_TR');
    final turkishDate = DateFormat.yMMM('tr_TR');

    await tester.pumpWidget(
      _wrapped(
        _row(
          turkishDate,
          format: CalendarWeekdayFormat.full,
          firstDay: CalendarWeekday.monday,
          uppercase: true,
        ),
      ),
    );

    expect(find.text('PAZARTESİ'), findsOneWidget);
    expect(find.text('CUMARTESİ'), findsOneWidget);
    expect(find.bySemanticsLabel('Pazartesi'), findsOneWidget);

    semantics.dispose();
  });

  testWidgets('custom builder receives context and unambiguous weekday state', (
    tester,
  ) async {
    final received = <CalendarWeekdayDetails>[];

    await tester.pumpWidget(
      _wrapped(
        WeekdayRow(
          firstDayOfWeek: CalendarWeekday.monday.sundayBasedIndex,
          localeDate: localeDate,
          config: CalendarWeekdayConfig(
            uppercase: true,
            builder: (context, details) {
              received.add(details);
              return Text(
                '${details.position}:${details.weekday.name}:${details.label}',
              );
            },
          ),
          style: const CalendarWeekdayStyle(
            textStyle: TextStyle(color: Colors.indigo),
          ),
        ),
      ),
    );

    expect(received, hasLength(DateTime.daysPerWeek));
    expect(received.first.weekday, CalendarWeekday.monday);
    expect(received.first.position, 0);
    expect(received.first.label, 'MON');
    expect(received.first.style.textStyle?.color, Colors.indigo);
    expect(received[5].weekday, CalendarWeekday.saturday);
    expect(received[5].isWeekend, isTrue);
    expect(received[6].weekday, CalendarWeekday.sunday);
    expect(received[6].isWeekend, isTrue);
    expect(find.text('0:monday:MON'), findsOneWidget);
  });

  testWidgets('custom builder can fall back for individual weekdays', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrapped(
        WeekdayRow(
          firstDayOfWeek: CalendarWeekday.sunday.sundayBasedIndex,
          localeDate: localeDate,
          config: CalendarWeekdayConfig(
            builder: (context, details) =>
                details.weekday == CalendarWeekday.monday
                ? const Text('Work week starts')
                : null,
          ),
          style: const CalendarWeekdayStyle(),
        ),
      ),
    );

    expect(find.text('Work week starts'), findsOneWidget);
    expect(find.text('Mon'), findsNothing);
    for (final label in <String>['Sun', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('hidden weekday row occupies no layout space', (tester) async {
    final row = WeekdayRow(
      firstDayOfWeek: CalendarWeekday.sunday.sundayBasedIndex,
      localeDate: localeDate,
      config: const CalendarWeekdayConfig(visible: false),
      style: const CalendarWeekdayStyle(),
    );

    await tester.pumpWidget(_wrapped(row));

    expect(find.byWidget(row), findsOneWidget);
    expect(find.byType(Row), findsNothing);
    final hiddenBox = tester.widget<SizedBox>(
      find.descendant(of: find.byWidget(row), matching: find.byType(SizedBox)),
    );
    expect(hiddenBox.width, 0);
    expect(hiddenBox.height, 0);
  });
}

WeekdayRow _row(
  DateFormat localeDate, {
  required CalendarWeekdayFormat format,
  CalendarWeekday firstDay = CalendarWeekday.sunday,
  bool uppercase = false,
}) => WeekdayRow(
  firstDayOfWeek: firstDay.sundayBasedIndex,
  localeDate: localeDate,
  config: CalendarWeekdayConfig(format: format, uppercase: uppercase),
  style: const CalendarWeekdayStyle(),
);

Widget _wrapped(Widget widget) =>
    Directionality(textDirection: TextDirection.ltr, child: widget);
