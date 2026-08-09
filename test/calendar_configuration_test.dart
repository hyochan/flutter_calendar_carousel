import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalendarWeekday', () {
    test('maps Sunday-based and Dart weekday values without ambiguity', () {
      expect(CalendarWeekday.sunday.sundayBasedIndex, 0);
      expect(CalendarWeekday.sunday.dartWeekday, DateTime.sunday);
      expect(CalendarWeekday.monday.sundayBasedIndex, 1);
      expect(CalendarWeekday.monday.dartWeekday, DateTime.monday);
      expect(CalendarWeekday.saturday.sundayBasedIndex, 6);
      expect(CalendarWeekday.saturday.dartWeekday, DateTime.saturday);

      for (var index = 0; index < DateTime.daysPerWeek; index++) {
        expect(
          CalendarWeekday.fromSundayBasedIndex(index).sundayBasedIndex,
          index,
        );
      }
      expect(
        () => CalendarWeekday.fromSundayBasedIndex(DateTime.daysPerWeek),
        throwsRangeError,
      );
    });
  });

  group('configuration defaults', () {
    test('keep the primary API small and predictable', () {
      const header = CalendarHeaderConfig();
      const weekdays = CalendarWeekdayConfig();
      const layout = CalendarLayoutConfig();
      const paging = CalendarPagingConfig();

      expect(header.visible, isTrue);
      expect(header.showNavigationButtons, isTrue);
      expect(header.enableDatePicker, isFalse);
      expect(weekdays.format, CalendarWeekdayFormat.short);
      expect(layout.showOutsideDays, isTrue);
      expect(layout.fixedSixWeeks, isFalse);
      expect(paging.enabled, isTrue);
      expect(paging.axis, Axis.horizontal);
      expect(paging.viewportFraction, 1);
    });

    test('rejects non-finite and negative layout or marker dimensions', () {
      for (final invalid in <double>[
        double.nan,
        double.infinity,
        double.negativeInfinity,
      ]) {
        expect(
          () => CalendarLayoutConfig(dayAspectRatio: invalid),
          throwsAssertionError,
        );
        expect(
          () => CalendarLayoutConfig(dayPadding: invalid),
          throwsAssertionError,
        );
        expect(() => CalendarMarkerStyle(size: invalid), throwsAssertionError);
        expect(
          () => CalendarMarkerStyle(spacing: invalid),
          throwsAssertionError,
        );
      }
      expect(
        () => CalendarLayoutConfig(dayAspectRatio: -1),
        throwsAssertionError,
      );
      expect(() => CalendarLayoutConfig(dayPadding: -1), throwsAssertionError);
      expect(() => CalendarMarkerStyle(size: -1), throwsAssertionError);
      expect(() => CalendarMarkerStyle(spacing: -1), throwsAssertionError);
    });
  });

  group('CalendarCarouselThemeData', () {
    test('merges partial styles and keeps selected state highest priority', () {
      const theme = CalendarCarouselThemeData(
        day: CalendarDayStyle(
          textStyle: TextStyle(color: Colors.black, fontSize: 14),
          backgroundColor: Colors.white,
        ),
        weekend: CalendarDayStyle(textStyle: TextStyle(color: Colors.purple)),
        withEvents: CalendarDayStyle(backgroundColor: Colors.amber),
        today: CalendarDayStyle(backgroundColor: Colors.blue),
        disabled: CalendarDayStyle(textStyle: TextStyle(color: Colors.grey)),
        selected: CalendarDayStyle(
          textStyle: TextStyle(color: Colors.white),
          backgroundColor: Colors.red,
        ),
      );

      final resolved = theme.resolveDayStyle(
        isOutsideMonth: false,
        isWeekend: true,
        hasEvents: true,
        isToday: true,
        isEnabled: false,
        isSelected: true,
        dateStyle: const CalendarDayStyle(
          textStyle: TextStyle(fontWeight: FontWeight.bold),
          backgroundColor: Colors.green,
        ),
      );

      expect(resolved.textStyle?.fontSize, 14);
      expect(resolved.textStyle?.fontWeight, FontWeight.bold);
      expect(resolved.textStyle?.color, Colors.white);
      expect(resolved.backgroundColor, Colors.red);
    });

    testWidgets('resolves defaults from the ambient Material theme', (
      WidgetTester tester,
    ) async {
      late CalendarCarouselThemeData resolved;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.teal,
              brightness: Brightness.dark,
            ),
          ),
          home: Builder(
            builder: (context) {
              resolved = const CalendarCarouselThemeData().resolve(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(resolved.day.textStyle, isNotNull);
      expect(resolved.selected.backgroundColor, isNotNull);
      expect(resolved.header.textStyle, isNotNull);
      expect(resolved.marker.color, isNotNull);
    });

    for (final brightness in Brightness.values) {
      testWidgets(
        'active outside-month text stays distinct and readable in ${brightness.name}',
        (tester) async {
          late CalendarCarouselThemeData resolved;
          late ColorScheme colors;
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.teal,
                  brightness: brightness,
                ),
              ),
              home: Builder(
                builder: (context) {
                  colors = Theme.of(context).colorScheme;
                  resolved = const CalendarCarouselThemeData().resolve(context);
                  return const SizedBox();
                },
              ),
            ),
          );

          final outside = resolved.outsideMonth.textStyle!.color!;
          final disabled = resolved.disabled.textStyle!.color!;
          expect(outside, isNot(disabled));
          expect(
            _contrastRatio(outside, colors.surface),
            greaterThanOrEqualTo(4.5),
          );
        },
      );
    }
  });

  test('CalendarDayDetails exposes one unambiguous month position', () {
    final details = CalendarDayDetails<String>(
      date: DateTime(2026, 5, 31),
      events: const <String>['release'],
      isEnabled: true,
      isSelected: false,
      isToday: false,
      isWeekend: true,
      monthPosition: CalendarMonthPosition.previous,
      pageAnchor: DateTime(2026, 6),
      style: const CalendarDayStyle(),
    );

    expect(details.isOutsideMonth, isTrue);
    expect(details.events, const <String>['release']);
  });
}

double _contrastRatio(Color foreground, Color background) {
  final paintedForeground = Color.alphaBlend(foreground, background);
  final foregroundLuminance = paintedForeground.computeLuminance();
  final backgroundLuminance = background.computeLuminance();
  final lighter = foregroundLuminance > backgroundLuminance
      ? foregroundLuminance
      : backgroundLuminance;
  final darker = foregroundLuminance > backgroundLuminance
      ? backgroundLuminance
      : foregroundLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}
