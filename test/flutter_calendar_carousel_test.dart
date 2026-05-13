// This is a basic Flutter widget test.
// To perform an interaction with a widget in your test, use the WidgetTester utility that Flutter
// provides. For example, you can send tap and scroll gestures. You can also use WidgetTester to
// find child widgets in the widget tree, read text, and verify that the values of widget properties
// are correct.

import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_test/flutter_test.dart';

Type typeOf<T>() => T;

void main() {
  testWidgets('Default test for Calendar Carousel', (
    WidgetTester tester,
  ) async {
    DateTime? pressedDay;
    //  Build our app and trigger a frame.
    final carousel = CalendarCarousel(
      daysHaveCircularBorder: null,
      weekendTextStyle: TextStyle(color: Colors.red),
      thisMonthDayBorderColor: Colors.grey,
      headerText: 'Custom Header',
      weekFormat: true,
      height: 200,
      showIconBehindDayText: true,
      customGridViewPhysics: NeverScrollableScrollPhysics(),
      markedDateShowIcon: true,
      markedDateIconMaxShown: 2,
      selectedDayTextStyle: TextStyle(color: Colors.yellow),
      todayTextStyle: TextStyle(color: Colors.blue),
      markedDateIconBuilder: (Event event) {
        return event.icon ?? Icon(Icons.help_outline);
      },
      todayButtonColor: Colors.transparent,
      todayBorderColor: Colors.green,
      markedDateMoreShowTotal: true,
      // null for not showing hidden events indicator
      onDayPressed: (date, event) {
        pressedDay = date;
      },
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Container(child: carousel)),
      ),
    );

    expect(find.byWidget(carousel), findsOneWidget);
    expect(pressedDay, isNull);
  });

  testWidgets('make sure onDayPressed is called when the user tap', (
    WidgetTester tester,
  ) async {
    DateTime? pressedDay;

    final carousel = CalendarCarousel(
      weekFormat: true,
      height: 200,
      onDayPressed: (date, event) {
        pressedDay = date;
      },
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Container(child: carousel)),
      ),
    );

    expect(find.byWidget(carousel), findsOneWidget);

    expect(pressedDay, isNull);

    await tester.tap(
      find.text(DateTime.now().subtract(Duration(days: 1)).day.toString()),
    );

    await tester.pump();

    expect(pressedDay, isNotNull);
  });

  testWidgets(
    'should do nothing when the user tap and onDayPressed is not provided',
    (WidgetTester tester) async {
      final carousel = CalendarCarousel(weekFormat: true, height: 200);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: Container(child: carousel)),
        ),
      );

      expect(find.byWidget(carousel), findsOneWidget);

      await tester.tap(
        find.text(DateTime.now().subtract(Duration(days: 1)).day.toString()),
      );
      await tester.pump();
    },
  );

  testWidgets('inactiveDates block taps and use inactive style', (
    WidgetTester tester,
  ) async {
    DateTime? pressedDay;
    DateTime? longPressedDay;
    final selectedDay = DateTime(2026, 5, 13);
    final blockedDay = DateTime(2026, 5, 12, 23, 30);
    const inactiveStyle = TextStyle(color: Colors.purple);

    final carousel = CalendarCarousel(
      weekFormat: true,
      height: 200,
      selectedDateTime: selectedDay,
      targetDateTime: selectedDay,
      minSelectedDate: DateTime(2026, 5),
      maxSelectedDate: DateTime(2026, 5, 31, 23, 59),
      inactiveDates: [blockedDay],
      inactiveDaysTextStyle: inactiveStyle,
      inactiveWeekendTextStyle: inactiveStyle,
      onDayPressed: (date, event) {
        pressedDay = date;
      },
      onDayLongPressed: (date) {
        longPressedDay = date;
      },
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Container(child: carousel)),
      ),
    );

    final blockedFinder = find.text(blockedDay.day.toString());
    expect(blockedFinder, findsOneWidget);

    final blockedText = tester.widget<Text>(blockedFinder);
    expect(blockedText.style?.color, inactiveStyle.color);

    await tester.tap(blockedFinder);
    await tester.pump();

    expect(pressedDay, isNull);

    await tester.longPress(blockedFinder);
    await tester.pump();

    expect(longPressedDay, isNull);
  });

  testWidgets('minSelectedDate compares by calendar day', (
    WidgetTester tester,
  ) async {
    DateTime? pressedDay;
    final selectedDay = DateTime(2026, 5, 13);
    final minDay = DateTime(2026, 5, 12, 23, 59);

    final carousel = CalendarCarousel(
      weekFormat: true,
      height: 200,
      selectedDateTime: selectedDay,
      targetDateTime: selectedDay,
      minSelectedDate: minDay,
      maxSelectedDate: DateTime(2026, 5, 31),
      onDayPressed: (date, event) {
        pressedDay = date;
      },
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Container(child: carousel)),
      ),
    );

    await tester.tap(find.text('12'));
    await tester.pump();

    expect(pressedDay, isNotNull);
    expect(pressedDay?.day, 12);
  });

  testWidgets('updates minSelectedDate when widget changes', (
    WidgetTester tester,
  ) async {
    DateTime? pressedDay;
    final selectedDay = DateTime(2026, 5, 13);

    Widget buildCalendar(DateTime minSelectedDate) {
      return MaterialApp(
        home: Scaffold(
          body: CalendarCarousel(
            weekFormat: true,
            height: 200,
            selectedDateTime: selectedDay,
            targetDateTime: selectedDay,
            minSelectedDate: minSelectedDate,
            maxSelectedDate: DateTime(2026, 5, 31),
            onDayPressed: (date, event) {
              pressedDay = date;
            },
          ),
        ),
      );
    }

    await tester.pumpWidget(buildCalendar(DateTime(2026, 5, 12)));
    await tester.pumpWidget(buildCalendar(DateTime(2026, 5, 13)));

    await tester.tap(find.text('12'));
    await tester.pump();

    expect(pressedDay, isNull);
  });

  testWidgets(
    'make sure onDayLongPressed is called when the user press and hold',
    (WidgetTester tester) async {
      DateTime? longPressedDay;

      final carousel = CalendarCarousel(
        weekFormat: true,
        height: 200,
        onDayLongPressed: (date) {
          longPressedDay = date;
        },
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: Container(child: carousel)),
        ),
      );

      expect(find.byWidget(carousel), findsOneWidget);

      expect(longPressedDay, isNull);

      await tester.longPress(
        find.text(DateTime.now().subtract(Duration(days: 1)).day.toString()),
      );
      await tester.pump();

      expect(longPressedDay, isNotNull);
    },
  );

  testWidgets(
    'should do nothing when the user press and hold and onDayLongPressed is not provided',
    (WidgetTester tester) async {
      final carousel = CalendarCarousel(weekFormat: true, height: 200);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: Container(child: carousel)),
        ),
      );

      expect(find.byWidget(carousel), findsOneWidget);

      await tester.longPress(
        find.text(DateTime.now().subtract(Duration(days: 1)).day.toString()),
      );
      await tester.pump();
    },
  );
}
