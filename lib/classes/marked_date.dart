import 'package:flutter/material.dart';

@immutable
class MarkedDate implements MarkedDateInterface {
  final Color color;
  final int? id;
  final TextStyle? textStyle;
  final DateTime date;

  const MarkedDate({
    required this.color,
    this.id,
    this.textStyle,
    required this.date,
  });

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MarkedDate &&
        date == other.date &&
        color == other.color &&
        textStyle == other.textStyle &&
        id == other.id;
  }

  @override
  DateTime getDate() => date;

  @override
  int? getId() => id;

  @override
  Color getColor() => color;

  @override
  TextStyle? getTextStyle() => textStyle;

  @override
  // ignore: unnecessary_overrides, TODO: implement hashCode
  int get hashCode => super.hashCode;
}

abstract class MarkedDateInterface {
  DateTime getDate();
  Color getColor();
  int? getId();
  TextStyle? getTextStyle();
}
