import 'package:flutter/material.dart';

@immutable
class Event implements EventInterface {
  final DateTime date;
  final String? title;
  final String? description;
  final String? location;
  final Widget? icon;
  final Widget? dot;
  final int? id;

  const Event({
    this.id,
    required this.date,
    this.title,
    this.description,
    this.location,
    this.icon,
    this.dot,
  });

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Event &&
        date == other.date &&
        title == other.title &&
        description == other.description &&
        location == other.location &&
        icon == other.icon &&
        dot == other.dot &&
        id == other.id;
  }

  @override
  int get hashCode => Object.hash(date, description, location, title, icon, id);

  @override
  DateTime getDate() {
    return date;
  }

  @override
  int? getId() {
    return id;
  }

  @override
  Widget? getDot() {
    return dot;
  }

  @override
  Widget? getIcon() {
    return icon;
  }

  @override
  String? getTitle() {
    return title;
  }

  @override
  String? getDescription() {
    return description;
  }

  @override
  String? getLocation() {
    return location;
  }
}

abstract class EventInterface {
  DateTime getDate();
  String? getTitle();
  String? getDescription();
  String? getLocation();
  Widget? getIcon();
  Widget? getDot();
  int? getId();
}
