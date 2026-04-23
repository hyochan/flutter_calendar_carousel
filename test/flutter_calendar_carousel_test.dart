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
