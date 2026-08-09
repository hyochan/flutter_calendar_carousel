import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'month and week changes preserve focus and controlled selection',
    (tester) async {
      var view = CalendarView.month;
      late StateSetter updateHost;
      final selected = DateTime(2026, 5, 13);

      await tester.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (context, setState) {
              updateHost = setState;
              return _calendar(
                view: view,
                selectedDate: selected,
                focusedDate: selected,
                firstDayOfWeek: CalendarWeekday.monday,
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(_details(tester, selected).isSelected, isTrue);
      expect(_details(tester, selected).pageAnchor, DateTime(2026, 5));

      updateHost(() => view = CalendarView.week);
      await tester.pumpAndSettle();
      expect(_details(tester, selected).isSelected, isTrue);
      expect(_details(tester, selected).pageAnchor, DateTime(2026, 5, 11));

      updateHost(() => view = CalendarView.month);
      await tester.pumpAndSettle();
      expect(_details(tester, selected).isSelected, isTrue);
      expect(_details(tester, selected).pageAnchor, DateTime(2026, 5));
    },
  );

  testWidgets('explicit focus wins over selection during view changes', (
    tester,
  ) async {
    var view = CalendarView.month;
    late StateSetter updateHost;
    final selected = DateTime(2026, 5);
    final focused = DateTime(2026, 5, 31);

    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            updateHost = setState;
            return _calendar(
              view: view,
              selectedDate: selected,
              focusedDate: focused,
              firstDayOfWeek: CalendarWeekday.sunday,
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    updateHost(() => view = CalendarView.week);
    await tester.pumpAndSettle();

    expect(_details(tester, focused).pageAnchor, focused);
    expect(_probeFinder(selected), findsNothing);
  });

  for (final firstDay in CalendarWeekday.values) {
    testWidgets(
      'week renders seven consecutive year-boundary dates from ${firstDay.name}',
      (tester) async {
        final focus = DateTime(2026, 12, 31);
        final expectedStart = _startOfWeek(focus, firstDay);
        await tester.pumpWidget(
          _host(
            _calendar(
              view: CalendarView.week,
              focusedDate: focus,
              firstDate: DateTime(2026, 12),
              lastDate: DateTime(2027, 1, 31),
              firstDayOfWeek: firstDay,
              layout: const CalendarLayoutConfig(showOutsideDays: false),
            ),
            height: 220,
          ),
        );
        await tester.pumpAndSettle();

        for (var offset = 0; offset < DateTime.daysPerWeek; offset++) {
          final date = _addDays(expectedStart, offset);
          expect(_probeFinder(date), findsOneWidget);
          expect(_details(tester, date).pageAnchor, expectedStart);
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('focusedDate moves pages while selectedDate stays controlled', (
    tester,
  ) async {
    var focusedDate = DateTime(2026, 5, 13);
    var selectedDate = DateTime(2026, 5, 13);
    final changedPages = <DateTime>[];
    late StateSetter updateHost;

    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            updateHost = setState;
            return _calendar(
              selectedDate: selectedDate,
              focusedDate: focusedDate,
              onPageChanged: changedPages.add,
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    updateHost(() => focusedDate = DateTime(2026, 8, 20));
    await tester.pumpAndSettle();
    expect(find.text('Aug 2026'), findsOneWidget);
    expect(changedPages, <DateTime>[DateTime(2026, 8)]);

    updateHost(() => selectedDate = DateTime(2026, 8, 20));
    await tester.pump();
    expect(_details(tester, selectedDate).isSelected, isTrue);

    await tester.tap(_dayFinder(DateTime(2026, 8, 21)));
    await tester.pump();
    expect(_details(tester, selectedDate).isSelected, isTrue);
    expect(_details(tester, DateTime(2026, 8, 21)).isSelected, isFalse);
  });

  testWidgets('same-page focus update cancels an in-flight page request', (
    tester,
  ) async {
    var focusedDate = DateTime(2026, 5, 13);
    late StateSetter updateHost;

    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            updateHost = setState;
            return _calendar(focusedDate: focusedDate);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(_nextButton());
    updateHost(() => focusedDate = DateTime(2026, 5, 20));
    await tester.pumpAndSettle();

    expect(find.text('May 2026'), findsOneWidget);
    expect(_details(tester, focusedDate).pageAnchor, DateTime(2026, 5));
  });

  testWidgets('same-page focus update cancels an in-flight swipe', (
    tester,
  ) async {
    var focusedDate = DateTime(2026, 5, 13);
    late StateSetter updateHost;

    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            updateHost = setState;
            return _calendar(focusedDate: focusedDate);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
    updateHost(() => focusedDate = DateTime(2026, 5, 20));
    await tester.pumpAndSettle();

    expect(find.text('May 2026'), findsOneWidget);
    expect(_details(tester, focusedDate).pageAnchor, DateTime(2026, 5));
  });

  testWidgets(
    'first weekday and viewport changes retain an in-flight week target',
    (tester) async {
      var firstDay = CalendarWeekday.monday;
      var viewportFraction = 1.0;
      final changedPages = <DateTime>[];
      late StateSetter updateHost;

      await tester.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (context, setState) {
              updateHost = setState;
              return _calendar(
                view: CalendarView.week,
                focusedDate: DateTime(2026, 5, 13),
                firstDayOfWeek: firstDay,
                paging: CalendarPagingConfig(
                  viewportFraction: viewportFraction,
                ),
                onPageChanged: changedPages.add,
              );
            },
          ),
          height: 220,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(_nextButton());
      updateHost(() {
        firstDay = CalendarWeekday.sunday;
        viewportFraction = .75;
      });
      await tester.pumpAndSettle();

      final pageView = tester.widget<PageView>(find.byType(PageView));
      expect(pageView.controller!.viewportFraction, .75);
      expect(
        _details(tester, DateTime(2026, 5, 21)).pageAnchor,
        DateTime(2026, 5, 17),
      );
      expect(changedPages, <DateTime>[
        DateTime(2026, 5, 18),
        DateTime(2026, 5, 17),
      ]);
    },
  );

  testWidgets('range changes clamp the visible page and report it once', (
    tester,
  ) async {
    var firstDate = DateTime(2026, 5);
    var lastDate = DateTime(2026, 12, 31);
    final changedPages = <DateTime>[];
    late StateSetter updateHost;

    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            updateHost = setState;
            return _calendar(
              focusedDate: DateTime(2026, 5, 13),
              firstDate: firstDate,
              lastDate: lastDate,
              onPageChanged: changedPages.add,
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    updateHost(() {
      firstDate = DateTime(2026, 7, 10);
      lastDate = DateTime(2026, 8, 20);
    });
    await tester.pumpAndSettle();
    expect(find.text('Jul 2026'), findsOneWidget);
    expect(changedPages, <DateTime>[DateTime(2026, 7)]);
    expect(_details(tester, DateTime(2026, 7, 9)).isEnabled, isFalse);
    expect(_details(tester, DateTime(2026, 7, 10)).isEnabled, isTrue);
  });

  testWidgets('rapid next taps report four exact targets without duplicates', (
    tester,
  ) async {
    final changedPages = <DateTime>[];
    await tester.pumpWidget(
      _host(
        _calendar(
          focusedDate: DateTime(2026, 5, 13),
          onPageChanged: changedPages.add,
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (var count = 0; count < 4; count++) {
      await tester.tap(_nextButton());
    }
    await tester.pumpAndSettle();

    expect(find.text('Sep 2026'), findsOneWidget);
    expect(changedPages, <DateTime>[
      DateTime(2026, 6),
      DateTime(2026, 7),
      DateTime(2026, 8),
      DateTime(2026, 9),
    ]);
  });

  testWidgets(
    'opposite rapid taps report request order without page duplicates',
    (tester) async {
      final changedPages = <DateTime>[];
      await tester.pumpWidget(
        _host(
          _calendar(
            focusedDate: DateTime(2026, 5, 13),
            onPageChanged: changedPages.add,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(_nextButton());
      await tester.tap(_previousButton());
      await tester.pumpAndSettle();

      expect(find.text('May 2026'), findsOneWidget);
      expect(changedPages, <DateTime>[DateTime(2026, 6), DateTime(2026, 5)]);
    },
  );

  testWidgets('horizontal swipe settles one month and emits one callback', (
    tester,
  ) async {
    final changedPages = <DateTime>[];
    await tester.pumpWidget(
      _host(
        _calendar(
          focusedDate: DateTime(2026, 5, 13),
          onPageChanged: changedPages.add,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(PageView), const Offset(-350, 0));
    await tester.pumpAndSettle();
    expect(find.text('Jun 2026'), findsOneWidget);
    expect(changedPages, <DateTime>[DateTime(2026, 6)]);
  });

  testWidgets('vertical drag pages instead of scrolling the day grid', (
    tester,
  ) async {
    final changedPages = <DateTime>[];
    await tester.pumpWidget(
      _host(
        _calendar(
          focusedDate: DateTime(2026, 5, 13),
          paging: const CalendarPagingConfig(axis: Axis.vertical),
          onPageChanged: changedPages.add,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final grid = tester.widget<GridView>(find.byType(GridView).first);
    expect(grid.physics, isA<NeverScrollableScrollPhysics>());
    await tester.drag(find.byType(PageView), const Offset(0, -350));
    await tester.pumpAndSettle();
    expect(find.text('Jun 2026'), findsOneWidget);
    expect(changedPages, <DateTime>[DateTime(2026, 6)]);
  });

  testWidgets('axis changes safely while a page drag is active', (
    tester,
  ) async {
    var axis = Axis.horizontal;
    late StateSetter updateHost;

    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            updateHost = setState;
            return _calendar(
              focusedDate: DateTime(2026, 5, 13),
              paging: CalendarPagingConfig(axis: axis),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final firstDrag = await tester.startGesture(
      tester.getCenter(find.byType(PageView)),
      pointer: 7,
    );
    await firstDrag.moveBy(const Offset(-100, 0));
    await tester.pump();
    updateHost(() => axis = Axis.vertical);
    await tester.pump();
    await firstDrag.up();
    await tester.pump();

    final secondDrag = await tester.startGesture(
      tester.getCenter(find.byType(PageView)),
      pointer: 8,
    );
    await secondDrag.moveBy(const Offset(0, -350));
    await secondDrag.up();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Jun 2026'), findsOneWidget);

    updateHost(() => axis = Axis.horizontal);
    await tester.pumpAndSettle();
    expect(find.text('Jun 2026'), findsOneWidget);
  });

  testWidgets('month can hide outside dates without affecting complete weeks', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        _calendar(
          focusedDate: DateTime(2026, 4, 15),
          firstDayOfWeek: CalendarWeekday.monday,
          layout: const CalendarLayoutConfig(showOutsideDays: false),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(_probeFinder(DateTime(2026, 3, 30)), findsNothing);
    expect(_probeFinder(DateTime(2026, 4, 1)), findsOneWidget);
    expect(_probeFinder(DateTime(2026, 5, 1)), findsNothing);
  });

  testWidgets('cross-month weeks do not dim the primary month', (tester) async {
    await tester.pumpWidget(
      _host(
        _calendar(
          view: CalendarView.week,
          focusedDate: DateTime(2026, 6, 3),
          firstDayOfWeek: CalendarWeekday.sunday,
          theme: const CalendarCarouselThemeData(
            day: CalendarDayStyle(textStyle: TextStyle(color: Colors.black)),
            weekend: CalendarDayStyle(
              textStyle: TextStyle(color: Colors.black),
            ),
            outsideMonth: CalendarDayStyle(
              textStyle: TextStyle(color: Colors.grey),
            ),
          ),
        ),
        height: 220,
      ),
    );
    await tester.pumpAndSettle();

    for (var day = 31; day <= 37; day++) {
      final date = DateTime(2026, 5, day);
      final details = _details(tester, date);
      expect(details.monthPosition, CalendarMonthPosition.current);
      expect(details.style.textStyle?.color, Colors.black);
    }
  });

  testWidgets('firstDate, lastDate, and isDateEnabled share civil dates', (
    tester,
  ) async {
    final selectedDates = <DateTime>[];
    final longPressedDates = <DateTime>[];
    await tester.pumpWidget(
      _host(
        _calendar(
          view: CalendarView.week,
          focusedDate: DateTime(2026, 5, 13),
          firstDate: DateTime(2026, 5, 12, 23, 59),
          lastDate: DateTime(2026, 5, 15, 23, 59),
          firstDayOfWeek: CalendarWeekday.monday,
          isDateEnabled: (date) => date != DateTime(2026, 5, 14),
          onDateSelected: (date, _) => selectedDates.add(date),
          onDateLongPressed: longPressedDates.add,
        ),
        height: 220,
      ),
    );
    await tester.pumpAndSettle();

    expect(_details(tester, DateTime(2026, 5, 11)).isEnabled, isFalse);
    expect(_details(tester, DateTime(2026, 5, 12)).isEnabled, isTrue);
    expect(_details(tester, DateTime(2026, 5, 14)).isEnabled, isFalse);
    expect(_details(tester, DateTime(2026, 5, 15)).isEnabled, isTrue);
    expect(_details(tester, DateTime(2026, 5, 16)).isEnabled, isFalse);

    for (final date in <DateTime>[
      DateTime(2026, 5, 11),
      DateTime(2026, 5, 12),
      DateTime(2026, 5, 14),
      DateTime(2026, 5, 15),
      DateTime(2026, 5, 16),
    ]) {
      await tester.tap(_dayFinder(date), warnIfMissed: false);
    }
    await tester.longPress(
      _dayFinder(DateTime(2026, 5, 14)),
      warnIfMissed: false,
    );
    await tester.longPress(_dayFinder(DateTime(2026, 5, 15)));
    await tester.pump();

    expect(selectedDates, <DateTime>[
      DateTime(2026, 5, 12),
      DateTime(2026, 5, 15),
    ]);
    expect(longPressedDates, <DateTime>[DateTime(2026, 5, 15)]);
  });

  testWidgets('selected style remains above resolver and disabled styles', (
    tester,
  ) async {
    final selected = DateTime(2026, 5, 13);
    var resolverCalls = 0;
    await tester.pumpWidget(
      _host(
        _calendar(
          selectedDate: selected,
          focusedDate: selected,
          eventsForDate: (date) =>
              date == selected ? <String>['event'] : const <String>[],
          isDateEnabled: (date) => date != selected,
          dayStyleResolver: (context, day) {
            if (day.date == selected) resolverCalls++;
            return const CalendarDayStyle(backgroundColor: Colors.red);
          },
          theme: const CalendarCarouselThemeData(
            day: CalendarDayStyle(backgroundColor: Colors.black),
            withEvents: CalendarDayStyle(backgroundColor: Colors.orange),
            disabled: CalendarDayStyle(backgroundColor: Colors.purple),
            selected: CalendarDayStyle(backgroundColor: Colors.green),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final details = _details(tester, selected);
    expect(details.isEnabled, isFalse);
    expect(details.style.backgroundColor, Colors.green);
    expect(resolverCalls, 1);
  });

  testWidgets('named builders share one immutable rendered event snapshot', (
    tester,
  ) async {
    final target = DateTime(2026, 5, 13);
    var eventCalls = 0;
    var dayCalls = 0;
    var markerCalls = 0;
    List<String>? renderedEvents;
    List<String>? pressedEvents;

    await tester.pumpWidget(
      _host(
        _calendar(
          selectedDate: target,
          focusedDate: target,
          eventsForDate: (date) {
            if (date != target) return const <String>[];
            eventCalls++;
            return <String>['release'];
          },
          dayBuilder: (context, day) {
            if (day.date != target) return null;
            dayCalls++;
            renderedEvents = day.events;
            return const Center(child: Text('custom day'));
          },
          markerBuilder: (context, day) {
            if (day.date != target) return null;
            markerCalls++;
            return const Align(
              alignment: Alignment.bottomCenter,
              child: Text('custom marker'),
            );
          },
          onDateSelected: (date, events) {
            if (date == target) pressedEvents = events;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('custom day'), findsOneWidget);
    expect(find.text('custom marker'), findsOneWidget);
    expect(eventCalls, 1);
    expect(dayCalls, 1);
    expect(markerCalls, 1);
    expect(() => renderedEvents!.add('mutation'), throwsUnsupportedError);

    await tester.tap(_dayFinder(target));
    await tester.pump();
    expect(identical(renderedEvents, pressedEvents), isTrue);
    expect(eventCalls, 1);
  });

  testWidgets('ambient locale changes weekday order and preserves selection', (
    tester,
  ) async {
    var locale = const Locale('en', 'US');
    late StateSetter updateHost;
    final selected = DateTime(2026, 5, 13);
    final calendar = SizedBox(
      width: 420,
      height: 500,
      child: _calendar(
        selectedDate: selected,
        focusedDate: selected,
        locale: null,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              updateHost = setState;
              return Localizations.override(
                context: context,
                locale: locale,
                child: calendar,
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getCenter(find.text('Sun')).dx,
      lessThan(tester.getCenter(find.text('Mon')).dx),
    );

    updateHost(() => locale = const Locale('en', 'GB'));
    await tester.pumpAndSettle();
    expect(
      tester.getCenter(find.text('Mon')).dx,
      lessThan(tester.getCenter(find.text('Tue')).dx),
    );
    expect(_details(tester, selected).isSelected, isTrue);
  });

  testWidgets('ambient locale remaps the explicit focus date', (tester) async {
    var locale = const Locale('en', 'US');
    late StateSetter updateHost;
    final selected = DateTime(2026, 5, 31);
    final focused = DateTime(2026, 6, 6);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              updateHost = setState;
              return Localizations.override(
                context: context,
                locale: locale,
                child: SizedBox(
                  width: 420,
                  height: 220,
                  child: _calendar(
                    view: CalendarView.week,
                    selectedDate: selected,
                    focusedDate: focused,
                    locale: null,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(_details(tester, focused).pageAnchor, DateTime(2026, 5, 31));

    updateHost(() => locale = const Locale('en', 'GB'));
    await tester.pumpAndSettle();

    expect(_details(tester, focused).pageAnchor, DateTime(2026, 6));
    expect(_probeFinder(selected), findsNothing);
  });

  testWidgets('script locales retain their matching regional calendar data', (
    tester,
  ) async {
    final selected = DateTime(2026, 6, 3);

    await tester.pumpWidget(
      _host(
        _calendar(
          selectedDate: selected,
          focusedDate: selected,
          locale: const Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hant',
            countryCode: 'TW',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('週日'), findsOneWidget);
    expect(find.text('周日'), findsNothing);
    expect(
      tester.getCenter(find.text('週日')).dx,
      lessThan(tester.getCenter(find.text('週一')).dx),
    );
    expect(_details(tester, selected).isSelected, isTrue);
  });
}

Widget _host(Widget calendar, {double width = 420, double height = 500}) =>
    MaterialApp(
      home: Scaffold(
        body: SizedBox(width: width, height: height, child: calendar),
      ),
    );

CalendarCarousel<String> _calendar({
  CalendarView view = CalendarView.month,
  DateTime? selectedDate,
  DateTime? focusedDate,
  OnDateSelected<String>? onDateSelected,
  ValueChanged<DateTime>? onDateLongPressed,
  ValueChanged<DateTime>? onPageChanged,
  EventsForDate<String>? eventsForDate,
  bool Function(DateTime date)? isDateEnabled,
  DateTime? firstDate,
  DateTime? lastDate,
  Locale? locale = const Locale('en', 'US'),
  CalendarWeekday? firstDayOfWeek,
  CalendarDayBuilder<String>? dayBuilder,
  CalendarMarkerBuilder<String>? markerBuilder,
  CalendarDayStyleResolver<String>? dayStyleResolver,
  CalendarLayoutConfig layout = const CalendarLayoutConfig(),
  CalendarPagingConfig paging = const CalendarPagingConfig(),
  CalendarCarouselThemeData theme = const CalendarCarouselThemeData(),
}) => CalendarCarousel<String>(
  view: view,
  selectedDate: selectedDate,
  focusedDate: focusedDate,
  onDateSelected: onDateSelected,
  onDateLongPressed: onDateLongPressed,
  onPageChanged: onPageChanged,
  eventsForDate: eventsForDate,
  isDateEnabled: isDateEnabled,
  firstDate: firstDate ?? DateTime(2026),
  lastDate: lastDate ?? DateTime(2027, 12, 31),
  locale: locale,
  firstDayOfWeek: firstDayOfWeek,
  dayBuilder: dayBuilder ?? _buildProbe,
  markerBuilder: markerBuilder,
  dayStyleResolver: dayStyleResolver,
  layout: layout,
  paging: paging,
  theme: theme,
);

Widget _buildProbe(BuildContext context, CalendarDayDetails<String> day) =>
    _DayProbe(details: day);

class _DayProbe extends StatelessWidget {
  const _DayProbe({required this.details});

  final CalendarDayDetails<String> details;

  @override
  Widget build(BuildContext context) =>
      ExcludeSemantics(child: Center(child: Text('${details.date.day}')));
}

Finder _dayFinder(DateTime date) => find.byKey(ValueKey<DateTime>(date));

Finder _probeFinder(DateTime date) =>
    find.descendant(of: _dayFinder(date), matching: find.byType(_DayProbe));

CalendarDayDetails<String> _details(WidgetTester tester, DateTime date) =>
    tester.widget<_DayProbe>(_probeFinder(date)).details;

Finder _nextButton() => find.widgetWithIcon(IconButton, Icons.chevron_right);

Finder _previousButton() => find.widgetWithIcon(IconButton, Icons.chevron_left);

DateTime _startOfWeek(DateTime date, CalendarWeekday firstDay) {
  final sundayBasedWeekday = date.weekday % DateTime.daysPerWeek;
  final distance =
      (sundayBasedWeekday - firstDay.sundayBasedIndex + DateTime.daysPerWeek) %
      DateTime.daysPerWeek;
  return _addDays(date, -distance);
}

DateTime _addDays(DateTime date, int days) =>
    DateTime(date.year, date.month, date.day + days);
