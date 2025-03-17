import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show WeekdayFormat;
import 'package:flutter_calendar_carousel/src/weekday_row.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart' show DateFormat;

void main() {
  final locale = DateFormat.yMMM('en_US');
  final margin = const EdgeInsets.only(bottom: 4);

  testWidgets('test short weekday row', (WidgetTester tester) async {
    await tester.pumpWidget(wrapped(
      WeekdayRow(
        0,
        null,
        weekdayPadding: EdgeInsets.zero,
        weekdayBackgroundColor: Colors.transparent,
        showWeekdays: true,
        weekdayFormat: WeekdayFormat.short,
        weekdayMargin: margin,
        weekdayTextStyle: null,
        localeDate: locale,
      ),
    ));

    expect(find.text('Sun'), findsOneWidget);
    expect(find.text('Mon'), findsOneWidget);
    expect(find.text('Tue'), findsOneWidget);
    expect(find.text('Wed'), findsOneWidget);
    expect(find.text('Thu'), findsOneWidget);
    expect(find.text('Fri'), findsOneWidget);
    expect(find.text('Sat'), findsOneWidget);
  });

  testWidgets('test narrow weekday row', (WidgetTester tester) async {
    await tester.pumpWidget(wrapped(WeekdayRow(
      0,
      null,
      weekdayPadding: EdgeInsets.zero,
      weekdayBackgroundColor: Colors.transparent,
      showWeekdays: true,
      weekdayFormat: WeekdayFormat.standaloneNarrow,
      weekdayMargin: margin,
      weekdayTextStyle: null,
      localeDate: locale,
    )));

    // sat and sun
    expect(find.text('S'), findsNWidgets(2));
    // thurs and tues
    expect(find.text('T'), findsNWidgets(2));

    expect(find.text('M'), findsOneWidget);
    expect(find.text('W'), findsOneWidget);
    expect(find.text('F'), findsOneWidget);
  });

  testWidgets('test standalone weekday row', (WidgetTester tester) async {
    await tester.pumpWidget(wrapped(WeekdayRow(
      0,
      null,
      weekdayPadding: EdgeInsets.zero,
      weekdayBackgroundColor: Colors.transparent,
      showWeekdays: true,
      weekdayFormat: WeekdayFormat.standalone,
      weekdayMargin: margin,
      weekdayTextStyle: null,
      localeDate: locale,
    )));

    expect(find.text('Sunday'), findsOneWidget);
    expect(find.text('Monday'), findsOneWidget);
    expect(find.text('Tuesday'), findsOneWidget);
    expect(find.text('Wednesday'), findsOneWidget);
    expect(find.text('Thursday'), findsOneWidget);
    expect(find.text('Friday'), findsOneWidget);
    expect(find.text('Saturday'), findsOneWidget);
  });

  testWidgets('test standalone short weekday row', (WidgetTester tester) async {
    await tester.pumpWidget(wrapped(WeekdayRow(
      0,
      null,
      weekdayPadding: EdgeInsets.zero,
      weekdayBackgroundColor: Colors.transparent,
      showWeekdays: true,
      weekdayFormat: WeekdayFormat.standaloneShort,
      weekdayMargin: margin,
      weekdayTextStyle: null,
      localeDate: locale,
    )));

    expect(find.text('Sun'), findsOneWidget);
    expect(find.text('Mon'), findsOneWidget);
    expect(find.text('Tue'), findsOneWidget);
    expect(find.text('Wed'), findsOneWidget);
    expect(find.text('Thu'), findsOneWidget);
    expect(find.text('Fri'), findsOneWidget);
    expect(find.text('Sat'), findsOneWidget);
  });

  testWidgets('test row does not render', (WidgetTester tester) async {
    final emptyContainer = WeekdayRow(
      0,
      null,
      weekdayPadding: EdgeInsets.zero,
      weekdayBackgroundColor: Colors.transparent,
      showWeekdays: false,
      weekdayFormat: WeekdayFormat.standaloneNarrow,
      weekdayMargin: margin,
      weekdayTextStyle: null,
      localeDate: locale,
    );

    await tester.pumpWidget(emptyContainer);

    expect(find.byType(Container), findsOneWidget);

    expect(find.byType(Row), findsNothing);
  });
}

Widget wrapped(Widget widget) => Directionality(
      textDirection: TextDirection.ltr,
      child: widget,
    );
