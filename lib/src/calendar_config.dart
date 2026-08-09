import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/src/calendar_view.dart';

/// Header visibility, interaction, and layout configuration.
@immutable
class CalendarHeaderConfig {
  /// Creates header configuration.
  const CalendarHeaderConfig({
    this.visible = true,
    this.showNavigationButtons = true,
    this.enableDatePicker = false,
    this.margin = const EdgeInsets.symmetric(vertical: 16),
    this.previousIcon,
    this.nextIcon,
    this.builder,
  });

  /// Whether the complete header row is visible.
  final bool visible;

  /// Whether the default previous and next controls are visible.
  final bool showNavigationButtons;

  /// Whether tapping the default title opens the date picker.
  final bool enableDatePicker;

  /// Space surrounding the header row.
  final EdgeInsetsGeometry margin;

  /// Optional replacement for the previous-page icon.
  final Widget? previousIcon;

  /// Optional replacement for the next-page icon.
  final Widget? nextIcon;

  /// Optional builder that replaces the complete default header.
  final CalendarHeaderBuilder? builder;
}

/// Weekday-label visibility, formatting, and layout configuration.
@immutable
class CalendarWeekdayConfig {
  /// Creates weekday-row configuration.
  const CalendarWeekdayConfig({
    this.visible = true,
    this.uppercase = false,
    this.format = CalendarWeekdayFormat.short,
    this.builder,
    this.margin = const EdgeInsets.only(bottom: 4),
    this.padding = EdgeInsets.zero,
  });

  /// Whether the localized weekday row is visible.
  final bool visible;

  /// Whether localized labels are converted to locale-aware uppercase.
  final bool uppercase;

  /// Width and context of localized weekday names.
  final CalendarWeekdayFormat format;

  /// Optional builder for each weekday label.
  final CalendarWeekdayBuilder? builder;

  /// Space surrounding the complete weekday row.
  final EdgeInsetsGeometry margin;

  /// Space inside the complete weekday row.
  final EdgeInsetsGeometry padding;
}

/// Month-grid and day-cell layout configuration.
@immutable
class CalendarLayoutConfig {
  /// Creates month-grid and day-cell layout configuration.
  const CalendarLayoutConfig({
    this.fixedSixWeeks = false,
    this.showOutsideDays = true,
    this.dayAspectRatio = 1,
    this.dayPadding = 2,
  }) : assert(dayAspectRatio > 0 && dayAspectRatio < double.infinity),
       assert(dayPadding >= 0 && dayPadding < double.infinity);

  /// Whether every month page contains exactly six week rows.
  final bool fixedSixWeeks;

  /// Whether leading and trailing dates from adjacent months are visible.
  ///
  /// Month pages suppress these dates when
  /// [CalendarPagingConfig.viewportFraction] is below one, preventing the same
  /// civil date from appearing twice across a visible page and its preview.
  final bool showOutsideDays;

  /// Preferred width divided by height for every day cell.
  ///
  /// The calendar raises this value when necessary to keep every row inside
  /// the available height, preventing wide layouts from clipping later weeks.
  final double dayAspectRatio;

  /// Visual inset for the day shape, content, and markers.
  ///
  /// The accessible hit target continues to occupy the complete grid cell.
  final double dayPadding;
}

/// Page-view interaction and viewport configuration.
@immutable
class CalendarPagingConfig {
  /// Creates page-view interaction and viewport configuration.
  const CalendarPagingConfig({
    this.enabled = true,
    this.axis = Axis.horizontal,
    this.physics = const PageScrollPhysics(),
    this.viewportFraction = 1,
  }) : assert(viewportFraction > 0 && viewportFraction <= 1);

  /// Whether drag gestures can change the visible page.
  final bool enabled;

  /// Axis along which pages move.
  final Axis axis;

  /// Physics used by the calendar page view.
  final ScrollPhysics physics;

  /// Fraction of the viewport occupied by each page.
  final double viewportFraction;
}
