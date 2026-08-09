import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/src/calendar_config.dart';
import 'package:flutter_calendar_carousel/src/calendar_theme.dart';
import 'package:flutter_calendar_carousel/src/calendar_view.dart';
import 'package:intl/intl.dart';

/// Internal renderer for localized weekday labels.
class WeekdayRow extends StatelessWidget {
  const WeekdayRow({
    super.key,
    required this.firstDayOfWeek,
    required this.localeDate,
    required this.config,
    required this.style,
  });

  final int firstDayOfWeek;
  final DateFormat localeDate;
  final CalendarWeekdayConfig config;
  final CalendarWeekdayStyle style;

  @override
  Widget build(BuildContext context) {
    if (!config.visible) return const SizedBox.shrink();
    return Container(
      margin: config.margin,
      padding: config.padding,
      color: style.backgroundColor,
      child: Row(
        children: <Widget>[
          for (var position = 0; position < DateTime.daysPerWeek; position++)
            Expanded(child: _buildWeekday(context, position)),
        ],
      ),
    );
  }

  Widget _buildWeekday(BuildContext context, int position) {
    final weekdayIndex = (firstDayOfWeek + position) % DateTime.daysPerWeek;
    final weekday = CalendarWeekday.fromSundayBasedIndex(weekdayIndex);
    final originalLabel = _labelFor(weekdayIndex);
    final label = config.uppercase
        ? _localeAwareUppercase(originalLabel)
        : originalLabel;
    final details = CalendarWeekdayDetails(
      weekday: weekday,
      position: position,
      label: label,
      isWeekend: localeDate.dateSymbols.WEEKENDRANGE.contains(
        weekday.dartWeekday - DateTime.monday,
      ),
      style: style,
    );
    final customWeekday = config.builder?.call(context, details);
    if (customWeekday != null) return customWeekday;
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          semanticsLabel: originalLabel,
          style: style.textStyle,
          maxLines: 1,
          softWrap: false,
        ),
      ),
    );
  }

  String _labelFor(int weekday) => switch (config.format) {
    CalendarWeekdayFormat.full => localeDate.dateSymbols.WEEKDAYS[weekday],
    CalendarWeekdayFormat.standaloneFull =>
      localeDate.dateSymbols.STANDALONEWEEKDAYS[weekday],
    CalendarWeekdayFormat.short =>
      localeDate.dateSymbols.SHORTWEEKDAYS[weekday],
    CalendarWeekdayFormat.standaloneShort =>
      localeDate.dateSymbols.STANDALONESHORTWEEKDAYS[weekday],
    CalendarWeekdayFormat.narrow =>
      localeDate.dateSymbols.NARROWWEEKDAYS[weekday],
    CalendarWeekdayFormat.standaloneNarrow =>
      localeDate.dateSymbols.STANDALONENARROWWEEKDAYS[weekday],
  };

  String _localeAwareUppercase(String label) {
    final language = localeDate.locale.split(RegExp('[-_]')).first;
    if (language == 'tr' || language == 'az') {
      return label.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();
    }
    return label.toUpperCase();
  }
}
