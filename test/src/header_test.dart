import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/src/calendar_header.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final title = 'Test title';
  final margin = const EdgeInsets.symmetric(vertical: 16);
  final iconColor = Colors.blueAccent;

  testWidgets('Verify Header Defaults', (WidgetTester tester) async {
    var headerTapped = false;
    var leftPressed = false;
    var rightPressed = false;

    await tester.pumpWidget(
      wrapped(
        CalendarHeader(
          headerTitle: title,
          headerMargin: margin,
          showHeader: true,
          showHeaderButtons: true,
          headerIconColor: iconColor,
          onHeaderTitlePressed: () => headerTapped = true,
          onRightButtonPressed: () => rightPressed = true,
          onLeftButtonPressed: () => leftPressed = true,
        ),
      ),
    );

    expect(find.text(title), findsOneWidget);

    await tester.tap(find.byType(TextButton));

    await tester.pump();

    expect(headerTapped, equals(true));

    await tester.tap(find.widgetWithIcon(IconButton, Icons.chevron_right));

    await tester.pump();

    expect(rightPressed, equals(true));

    await tester.tap(find.widgetWithIcon(IconButton, Icons.chevron_left));

    await tester.pump();

    expect(leftPressed, equals(true));
  });

  testWidgets('Verify No header Renders', (WidgetTester tester) async {
    final noHeaderEmpty = CalendarHeader(
      showHeader: false,
      headerTitle: '',
      onLeftButtonPressed: () {},
      onHeaderTitlePressed: () {},
      onRightButtonPressed: () {},
    );

    await tester.pumpWidget(Container(child: noHeaderEmpty));

    expect(find.byWidget(noHeaderEmpty), findsOneWidget);
  });

  testWidgets('Verify Header Is Not Touchable', (WidgetTester tester) async {
    await tester.pumpWidget(
      wrapped(
        CalendarHeader(
          headerTitle: title,
          headerMargin: margin,
          showHeader: true,
          showHeaderButtons: true,
          headerIconColor: iconColor,
          onHeaderTitlePressed: null,
          onRightButtonPressed: () {},
          onLeftButtonPressed: () {},
        ),
      ),
    );

    // the header TextButton Should not render
    final touchableHeader = find.byType(TextButton);

    expect(touchableHeader, findsNothing);
  });

  testWidgets('Verify No Header Buttons', (WidgetTester tester) async {
    await tester.pumpWidget(
      wrapped(
        CalendarHeader(
          headerTitle: title,
          headerMargin: margin,
          showHeader: true,
          showHeaderButtons: false,
          headerIconColor: iconColor,
          onHeaderTitlePressed: () {},
          onRightButtonPressed: () {},
          onLeftButtonPressed: () {},
        ),
      ),
    );

    // the header IconButtons Should not render
    final headerButton = find.byType(IconButton);

    expect(headerButton, findsNothing);
  });
}

// header uses Row which requires MaterialApp as an ancestor
Widget wrapped(Widget widget) => MaterialApp(home: Material(child: widget));
