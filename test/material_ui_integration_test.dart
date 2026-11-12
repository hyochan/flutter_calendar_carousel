import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets(
    'resolves localizations and the date picker from material_ui delegates',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ko'),
          supportedLocales: const <Locale>[Locale('en'), Locale('ko')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: Scaffold(
            body: SizedBox(
              height: 420,
              child: CalendarCarousel<String>.month(
                focusedDate: DateTime(2026, 5, 13),
                firstDate: DateTime(2026),
                lastDate: DateTime(2026, 12, 31),
                header: const CalendarHeaderConfig(enableDatePicker: true),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final localizations = MaterialLocalizations.of(
        tester.element(find.byType(CalendarCarousel<String>)),
      );
      expect(localizations.previousPageTooltip, isNot('Previous page'));
      expect(find.byTooltip(localizations.previousPageTooltip), findsOneWidget);
      expect(find.byTooltip(localizations.nextPageTooltip), findsOneWidget);

      await tester.tap(
        find.text(DateFormat.yMMM('ko').format(DateTime(2026, 5))),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DatePickerDialog), findsOneWidget);
      expect(find.text(localizations.datePickerHelpText), findsOneWidget);
    },
  );
}
