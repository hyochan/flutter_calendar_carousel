import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/marked_date.dart';

class MultipleMarkedDates {
  List<MarkedDate> markedDates;

  MultipleMarkedDates({required this.markedDates});

  void add(MarkedDate markedDate) {
    markedDates.add(markedDate);
  }

  void addRange(MarkedDate markedDate, {int plus = 0, int minus = 0}) {
    add(markedDate);

    if (plus > 0) {
      int start = 1;
      MarkedDate newAddMarkedDate;

      while (start <= plus) {
        newAddMarkedDate = MarkedDate(
          color: markedDate.color,
          date: markedDate.date.add(Duration(days: start)),
          textStyle: markedDate.textStyle,
        );

        add(newAddMarkedDate);

        start += 1;
      }
    }

    if (minus > 0) {
      int start = 1;
      MarkedDate newSubMarkedDate;

      while (start <= minus) {
        newSubMarkedDate = MarkedDate(
          color: markedDate.color,
          date: markedDate.date.subtract(Duration(days: start)),
          textStyle: markedDate.textStyle,
        );

        add(newSubMarkedDate);

        start += 1;
      }
    }
  }

  void addAll(List<MarkedDate> markedDates) {
    this.markedDates.addAll(markedDates);
  }

  bool remove(MarkedDate markedDate) {
    return markedDates.remove(markedDate);
  }

  void clear() {
    markedDates.clear();
  }

  bool isMarked(DateTime date) {
    final results = markedDates.firstWhere((element) => element.date == date,
        orElse: () => MarkedDate(color: Colors.black, date: DateTime(0)));
    return results.date.year == date.year;
  }

  Color getColor(DateTime date) {
    final results = markedDates.firstWhere((element) => element.date == date,
        orElse: () => MarkedDate(color: Colors.black, date: DateTime(0)));
    return results.color;
  }

  DateTime getDate(DateTime date) {
    final results = markedDates.firstWhere((element) => element.date == date,
        orElse: () => MarkedDate(color: Colors.black, date: DateTime(0)));
    return results.date;
  }

  TextStyle? getTextStyle(DateTime date) {
    final results = markedDates.firstWhere((element) => element.date == date,
        orElse: () => MarkedDate(color: Colors.black, date: DateTime(0)));
    return results.textStyle;
  }
}
