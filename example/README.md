# flutter_calendar_carousel example

This Material 3 app demonstrates the 3.0 API as a real package consumer:
controlled month/week views, an application-owned event model, date-only event
indexing, custom markers, theme/config objects, date-picker navigation, and
large-text responsive behavior.

## Run

```shell
flutter pub get
flutter run
```

```shell
flutter test
```

The app uses a path dependency on the parent package, so local library changes
are picked up automatically.

## Minimal calendar

The public entrypoint contains the calendar and all view, configuration, theme,
and builder types:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';

class CalendarPreview extends StatefulWidget {
  const CalendarPreview({super.key});

  @override
  State<CalendarPreview> createState() => _CalendarPreviewState();
}

class _CalendarPreviewState extends State<CalendarPreview> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 420,
    child: CalendarCarousel<String>.month(
      selectedDate: selectedDate,
      focusedDate: selectedDate,
      onDateSelected: (DateTime date, List<String> events) {
        setState(() => selectedDate = date);
      },
    ),
  );
}
```

Use `.week(...)` for a seven-day page, or pass a controlled `view` to the
default constructor when the layout changes at runtime.

## Demo architecture

- `DemoEvent` belongs to the example app, not the calendar package.
- `Map<DateTime, List<DemoEvent>>` uses civil year/month/day keys. These are
  normally local midnight, but timezone transitions can normalize midnight to
  the first representable local time or require a UTC carrier for a completely
  skipped date.
- `eventsForDate` performs a constant-time map lookup.
- `selectedDate` and `focusedDate` are updated by the parent widget.
- `CalendarHeaderConfig`, `CalendarWeekdayConfig`, `CalendarLayoutConfig`,
  `CalendarPagingConfig`, and `CalendarCarouselThemeData` keep related options
  together.
- The custom `markerBuilder` is called once per visible date with events during
  a build, limits its own work to three dots, announces a meaningful event
  count, and switches to the selected-day foreground color for contrast.

## Production notes

- Give the calendar a finite height through its parent constraints.
- Pass `Localizations.localeOf(context)` when locale should be explicit;
  otherwise the calendar follows the surrounding app automatically.
- Treat callback values as civil year/month/day carriers, not timestamps; do
  not depend on their hour, UTC offset, or `isUtc` value.
- Keep `eventsForDate`, style resolvers, and builders pure and inexpensive.
- Return only visual content from day and marker builders. The calendar already
  owns each date's semantics and adds button actions when callbacks are present.
- Localize marker-count semantics in production apps; the package's built-in
  marker uses a concise English fallback.
- Test at narrow widths, RTL direction, and large accessibility text scales.

See the [package README](../README.md) for the full API guide and the complete
2.x-to-3.0 migration table.
