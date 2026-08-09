import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final firstDate = DateTime(2026, 1, 1);
  final lastDate = DateTime(2026, 12, 31);
  final focus = DateTime(2026, 5, 13);

  testWidgets('month view renders a deterministic focused page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        CalendarCarousel<void>.month(
          focusedDate: focus,
          firstDate: firstDate,
          lastDate: lastDate,
          locale: const Locale('en', 'US'),
        ),
      ),
    );

    expect(find.text('May 2026'), findsOneWidget);
    expect(find.byKey(ValueKey<DateTime>(focus)), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('week view always builds seven consecutive civil dates', (
    WidgetTester tester,
  ) async {
    final builtDates = <DateTime>[];
    await tester.pumpWidget(
      _host(
        CalendarCarousel<void>.week(
          focusedDate: DateTime(2026, 1, 1),
          firstDate: firstDate,
          lastDate: lastDate,
          firstDayOfWeek: CalendarWeekday.monday,
          dayBuilder: (context, day) {
            builtDates.add(day.date);
            return Text('${day.date.day}');
          },
        ),
      ),
    );

    final uniqueDates = builtDates.toSet().toList()..sort();
    expect(uniqueDates, <DateTime>[
      DateTime(2025, 12, 29),
      DateTime(2025, 12, 30),
      DateTime(2025, 12, 31),
      DateTime(2026, 1, 1),
      DateTime(2026, 1, 2),
      DateTime(2026, 1, 3),
      DateTime(2026, 1, 4),
    ]);
  });

  testWidgets('tap reports the rendered immutable event snapshot once', (
    WidgetTester tester,
  ) async {
    final release = _Release('3.0');
    var targetCalls = 0;
    DateTime? pressedDate;
    List<_Release>? pressedEvents;

    await tester.pumpWidget(
      _host(
        CalendarCarousel<_Release>.month(
          focusedDate: focus,
          firstDate: firstDate,
          lastDate: lastDate,
          eventsForDate: (date) {
            if (date == focus) {
              targetCalls++;
              return <_Release>[release];
            }
            return const <_Release>[];
          },
          onDateSelected: (date, events) {
            pressedDate = date;
            pressedEvents = events;
          },
        ),
      ),
    );
    final callsAfterBuild = targetCalls;

    await tester.tap(find.byKey(ValueKey<DateTime>(focus)));
    await tester.pump();

    expect(pressedDate, focus);
    expect(pressedEvents, <_Release>[release]);
    expect(targetCalls, callsAfterBuild);
    expect(
      () => pressedEvents!.add(_Release('mutate')),
      throwsUnsupportedError,
    );
  });

  testWidgets('selectedDate remains controlled by the parent', (
    WidgetTester tester,
  ) async {
    var selected = DateTime(2026, 5, 13);
    late StateSetter updateHost;

    await tester.pumpWidget(
      _hostBuilder((context, setState) {
        updateHost = setState;
        return CalendarCarousel<void>.month(
          selectedDate: selected,
          focusedDate: focus,
          firstDate: firstDate,
          lastDate: lastDate,
          onDateSelected: (date, events) {},
          dayBuilder: (context, day) => Text(
            '${day.date.day}:${day.isSelected}',
            key: ValueKey<String>('day-${day.date.toIso8601String()}'),
          ),
        );
      }),
    );

    expect(find.text('13:true'), findsOneWidget);
    await tester.tap(find.byKey(ValueKey<DateTime>(DateTime(2026, 5, 14))));
    await tester.pump();
    expect(find.text('13:true'), findsOneWidget);
    expect(find.text('14:false'), findsOneWidget);

    updateHost(() => selected = DateTime(2026, 5, 14));
    await tester.pump();
    expect(find.text('13:false'), findsOneWidget);
    expect(find.text('14:true'), findsOneWidget);
  });

  testWidgets('disabled dates expose no tap or long-press callbacks', (
    WidgetTester tester,
  ) async {
    final disabled = DateTime(2026, 5, 13);
    var taps = 0;
    var longPresses = 0;
    await tester.pumpWidget(
      _host(
        CalendarCarousel<void>.month(
          focusedDate: disabled,
          firstDate: firstDate,
          lastDate: lastDate,
          isDateEnabled: (date) => date != disabled,
          onDateSelected: (date, events) => taps++,
          onDateLongPressed: (date) => longPresses++,
        ),
      ),
    );

    final day = find.byKey(ValueKey<DateTime>(disabled));
    await tester.tap(day);
    await tester.longPress(day);
    await tester.pump();
    expect(taps, 0);
    expect(longPresses, 0);
  });

  testWidgets('enabled long press reports the exact local civil date', (
    WidgetTester tester,
  ) async {
    DateTime? reported;
    await tester.pumpWidget(
      _host(
        CalendarCarousel<void>.month(
          focusedDate: focus,
          firstDate: firstDate,
          lastDate: lastDate,
          onDateLongPressed: (date) => reported = date,
        ),
      ),
    );

    await tester.longPress(find.byKey(ValueKey<DateTime>(focus)));
    await tester.pump();
    expect(reported, focus);
    expect(reported!.hour, 0);
  });

  testWidgets('focusedDate is clamped to the nearest configured page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        CalendarCarousel<void>.month(
          focusedDate: DateTime(2030),
          firstDate: DateTime(2026, 8, 10),
          lastDate: DateTime(2026, 10, 20),
        ),
      ),
    );
    expect(find.text('Oct 2026'), findsOneWidget);

    await tester.pumpWidget(
      _host(
        CalendarCarousel<void>.month(
          focusedDate: DateTime(2020),
          firstDate: DateTime(2026, 8, 10),
          lastDate: DateTime(2026, 10, 20),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Aug 2026'), findsOneWidget);
  });

  testWidgets('inverted range fails with a clear public argument name', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        CalendarCarousel<void>(
          firstDate: DateTime(2026, 2),
          lastDate: DateTime(2026, 1),
        ),
      ),
    );

    final exception = tester.takeException();
    expect(exception, isA<ArgumentError>());
    expect(exception.toString(), contains('firstDate'));
  });

  testWidgets('showOutsideDays only hides adjacent dates in month view', (
    WidgetTester tester,
  ) async {
    final outside = DateTime(2026, 3, 30);
    await tester.pumpWidget(
      _host(
        CalendarCarousel<void>.month(
          focusedDate: DateTime(2026, 4, 15),
          firstDate: DateTime(2026, 3),
          lastDate: DateTime(2026, 5, 31),
          firstDayOfWeek: CalendarWeekday.monday,
          layout: const CalendarLayoutConfig(showOutsideDays: false),
        ),
      ),
    );
    expect(
      find.descendant(
        of: find.byKey(ValueKey<DateTime>(outside)),
        matching: find.byType(TextButton),
      ),
      findsNothing,
    );

    await tester.pumpWidget(
      _host(
        CalendarCarousel<void>.week(
          focusedDate: DateTime(2026, 4, 1),
          firstDate: DateTime(2026, 3),
          lastDate: DateTime(2026, 5, 31),
          firstDayOfWeek: CalendarWeekday.monday,
          layout: const CalendarLayoutConfig(showOutsideDays: false),
        ),
      ),
    );
    await tester.pump();
    for (var day = 30; day <= 31; day++) {
      expect(
        find.byKey(ValueKey<DateTime>(DateTime(2026, 3, day))),
        findsOneWidget,
      );
    }
    for (var day = 1; day <= 5; day++) {
      expect(
        find.byKey(ValueKey<DateTime>(DateTime(2026, 4, day))),
        findsOneWidget,
      );
    }
    expect(find.byType(TextButton), findsNothing);
  });

  testWidgets('the calendar sizes itself from parent constraints', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 320,
            height: 420,
            child: CalendarCarousel<void>.month(
              focusedDate: focus,
              firstDate: firstDate,
              lastDate: lastDate,
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(CalendarCarousel<void>)),
      const Size(320, 420),
    );
    expect(tester.takeException(), isNull);
  });
}

class _Release {
  const _Release(this.name);

  final String name;

  @override
  bool operator ==(Object other) => other is _Release && other.name == name;

  @override
  int get hashCode => name.hashCode;
}

Widget _host(Widget child) => MaterialApp(
  locale: const Locale('en', 'US'),
  home: Scaffold(body: SizedBox(width: 420, height: 520, child: child)),
);

Widget _hostBuilder(
  Widget Function(BuildContext context, StateSetter setState) builder,
) => MaterialApp(
  locale: const Locale('en', 'US'),
  home: Scaffold(
    body: SizedBox(
      width: 420,
      height: 520,
      child: StatefulBuilder(builder: builder),
    ),
  ),
);
