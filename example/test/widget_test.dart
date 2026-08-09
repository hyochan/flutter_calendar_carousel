import 'package:flutter/material.dart';
import 'package:example/main.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('switches the demo between month and week views', (tester) async {
    final initialDate = DateTime(2026, 5, 13);
    await tester.pumpWidget(CalendarDemoApp(initialDate: initialDate));
    await tester.pumpAndSettle();

    expect(find.text('Calendar Carousel'), findsOneWidget);
    expect(_calendar(tester).view, CalendarView.month);
    expect(_calendar(tester).selectedDate, initialDate);
    expect(_calendar(tester).focusedDate, initialDate);

    await tester.tap(find.text('Week'));
    await tester.pumpAndSettle();

    expect(_calendar(tester).view, CalendarView.week);
    expect(_calendar(tester).selectedDate, initialDate);
    final localizations = MaterialLocalizations.of(
      tester.element(find.byType(CalendarDemoPage)),
    );
    final sundayBasedWeekday = initialDate.weekday % DateTime.daysPerWeek;
    final distance =
        (sundayBasedWeekday -
            localizations.firstDayOfWeekIndex +
            DateTime.daysPerWeek) %
        DateTime.daysPerWeek;
    final weekStart = DateTime(
      initialDate.year,
      initialDate.month,
      initialDate.day - distance,
    );
    final weekEnd = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day + 6,
    );
    expect(_calendar(tester).focusedDate, weekStart);
    expect(
      find.text(
        'Visible: ${localizations.formatShortDate(weekStart)} – '
        '${localizations.formatShortDate(weekEnd)}',
      ),
      findsOneWidget,
    );
    expect(find.text('Today'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('selects events, handles long press, Today, and paging', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 1000);
    addTearDown(tester.view.reset);

    final initialDate = DateTime(2026, 5, 13);
    await tester.pumpWidget(CalendarDemoApp(initialDate: initialDate));
    await tester.pumpAndSettle();

    expect(find.text('Team sync'), findsOneWidget);
    expect(find.text('Release'), findsNothing);

    await tester.tap(
      find.bySemanticsLabel(RegExp(r'^May 15, 2026[\s\S]*2 events$')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Release'), findsOneWidget);
    expect(find.text('Release notes'), findsOneWidget);
    expect(_calendar(tester).selectedDate, DateTime(2026, 5, 15));
    expect(_calendar(tester).focusedDate, DateTime(2026, 5, 15));

    await tester.longPress(find.bySemanticsLabel('May 14, 2026'));
    await tester.pump();
    expect(find.textContaining('Long pressed'), findsOneWidget);

    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();
    expect(find.text('Team sync'), findsOneWidget);
    expect(find.text('Release'), findsNothing);
    expect(_calendar(tester).selectedDate, initialDate);
    expect(_calendar(tester).focusedDate, initialDate);

    await tester.tap(find.widgetWithIcon(IconButton, Icons.chevron_right));
    await tester.pumpAndSettle();
    expect(find.text('Visible: June 2026'), findsOneWidget);
    expect(_calendar(tester).selectedDate, initialDate);
    expect(_calendar(tester).focusedDate, DateTime(2026, 6));
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps page controls usable on narrow screens with large text', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(220, 700);
    tester.platformDispatcher.textScaleFactorTestValue = 3;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      CalendarDemoApp(initialDate: DateTime(2026, 5, 13)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Visible: May 2026'), findsOneWidget);
    expect(find.byTooltip('Today'), findsOneWidget);
    expect(
      find.widgetWithIcon(IconButton, Icons.today_rounded),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Week'));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<SegmentedButton<CalendarView>>(
            find.byType(SegmentedButton<CalendarView>),
          )
          .selected,
      <CalendarView>{CalendarView.week},
    );
    expect(find.textContaining('Visible:'), findsOneWidget);
    final todayButton = find.widgetWithIcon(IconButton, Icons.today_rounded);
    final todayButtonRect = tester.getRect(todayButton);
    expect(todayButtonRect.top, greaterThanOrEqualTo(0));
    expect(todayButtonRect.bottom, lessThanOrEqualTo(700));
    await tester.tap(todayButton);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

CalendarCarousel<DemoEvent> _calendar(WidgetTester tester) =>
    tester.widget<CalendarCarousel<DemoEvent>>(
      find.byType(CalendarCarousel<DemoEvent>),
    );
