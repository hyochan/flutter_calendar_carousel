import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_calendar_carousel/src/calendar_header.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const title = 'Test title';
  const margin = EdgeInsets.symmetric(vertical: 16);
  const iconColor = Colors.blueAccent;
  final pageAnchor = DateTime(2026, 5);

  testWidgets('default header exposes title and navigation actions', (
    tester,
  ) async {
    var titleTapped = false;
    var previousPressed = false;
    var nextPressed = false;

    await tester.pumpWidget(
      _wrapped(
        CalendarHeader(
          config: const CalendarHeaderConfig(margin: margin),
          details: CalendarHeaderDetails(
            pageAnchor: pageAnchor,
            label: title,
            view: CalendarView.month,
            style: const CalendarHeaderStyle(
              textStyle: TextStyle(fontSize: 18),
              iconColor: iconColor,
            ),
            onTitlePressed: () => titleTapped = true,
            onPrevious: () => previousPressed = true,
            onNext: () => nextPressed = true,
          ),
        ),
      ),
    );

    expect(find.text(title), findsOneWidget);
    expect(
      tester.widget<Container>(find.byType(Container).first).margin,
      margin,
    );

    await tester.tap(find.byType(TextButton));
    await tester.pump();
    expect(titleTapped, isTrue);

    await tester.tap(find.widgetWithIcon(IconButton, Icons.chevron_right));
    await tester.pump();
    expect(nextPressed, isTrue);

    await tester.tap(find.widgetWithIcon(IconButton, Icons.chevron_left));
    await tester.pump();
    expect(previousPressed, isTrue);
  });

  testWidgets('hidden header occupies no layout space', (tester) async {
    final header = CalendarHeader(
      config: const CalendarHeaderConfig(visible: false),
      details: CalendarHeaderDetails(
        pageAnchor: pageAnchor,
        label: title,
        view: CalendarView.month,
        style: const CalendarHeaderStyle(),
      ),
    );

    await tester.pumpWidget(_wrapped(header));

    expect(find.byWidget(header), findsOneWidget);
    expect(find.byType(Row), findsNothing);
    expect(find.byType(IconButton), findsNothing);
    final hiddenBox = tester.widget<SizedBox>(
      find.descendant(
        of: find.byWidget(header),
        matching: find.byType(SizedBox),
      ),
    );
    expect(hiddenBox.width, 0);
    expect(hiddenBox.height, 0);
  });

  testWidgets('title is non-interactive without a configured action', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrapped(
        CalendarHeader(
          config: const CalendarHeaderConfig(),
          details: CalendarHeaderDetails(
            pageAnchor: pageAnchor,
            label: title,
            view: CalendarView.week,
            style: const CalendarHeaderStyle(iconColor: iconColor),
            onPrevious: () {},
            onNext: () {},
          ),
        ),
      ),
    );

    expect(find.byType(TextButton), findsNothing);
  });

  testWidgets('navigation controls can be hidden as one configuration', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrapped(
        CalendarHeader(
          config: const CalendarHeaderConfig(showNavigationButtons: false),
          details: CalendarHeaderDetails(
            pageAnchor: pageAnchor,
            label: title,
            view: CalendarView.month,
            style: const CalendarHeaderStyle(),
            onPrevious: () {},
            onNext: () {},
          ),
        ),
      ),
    );

    expect(find.byType(IconButton), findsNothing);
    expect(find.text(title), findsOneWidget);
  });

  testWidgets('compact RTL header preserves every action without overflow', (
    tester,
  ) async {
    var titleTapped = false;
    var previousPressed = false;
    var nextPressed = false;
    await tester.pumpWidget(
      _wrapped(
        Center(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: SizedBox(
              width: 80,
              height: 48,
              child: CalendarHeader(
                config: const CalendarHeaderConfig(margin: EdgeInsets.zero),
                details: CalendarHeaderDetails(
                  pageAnchor: pageAnchor,
                  label: title,
                  view: CalendarView.month,
                  style: const CalendarHeaderStyle(iconColor: iconColor),
                  onTitlePressed: () => titleTapped = true,
                  onPrevious: () => previousPressed = true,
                  onNext: () => nextPressed = true,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text(title), findsOneWidget);
    final previous = find.widgetWithIcon(IconButton, Icons.chevron_left);
    final next = find.widgetWithIcon(IconButton, Icons.chevron_right);
    expect(tester.getSize(previous).width, greaterThanOrEqualTo(24));
    expect(tester.getSize(next).width, greaterThanOrEqualTo(24));
    expect(
      tester.getCenter(previous).dx,
      greaterThan(tester.getCenter(next).dx),
    );

    await tester.tap(previous);
    await tester.tap(find.byType(TextButton));
    await tester.tap(next);
    await tester.pump();

    expect(previousPressed, isTrue);
    expect(titleTapped, isTrue);
    expect(nextPressed, isTrue);
    expect(tester.takeException(), isNull);
  });
  testWidgets('custom header builder receives named state and actions', (
    tester,
  ) async {
    CalendarHeaderDetails? received;
    var nextPressed = false;

    await tester.pumpWidget(
      _wrapped(
        CalendarHeader(
          config: CalendarHeaderConfig(
            builder: (context, details) {
              received = details;
              return TextButton(
                key: const ValueKey<String>('custom-header'),
                onPressed: details.onNext,
                child: Text('${details.view.name}:${details.label}'),
              );
            },
          ),
          details: CalendarHeaderDetails(
            pageAnchor: pageAnchor,
            label: title,
            view: CalendarView.week,
            style: const CalendarHeaderStyle(),
            onNext: () => nextPressed = true,
          ),
        ),
      ),
    );

    expect(received?.pageAnchor, pageAnchor);
    expect(received?.view, CalendarView.week);
    expect(find.text('week:$title'), findsOneWidget);
    expect(find.byType(IconButton), findsNothing);

    await tester.tap(find.byKey(const ValueKey<String>('custom-header')));
    await tester.pump();
    expect(nextPressed, isTrue);
  });
}

Widget _wrapped(Widget widget) => MaterialApp(home: Material(child: widget));
