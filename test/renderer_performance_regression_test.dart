import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final targetDate = DateTime(2026, 5, 13);
  final events = List<_TestEvent>.unmodifiable(
    List<_TestEvent>.generate(1000, _TestEvent.new),
  );

  for (final view in CalendarView.values) {
    testWidgets('${view.name} keeps the default 200-year range lazy', (
      tester,
    ) async {
      var resolverCalls = 0;
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        _host(
          view: view,
          targetDate: DateTime.now(),
          eventsForDate: (_) {
            resolverCalls++;
            return const <_TestEvent>[];
          },
        ),
      );
      stopwatch.stop();

      final pageViewFinder = find.byType(PageView);
      expect(pageViewFinder, findsOneWidget);
      final pageView = tester.widget<PageView>(pageViewFinder);
      expect(
        pageView.childrenDelegate.estimatedChildCount,
        view == CalendarView.month ? greaterThan(2000) : greaterThan(10000),
      );
      expect(pageView.controller, isNotNull);
      expect(find.byType(GridView).evaluate().length, lessThanOrEqualTo(3));
      expect(find.byType(TextButton).evaluate().length, lessThanOrEqualTo(90));
      expect(resolverCalls, lessThan(100));
      expect(stopwatch.elapsed, lessThan(const Duration(seconds: 5)));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('default marker caps 1000 events and announces one count', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    const markerColor = Colors.teal;
    const selectedMarkerColor = Colors.white;
    const markerSize = 6.0;

    await tester.pumpWidget(
      _host(
        view: CalendarView.month,
        targetDate: targetDate,
        eventsForDate: (date) =>
            _sameDate(date, targetDate) ? events : const <_TestEvent>[],
        theme: const CalendarCarouselThemeData(
          marker: CalendarMarkerStyle(
            color: markerColor,
            selectedColor: selectedMarkerColor,
            maxVisible: 3,
            size: markerSize,
            spacing: 2,
            showOverflowCount: true,
          ),
        ),
      ),
    );

    final dots = _defaultDotsFor(
      targetDate,
      color: selectedMarkerColor,
      size: markerSize,
    );
    expect(dots, findsNWidgets(3));
    expect(find.text('+997'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('May 13, 2026[\\s\\S]*1000 events')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    semantics.dispose();
  });

  testWidgets('marker semantics can localize the default count label', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var labelBuilds = 0;
    await tester.pumpWidget(
      _host(
        view: CalendarView.month,
        targetDate: targetDate,
        eventsForDate: (date) =>
            _sameDate(date, targetDate) ? events : const <_TestEvent>[],
        theme: CalendarCarouselThemeData(
          marker: CalendarMarkerStyle(
            selectedColor: Colors.white,
            semanticLabelBuilder: (context, count) {
              labelBuilds++;
              return '$count appointments';
            },
          ),
        ),
      ),
    );

    expect(
      find.bySemanticsLabel(RegExp('May 13, 2026[\\s\\S]*1000 appointments')),
      findsOneWidget,
    );
    expect(labelBuilds, 1);
    semantics.dispose();
  });

  testWidgets('hidden default marker visuals retain the event count label', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(
        view: CalendarView.month,
        targetDate: targetDate,
        eventsForDate: (date) =>
            _sameDate(date, targetDate) ? events : const <_TestEvent>[],
        theme: const CalendarCarouselThemeData(
          marker: CalendarMarkerStyle(maxVisible: 0, showOverflowCount: false),
        ),
      ),
    );

    expect(
      find.bySemanticsLabel(RegExp('May 13, 2026[\\s\\S]*1000 events')),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('selected default markers use ambient on-primary contrast', (
    tester,
  ) async {
    final materialTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    );
    await tester.pumpWidget(
      _host(
        view: CalendarView.month,
        targetDate: targetDate,
        eventsForDate: (date) => _sameDate(date, targetDate)
            ? const <_TestEvent>[_TestEvent(1)]
            : const <_TestEvent>[],
        materialTheme: materialTheme,
      ),
    );

    expect(
      _defaultDotsFor(
        targetDate,
        color: materialTheme.colorScheme.onPrimary,
        size: 4,
      ),
      findsOneWidget,
    );
  });

  testWidgets('custom markerBuilder runs once for its visible event day', (
    tester,
  ) async {
    var markerBuilds = 0;
    CalendarDayDetails<_TestEvent>? received;

    await tester.pumpWidget(
      _host(
        view: CalendarView.month,
        targetDate: targetDate,
        eventsForDate: (date) =>
            _sameDate(date, targetDate) ? events : const <_TestEvent>[],
        markerBuilder: (context, day) {
          markerBuilds++;
          received = day;
          return const _CustomMarker();
        },
      ),
    );

    expect(markerBuilds, 1);
    expect(received?.date, targetDate);
    expect(received?.events, hasLength(1000));
    expect(find.byType(_CustomMarker), findsOneWidget);
  });

  testWidgets('a null custom marker hides markers without a fallback', (
    tester,
  ) async {
    var markerBuilds = 0;
    const markerColor = Colors.deepPurple;
    const markerSize = 7.0;

    await tester.pumpWidget(
      _host(
        view: CalendarView.month,
        targetDate: targetDate,
        eventsForDate: (date) =>
            _sameDate(date, targetDate) ? events : const <_TestEvent>[],
        markerBuilder: (context, day) {
          markerBuilds++;
          return null;
        },
        theme: const CalendarCarouselThemeData(
          marker: CalendarMarkerStyle(
            color: markerColor,
            maxVisible: 2,
            size: markerSize,
          ),
        ),
      ),
    );

    expect(markerBuilds, 1);
    expect(
      _defaultDotsFor(targetDate, color: markerColor, size: markerSize),
      findsNothing,
    );
    expect(find.text('+998'), findsNothing);
    expect(find.byType(_CustomMarker), findsNothing);
  });

  testWidgets(
    'events resolve once per built cell and taps reuse the snapshot',
    (tester) async {
      final firstDate = DateTime(2026, 5, 10);
      final lastDate = DateTime(2026, 5, 16);
      final callsByDate = <DateTime, int>{};
      List<_TestEvent>? pressedEvents;

      await tester.pumpWidget(
        _host(
          view: CalendarView.week,
          targetDate: targetDate,
          firstDate: firstDate,
          lastDate: lastDate,
          firstDayOfWeek: CalendarWeekday.sunday,
          eventsForDate: (date) {
            callsByDate.update(date, (count) => count + 1, ifAbsent: () => 1);
            return _sameDate(date, targetDate)
                ? const <_TestEvent>[_TestEvent(13)]
                : const <_TestEvent>[];
          },
          onDateSelected: (date, resolvedEvents) {
            pressedEvents = resolvedEvents;
          },
        ),
      );

      expect(callsByDate, hasLength(DateTime.daysPerWeek));
      expect(callsByDate.values, everyElement(1));
      final callsBeforeTap = callsByDate.values.fold<int>(0, (a, b) => a + b);

      await tester.tap(find.byKey(ValueKey<DateTime>(targetDate)));
      await tester.pump();

      expect(pressedEvents, const <_TestEvent>[_TestEvent(13)]);
      expect(callsByDate.values.fold<int>(0, (a, b) => a + b), callsBeforeTap);
    },
  );

  for (final view in CalendarView.values) {
    testWidgets('${view.name} page has no transform animation layer', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          view: view,
          targetDate: targetDate,
          eventsForDate: (_) => const <_TestEvent>[],
        ),
      );

      final pageView = find.byType(PageView);
      expect(pageView, findsOneWidget);
      final pageAnimatedBuilders = tester
          .widgetList<AnimatedBuilder>(
            find.descendant(
              of: pageView,
              matching: find.byType(AnimatedBuilder),
            ),
          )
          .where((builder) => builder.animation is PageController);
      expect(pageAnimatedBuilders, isEmpty);
      final pageScaleTransforms = tester
          .widgetList<Transform>(
            find.descendant(of: pageView, matching: find.byType(Transform)),
          )
          .where((transform) => transform.child is GridView);
      expect(pageScaleTransforms, isEmpty);
      expect(
        find.descendant(of: pageView, matching: find.byType(ScaleTransition)),
        findsNothing,
      );
      expect(
        find.descendant(of: pageView, matching: find.byType(SlideTransition)),
        findsNothing,
      );
    });
  }

  testWidgets('default markers stay in narrow month and week cells', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    const markerColor = Colors.orange;
    const markerSize = 5.0;

    for (final view in CalendarView.values) {
      for (final textScale in <double>[2, 3]) {
        await tester.pumpWidget(
          _host(
            view: view,
            targetDate: targetDate,
            eventsForDate: (date) =>
                _sameDate(date, targetDate) ? events : const <_TestEvent>[],
            width: 220,
            height: view == CalendarView.month ? 500 : 220,
            textScaler: TextScaler.linear(textScale),
            theme: const CalendarCarouselThemeData(
              marker: CalendarMarkerStyle(
                color: markerColor,
                selectedColor: markerColor,
                maxVisible: 3,
                size: markerSize,
                spacing: 2,
                showOverflowCount: true,
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        final dayRect = tester.getRect(
          find.byKey(ValueKey<DateTime>(targetDate)),
        );
        final overflowRect = tester.getRect(find.text('+997'));
        expect(dayRect.contains(overflowRect.topLeft), isTrue);
        expect(dayRect.contains(overflowRect.bottomRight), isTrue);

        final dots = _defaultDotsFor(
          targetDate,
          color: markerColor,
          size: markerSize,
        );
        expect(dots, findsNWidgets(3));
        for (var index = 0; index < 3; index++) {
          final dotRect = tester.getRect(dots.at(index));
          expect(dayRect.contains(dotRect.topLeft), isTrue);
          expect(dayRect.contains(dotRect.bottomRight), isTrue);
        }
        expect(
          find.bySemanticsLabel(RegExp('May 13, 2026[\\s\\S]*1000 events')),
          findsOneWidget,
        );
      }
    }

    semantics.dispose();
  });

  for (final view in CalendarView.values) {
    testWidgets('vertical drag pages the outer ${view.name} PageView', (
      tester,
    ) async {
      final changedDates = <DateTime>[];
      final expected = view == CalendarView.month
          ? DateTime(2026, 6)
          : DateTime(2026, 5, 18);

      await tester.pumpWidget(
        _host(
          view: view,
          targetDate: targetDate,
          firstDate: DateTime(2026, 1),
          lastDate: DateTime(2026, 12, 31),
          firstDayOfWeek: CalendarWeekday.monday,
          eventsForDate: (_) => const <_TestEvent>[],
          paging: const CalendarPagingConfig(axis: Axis.vertical),
          onPageChanged: changedDates.add,
        ),
      );
      await tester.pumpAndSettle();

      final pageViewFinder = find.byType(PageView);
      final pageView = tester.widget<PageView>(pageViewFinder);
      expect(pageView.scrollDirection, Axis.vertical);
      expect(
        tester
            .widgetList<GridView>(find.byType(GridView))
            .every((grid) => grid.physics is NeverScrollableScrollPhysics),
        isTrue,
      );

      await tester.fling(pageViewFinder, const Offset(0, -350), 1000);
      await tester.pumpAndSettle();

      expect(changedDates, <DateTime>[expected]);
    });
  }
}

Widget _host({
  required CalendarView view,
  required DateTime targetDate,
  required EventsForDate<_TestEvent> eventsForDate,
  DateTime? firstDate,
  DateTime? lastDate,
  CalendarWeekday firstDayOfWeek = CalendarWeekday.monday,
  OnDateSelected<_TestEvent>? onDateSelected,
  ValueChanged<DateTime>? onPageChanged,
  CalendarMarkerBuilder<_TestEvent>? markerBuilder,
  CalendarCarouselThemeData theme = const CalendarCarouselThemeData(),
  ThemeData? materialTheme,
  CalendarPagingConfig paging = const CalendarPagingConfig(enabled: false),
  double width = 420,
  double height = 420,
  TextScaler textScaler = TextScaler.noScaling,
}) => MaterialApp(
  locale: const Locale('en', 'US'),
  theme: materialTheme,
  home: MediaQuery(
    data: MediaQueryData(size: Size(width, height), textScaler: textScaler),
    child: Scaffold(
      body: SizedBox(
        width: width,
        height: height,
        child: CalendarCarousel<_TestEvent>(
          view: view,
          selectedDate: targetDate,
          focusedDate: targetDate,
          firstDate: firstDate,
          lastDate: lastDate,
          firstDayOfWeek: firstDayOfWeek,
          eventsForDate: eventsForDate,
          onDateSelected: onDateSelected,
          onPageChanged: onPageChanged,
          markerBuilder: markerBuilder,
          header: const CalendarHeaderConfig(visible: false),
          weekdays: const CalendarWeekdayConfig(visible: false),
          paging: paging,
          theme: theme,
        ),
      ),
    ),
  ),
);

Finder _defaultDotsFor(
  DateTime date, {
  required Color color,
  required double size,
}) => find.descendant(
  of: find.byKey(ValueKey<DateTime>(date)),
  matching: find.byWidgetPredicate((widget) {
    if (widget is! Container) return false;
    final decoration = widget.decoration;
    final constraints = widget.constraints;
    return decoration is BoxDecoration &&
        decoration.shape == BoxShape.circle &&
        decoration.color == color &&
        constraints?.minWidth == size &&
        constraints?.maxWidth == size &&
        constraints?.minHeight == size &&
        constraints?.maxHeight == size;
  }),
);

bool _sameDate(DateTime first, DateTime second) =>
    first.year == second.year &&
    first.month == second.month &&
    first.day == second.day;

@immutable
class _TestEvent {
  const _TestEvent(this.id);

  final int id;

  @override
  bool operator ==(Object other) => other is _TestEvent && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class _CustomMarker extends StatelessWidget {
  const _CustomMarker();

  @override
  Widget build(BuildContext context) => const Align(
    alignment: Alignment.bottomCenter,
    child: SizedBox.square(dimension: 8),
  );
}
