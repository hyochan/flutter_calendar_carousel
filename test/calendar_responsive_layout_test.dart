import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_calendar_carousel/src/calendar_header.dart';
import 'package:flutter_calendar_carousel/src/weekday_row.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final testCase in <({CalendarView view, double height})>[
    (view: CalendarView.month, height: 500),
    (view: CalendarView.week, height: 220),
  ]) {
    testWidgets('${testCase.view.name} view fits 220px with 2x text', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(220, 500),
              textScaler: TextScaler.linear(2),
            ),
            child: Scaffold(
              body: SizedBox(
                width: 220,
                height: testCase.height,
                child: CalendarCarousel<_ScheduleItem>(
                  view: testCase.view,
                  locale: const Locale('de', 'DE'),
                  focusedDate: DateTime(2026, 9, 15),
                  firstDate: DateTime(2026),
                  lastDate: DateTime(2026, 12, 31),
                  paging: const CalendarPagingConfig(enabled: false),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.textContaining('2026'), findsOneWidget);
    });
  }

  for (final view in CalendarView.values) {
    testWidgets('${view.name} view keeps RTL order and exact page anchors', (
      tester,
    ) async {
      final changedDates = <DateTime>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: SizedBox(
                width: 420,
                height: 420,
                child: CalendarCarousel<_ScheduleItem>(
                  view: view,
                  locale: const Locale('en', 'US'),
                  firstDayOfWeek: CalendarWeekday.sunday,
                  focusedDate: DateTime(2026, 5, 13),
                  firstDate: DateTime(2026, 1),
                  lastDate: DateTime(2026, 12, 31),
                  onPageChanged: changedDates.add,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getCenter(find.text('Sun')).dx,
        greaterThan(tester.getCenter(find.text('Sat')).dx),
      );
      expect(
        tester.getCenter(find.bySemanticsLabel('May 10, 2026')).dx,
        greaterThan(tester.getCenter(find.bySemanticsLabel('May 16, 2026')).dx),
      );
      expect(
        tester
            .getCenter(find.widgetWithIcon(IconButton, Icons.chevron_left))
            .dx,
        greaterThan(
          tester
              .getCenter(find.widgetWithIcon(IconButton, Icons.chevron_right))
              .dx,
        ),
      );

      await tester.tap(find.widgetWithIcon(IconButton, Icons.chevron_left));
      await tester.pumpAndSettle();

      expect(changedDates, <DateTime>[
        view == CalendarView.month ? DateTime(2026, 4) : DateTime(2026, 5, 3),
      ]);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('wide month layouts keep all six weeks inside the viewport', (
    tester,
  ) async {
    final selectedDate = DateTime(2026, 8, 10);
    final lastVisibleDate = DateTime(2026, 9, 5);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1280,
            height: 420,
            child: CalendarCarousel<_ScheduleItem>.month(
              selectedDate: selectedDate,
              focusedDate: selectedDate,
              firstDate: DateTime(2026),
              lastDate: DateTime(2026, 12, 31),
              layout: const CalendarLayoutConfig(fixedSixWeeks: true),
            ),
          ),
        ),
      ),
    );

    final gridRect = tester.getRect(find.byType(GridView));
    for (final date in <DateTime>[selectedDate, lastVisibleDate]) {
      final cellRect = tester.getRect(find.byKey(ValueKey<DateTime>(date)));
      expect(cellRect.top, greaterThanOrEqualTo(gridRect.top));
      expect(cellRect.bottom, lessThanOrEqualTo(gridRect.bottom + 0.01));
    }
    expect(
      find.bySemanticsLabel('August 10, 2026').hitTestable(),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  for (final view in CalendarView.values) {
    testWidgets('${view.name} preserves its day grid at 120px and 3x text', (
      tester,
    ) async {
      final target = DateTime(2026, 5, 13);
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(3)),
            child: Scaffold(
              body: SizedBox(
                width: 390,
                height: 120,
                child: CalendarCarousel<_ScheduleItem>(
                  view: view,
                  focusedDate: target,
                  firstDate: DateTime(2026, 1),
                  lastDate: DateTime(2026, 12, 31),
                  onDateSelected: (_, _) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      final day = find.byKey(ValueKey<DateTime>(target));
      expect(day, findsOneWidget);
      expect(day.hitTestable(), findsOneWidget);
      final rect = tester.getRect(day);
      expect(rect.top, greaterThanOrEqualTo(0));
      expect(rect.bottom, lessThanOrEqualTo(120));
    });
  }

  testWidgets('compact height prioritizes a usable six-week day grid', (
    tester,
  ) async {
    final target = DateTime(2026, 5, 13);
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(3)),
          child: Scaffold(
            body: SizedBox(
              width: 390,
              height: 160,
              child: CalendarCarousel<_ScheduleItem>.month(
                focusedDate: target,
                firstDate: DateTime(2026, 1),
                lastDate: DateTime(2026, 12, 31),
                layout: const CalendarLayoutConfig(fixedSixWeeks: true),
                onDateSelected: (_, _) {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final day = find.byKey(ValueKey<DateTime>(target));
    final button = find.descendant(of: day, matching: find.byType(TextButton));
    expect(tester.getSize(button).height, greaterThanOrEqualTo(24));
    expect(tester.getRect(button), tester.getRect(day));
    expect(find.byType(CalendarHeader), findsNothing);
    expect(find.byType(WeekdayRow), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('vertical page previews preserve the compact day-row budget', (
    tester,
  ) async {
    final target = DateTime(2026, 5, 13);
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(3)),
          child: Scaffold(
            body: SizedBox(
              width: 390,
              height: 240,
              child: CalendarCarousel<_ScheduleItem>.month(
                focusedDate: target,
                firstDate: DateTime(2026, 1),
                lastDate: DateTime(2026, 12, 31),
                layout: const CalendarLayoutConfig(fixedSixWeeks: true),
                paging: const CalendarPagingConfig(
                  axis: Axis.vertical,
                  viewportFraction: .8,
                ),
                onDateSelected: (_, _) {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final day = find.byKey(ValueKey<DateTime>(target));
    final button = find.descendant(of: day, matching: find.byType(TextButton));
    expect(tester.getSize(button).height, greaterThanOrEqualTo(24));
    expect(tester.getRect(button), tester.getRect(day));
    expect(tester.takeException(), isNull);
  });

  testWidgets('minimum adaptive header keeps navigation controls usable', (
    tester,
  ) async {
    final changed = <DateTime>[];
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(3)),
          child: Scaffold(
            body: SizedBox(
              width: 390,
              height: 240,
              child: CalendarCarousel<_ScheduleItem>.month(
                focusedDate: DateTime(2026, 5, 13),
                firstDate: DateTime(2026, 1),
                lastDate: DateTime(2026, 12, 31),
                layout: const CalendarLayoutConfig(fixedSixWeeks: true),
                onPageChanged: changed.add,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final next = find.widgetWithIcon(IconButton, Icons.chevron_right);
    expect(next.hitTestable(), findsOneWidget);
    await tester.tap(next);
    await tester.pumpAndSettle();
    expect(changed, <DateTime>[DateTime(2026, 6)]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('oversized custom chrome is bounded without starving days', (
    tester,
  ) async {
    final target = DateTime(2026, 5, 13);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 390,
            height: 300,
            child: CalendarCarousel<_ScheduleItem>.month(
              focusedDate: target,
              firstDate: DateTime(2026, 1),
              lastDate: DateTime(2026, 12, 31),
              layout: const CalendarLayoutConfig(fixedSixWeeks: true),
              header: CalendarHeaderConfig(
                builder: (context, details) => const SizedBox(
                  height: 500,
                  child: ColoredBox(color: Colors.blue),
                ),
              ),
              weekdays: CalendarWeekdayConfig(
                builder: (context, details) => const SizedBox(
                  height: 500,
                  child: ColoredBox(color: Colors.orange),
                ),
              ),
              onDateSelected: (_, _) {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final targetButton = find.descendant(
      of: find.byKey(ValueKey<DateTime>(target)),
      matching: find.byType(TextButton),
    );
    expect(tester.getSize(targetButton).height, greaterThanOrEqualTo(24));
    expect(find.byType(GridView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('peeked month pages suppress duplicate outside-day actions', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final selected = DateTime(2026, 5, 31);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 390,
            height: 500,
            child: CalendarCarousel<_ScheduleItem>.month(
              selectedDate: selected,
              focusedDate: selected,
              firstDate: DateTime(2026, 1),
              lastDate: DateTime(2026, 12, 31),
              firstDayOfWeek: CalendarWeekday.sunday,
              paging: const CalendarPagingConfig(viewportFraction: .8),
              onDateSelected: (_, _) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('May 31, 2026'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(ValueKey<DateTime>(selected)),
        matching: find.byType(TextButton),
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('dayPadding keeps the complete cell as the Android hit target', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final target = DateTime(2026, 5, 13);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 360,
            height: 640,
            child: CalendarCarousel<_ScheduleItem>.month(
              focusedDate: target,
              firstDate: DateTime(2026, 1),
              lastDate: DateTime(2026, 12, 31),
              layout: const CalendarLayoutConfig(fixedSixWeeks: true),
              onDateSelected: (_, _) {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final day = find.byKey(ValueKey<DateTime>(target));
    final button = find.descendant(of: day, matching: find.byType(TextButton));
    expect(tester.getRect(button), tester.getRect(day));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    semantics.dispose();
  });
}

class _ScheduleItem {}
