import 'dart:ui' show SemanticsAction, Tristate;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('month and week constructors expose predictable paging defaults', () {
    final month = CalendarCarousel<_Meeting>.month();
    final week = CalendarCarousel<_Meeting>.week();

    expect(month.view, CalendarView.month);
    expect(week.view, CalendarView.week);
    expect(month.paging.enabled, isTrue);
    expect(week.paging.enabled, isTrue);
    expect(month.paging.axis, Axis.horizontal);
    expect(week.paging.viewportFraction, 1);
  });

  testWidgets('uses an app-local event model without an adapter', (
    tester,
  ) async {
    final eventDate = DateTime(2026, 5, 15);
    const meeting = _Meeting('Planning');
    List<_Meeting>? pressedEvents;

    await tester.pumpWidget(
      _testApp(
        CalendarCarousel<_Meeting>.month(
          focusedDate: eventDate,
          firstDate: DateTime(2026, 5),
          lastDate: DateTime(2026, 5, 31),
          paging: const CalendarPagingConfig(enabled: false),
          eventsForDate: (date) => _sameDate(date, eventDate)
              ? const <_Meeting>[meeting]
              : const <_Meeting>[],
          dayBuilder: (context, day) => day.events.isEmpty
              ? null
              : Center(child: Text(day.events.single.title)),
          onDateSelected: (date, events) => pressedEvents = events,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Planning'), findsOneWidget);

    await tester.tap(find.text('Planning'));
    await tester.pump();

    expect(pressedEvents, const <_Meeting>[meeting]);
    expect(
      () => pressedEvents!.add(const _Meeting('Mutation')),
      throwsUnsupportedError,
    );
  });

  testWidgets('selectedDate remains controlled until the parent updates it', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final selectedDate = DateTime(2026, 5, 13);
    final pressedDate = DateTime(2026, 5, 12);
    DateTime? reportedDate;

    await tester.pumpWidget(
      _testApp(
        CalendarCarousel<_Meeting>.week(
          selectedDate: selectedDate,
          focusedDate: selectedDate,
          firstDate: DateTime(2026, 5),
          lastDate: DateTime(2026, 5, 31),
          paging: const CalendarPagingConfig(enabled: false),
          onDateSelected: (date, events) => reportedDate = date,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.bySemanticsLabel('May 12, 2026'));
    await tester.pump();

    expect(reportedDate, pressedDate);
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('May 13, 2026'))
          .getSemanticsData()
          .flagsCollection
          .isSelected,
      Tristate.isTrue,
    );
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('May 12, 2026'))
          .getSemanticsData()
          .flagsCollection
          .isSelected,
      Tristate.isFalse,
    );

    semantics.dispose();
  });

  testWidgets('custom day semantics merge into one actionable date node', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final targetDate = DateTime(2026, 5, 13);

    await tester.pumpWidget(
      _testApp(
        CalendarCarousel<_Meeting>.month(
          selectedDate: targetDate,
          focusedDate: targetDate,
          firstDate: DateTime(2026, 5),
          lastDate: DateTime(2026, 5, 31),
          paging: const CalendarPagingConfig(enabled: false),
          onDateSelected: (_, _) {},
          onDateLongPressed: (_) {},
          dayBuilder: (context, day) => day.date == targetDate
              ? Semantics(label: 'custom appointment', child: const Text('13'))
              : null,
        ),
      ),
    );
    await tester.pump();

    final dayButton = find.bySemanticsLabel(
      RegExp('May 13, 2026[\\s\\S]*custom appointment'),
    );
    expect(dayButton, findsOneWidget);
    final buttonNode = tester.getSemantics(dayButton);
    expect(buttonNode.label, contains('May 13, 2026'));
    expect(buttonNode.label, contains('custom appointment'));
    expect(
      buttonNode.getSemanticsData().flagsCollection.isSelected,
      Tristate.isTrue,
    );
    expect(
      buttonNode.getSemanticsData().hasAction(SemanticsAction.tap),
      isTrue,
    );
    expect(
      buttonNode.getSemanticsData().hasAction(SemanticsAction.longPress),
      isTrue,
    );

    semantics.dispose();
  });

  testWidgets('default day semantics announce the full date only once', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final targetDate = DateTime(2026, 5, 13);

    await tester.pumpWidget(
      _testApp(
        CalendarCarousel<_Meeting>.month(
          selectedDate: targetDate,
          focusedDate: targetDate,
          firstDate: DateTime(2026, 5),
          lastDate: DateTime(2026, 5, 31),
          paging: const CalendarPagingConfig(enabled: false),
          onDateSelected: (_, _) {},
        ),
      ),
    );
    await tester.pump();

    final dayButton = find.bySemanticsLabel('May 13, 2026');
    expect(dayButton, findsOneWidget);
    final node = tester.getSemantics(dayButton);
    expect(node.label, 'May 13, 2026');
    expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);

    semantics.dispose();
  });

  testWidgets('read-only dates are labels rather than disabled buttons', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final targetDate = DateTime(2026, 5, 13);

    await tester.pumpWidget(
      _testApp(
        CalendarCarousel<_Meeting>.month(
          selectedDate: targetDate,
          focusedDate: targetDate,
          firstDate: DateTime(2026, 5),
          lastDate: DateTime(2026, 5, 31),
          paging: const CalendarPagingConfig(enabled: false),
        ),
      ),
    );
    await tester.pump();

    final dateNode = tester.getSemantics(find.bySemanticsLabel('May 13, 2026'));
    final data = dateNode.getSemanticsData();
    expect(data.flagsCollection.isButton, isFalse);
    expect(data.flagsCollection.isEnabled, Tristate.none);
    expect(data.hasAction(SemanticsAction.tap), isFalse);
    expect(data.hasAction(SemanticsAction.longPress), isFalse);
    expect(data.flagsCollection.isSelected, Tristate.isTrue);

    semantics.dispose();
  });

  testWidgets('date picker follows a supported calendar locale', (
    tester,
  ) async {
    final targetDate = DateTime(2026, 5, 13);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en', 'US'),
        supportedLocales: const <Locale>[
          Locale('en', 'US'),
          Locale('en', 'GB'),
        ],
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          _TestEnglishMaterialLocalizationsDelegate(),
        ],
        home: Scaffold(
          body: SizedBox(
            height: 420,
            child: CalendarCarousel<_Meeting>.month(
              locale: const Locale('en', 'GB'),
              focusedDate: targetDate,
              firstDate: DateTime(2026, 5),
              lastDate: DateTime(2026, 5, 31),
              header: const CalendarHeaderConfig(enableDatePicker: true),
              paging: const CalendarPagingConfig(enabled: false),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('May 2026'));
    await tester.pumpAndSettle();

    final picker = find.byType(DatePickerDialog);
    expect(picker, findsOneWidget);
    expect(
      Localizations.localeOf(tester.element(picker)),
      const Locale('en', 'GB'),
    );
    expect(
      MaterialLocalizations.of(tester.element(picker)).firstDayOfWeekIndex,
      DateTime.monday,
    );
  });

  testWidgets('date picker falls back when locale delegates are unavailable', (
    tester,
  ) async {
    final targetDate = DateTime(2026, 5, 13);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 420,
            child: CalendarCarousel<_Meeting>.month(
              locale: const Locale('ko', 'KR'),
              focusedDate: targetDate,
              firstDate: DateTime(2026, 5),
              lastDate: DateTime(2026, 5, 31),
              header: const CalendarHeaderConfig(enableDatePicker: true),
              paging: const CalendarPagingConfig(enabled: false),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('2026년 5월'));
    await tester.pumpAndSettle();

    final picker = find.byType(DatePickerDialog);
    expect(picker, findsOneWidget);
    expect(
      Localizations.localeOf(tester.element(picker)),
      const Locale('en', 'US'),
    );
  });

  testWidgets('unsupported intl locales fall back without breaking the view', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        CalendarCarousel<_Meeting>.month(
          locale: const Locale('zz', 'ZZ'),
          focusedDate: DateTime(2026, 5, 13),
          firstDate: DateTime(2026, 5),
          lastDate: DateTime(2026, 5, 31),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('May 2026'), findsOneWidget);
    expect(find.byType(PageView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('picker starts enabled and jumps directly to a far result', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final blockedDate = DateTime(2026, 5, 31);
    var selectedDate = blockedDate;
    final pressedDates = <DateTime>[];
    final changedDates = <DateTime>[];
    late StateSetter updateHost;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 420,
            child: StatefulBuilder(
              builder: (context, setState) {
                updateHost = setState;
                return CalendarCarousel<_Meeting>.month(
                  locale: const Locale('en', 'US'),
                  selectedDate: selectedDate,
                  focusedDate: blockedDate,
                  firstDate: DateTime(2024),
                  lastDate: DateTime(2026, 6, 30),
                  isDateEnabled: (date) => date != blockedDate,
                  header: const CalendarHeaderConfig(enableDatePicker: true),
                  paging: const CalendarPagingConfig(enabled: false),
                  onDateSelected: (date, events) {
                    pressedDates.add(date);
                    updateHost(() => selectedDate = date);
                  },
                  onPageChanged: changedDates.add,
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('May 2026'));
    await tester.pumpAndSettle();

    final picker = find.byType(DatePickerDialog);
    expect(
      find.descendant(of: picker, matching: find.text('June 2026')),
      findsOneWidget,
    );

    await tester.tap(
      find.descendant(of: picker, matching: find.text('June 2026')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: picker, matching: find.text('2024')));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: picker, matching: find.text('13')));
    await tester.pump();
    await tester.tap(find.descendant(of: picker, matching: find.text('OK')));
    await tester.pumpAndSettle();

    expect(pressedDates, <DateTime>[DateTime(2024, 6, 13)]);
    expect(changedDates, <DateTime>[DateTime(2024, 6)]);
    expect(find.text('Jun 2024'), findsOneWidget);
    final selectedNode = tester.getSemantics(
      find.bySemanticsLabel('June 13, 2024'),
    );
    expect(
      selectedNode.getSemanticsData().flagsCollection.isSelected,
      Tristate.isTrue,
    );

    semantics.dispose();
  });

  testWidgets('picker searches backward when no later date is enabled', (
    tester,
  ) async {
    final blockedDate = DateTime(2026, 5, 31);
    await tester.pumpWidget(
      _testApp(
        CalendarCarousel<_Meeting>.month(
          selectedDate: blockedDate,
          focusedDate: blockedDate,
          firstDate: DateTime(2026, 5),
          lastDate: blockedDate,
          isDateEnabled: (date) => date != blockedDate,
          header: const CalendarHeaderConfig(enableDatePicker: true),
          paging: const CalendarPagingConfig(enabled: false),
        ),
      ),
    );

    await tester.tap(find.text('May 2026'));
    await tester.pumpAndSettle();

    final picker = tester.widget<CalendarDatePicker>(
      find.byType(CalendarDatePicker),
    );
    expect(picker.initialDate, DateTime(2026, 5, 30));
  });

  testWidgets('picker stays closed when the complete range is disabled', (
    tester,
  ) async {
    var predicateCalls = 0;
    await tester.pumpWidget(
      _testApp(
        CalendarCarousel<_Meeting>.month(
          focusedDate: DateTime(2026, 5, 13),
          firstDate: DateTime(1926, 5, 13),
          lastDate: DateTime(2126, 5, 13),
          isDateEnabled: (_) {
            predicateCalls++;
            return false;
          },
          header: const CalendarHeaderConfig(enableDatePicker: true),
          paging: const CalendarPagingConfig(enabled: false),
        ),
      ),
    );

    await tester.tap(find.text('May 2026'));
    expect(predicateCalls, lessThan(5000));
    await tester.tap(find.text('May 2026'));
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerDialog), findsNothing);
    expect(predicateCalls, greaterThan(70000));
    expect(predicateCalls, lessThan(80000));
    expect(tester.takeException(), isNull);
  });
}

Widget _testApp(Widget child) => MaterialApp(
  locale: const Locale('en', 'US'),
  home: Scaffold(body: SizedBox(height: 420, child: child)),
);

bool _sameDate(DateTime first, DateTime second) =>
    first.year == second.year &&
    first.month == second.month &&
    first.day == second.day;

@immutable
class _Meeting {
  const _Meeting(this.title);

  final String title;
}

class _TestEnglishMaterialLocalizations extends DefaultMaterialLocalizations {
  const _TestEnglishMaterialLocalizations({required this.firstDay});

  final int firstDay;

  @override
  int get firstDayOfWeekIndex => firstDay;
}

class _TestEnglishMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _TestEnglishMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'en';

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      SynchronousFuture<MaterialLocalizations>(
        _TestEnglishMaterialLocalizations(
          firstDay: locale.countryCode == 'GB'
              ? DateTime.monday
              : DateTime.sunday,
        ),
      );

  @override
  bool shouldReload(_TestEnglishMaterialLocalizationsDelegate old) => false;
}
