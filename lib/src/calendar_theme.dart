import 'package:flutter/material.dart';

/// Builds an accessible label for a built-in event marker count.
typedef CalendarMarkerSemanticLabelBuilder =
    String Function(BuildContext context, int eventCount);

/// Visual styling for one calendar day.
@immutable
class CalendarDayStyle {
  /// Creates a partial day style.
  ///
  /// Null properties inherit from the lower-priority style.
  const CalendarDayStyle({
    this.textStyle,
    this.backgroundColor,
    this.shape,
    this.border,
    this.alignment,
  });

  /// Text style for the day number or default day content.
  final TextStyle? textStyle;

  /// Fill color of the day button.
  final Color? backgroundColor;

  /// Shape of the day button.
  final OutlinedBorder? shape;

  /// Border applied to [shape].
  final BorderSide? border;

  /// Alignment of the default day content within its cell.
  final AlignmentGeometry? alignment;

  /// Merges the non-null properties of [other] over this style.
  CalendarDayStyle merge(CalendarDayStyle? other) {
    if (other == null) return this;
    return CalendarDayStyle(
      textStyle: textStyle?.merge(other.textStyle) ?? other.textStyle,
      backgroundColor: other.backgroundColor ?? backgroundColor,
      shape: other.shape ?? shape,
      border: other.border ?? border,
      alignment: other.alignment ?? alignment,
    );
  }
}

/// Visual styling for the calendar header.
@immutable
class CalendarHeaderStyle {
  /// Creates a partial header style.
  const CalendarHeaderStyle({
    this.textStyle,
    this.iconColor,
    this.backgroundColor,
  });

  /// Text style of the visible page label.
  final TextStyle? textStyle;

  /// Color of the default previous and next icons.
  final Color? iconColor;

  /// Fill color behind the header row.
  final Color? backgroundColor;

  /// Merges the non-null properties of [other] over this style.
  CalendarHeaderStyle merge(CalendarHeaderStyle? other) {
    if (other == null) return this;
    return CalendarHeaderStyle(
      textStyle: textStyle?.merge(other.textStyle) ?? other.textStyle,
      iconColor: other.iconColor ?? iconColor,
      backgroundColor: other.backgroundColor ?? backgroundColor,
    );
  }
}

/// Visual styling for the weekday-label row.
@immutable
class CalendarWeekdayStyle {
  /// Creates a partial weekday-row style.
  const CalendarWeekdayStyle({this.textStyle, this.backgroundColor});

  /// Text style of localized weekday labels.
  final TextStyle? textStyle;

  /// Fill color behind the weekday row.
  final Color? backgroundColor;

  /// Merges the non-null properties of [other] over this style.
  CalendarWeekdayStyle merge(CalendarWeekdayStyle? other) {
    if (other == null) return this;
    return CalendarWeekdayStyle(
      textStyle: textStyle?.merge(other.textStyle) ?? other.textStyle,
      backgroundColor: other.backgroundColor ?? backgroundColor,
    );
  }
}

/// Styling and bounded rendering behavior for default event markers.
@immutable
class CalendarMarkerStyle {
  /// Creates styling for the built-in dot and overflow marker.
  const CalendarMarkerStyle({
    this.color,
    this.selectedColor,
    this.semanticLabelBuilder,
    int? maxVisible,
    double? size,
    double? spacing,
    bool? showOverflowCount,
  }) : assert(maxVisible == null || maxVisible >= 0),
       assert(size == null || (size >= 0 && size < double.infinity)),
       assert(spacing == null || (spacing >= 0 && spacing < double.infinity)),
       maxVisible = maxVisible ?? 3,
       size = size ?? 4,
       spacing = spacing ?? 2,
       showOverflowCount = showOverflowCount ?? true,
       _hasMaxVisible = maxVisible != null,
       _hasSize = size != null,
       _hasSpacing = spacing != null,
       _hasShowOverflowCount = showOverflowCount != null;

  /// Dot and default overflow-badge color.
  final Color? color;

  /// Dot and overflow-badge color while the event date is selected.
  ///
  /// The ambient theme defaults this to its on-primary color so markers stay
  /// visible over the default selected-day fill.
  final Color? selectedColor;

  /// Optional localized label for the merged event-count semantics.
  ///
  /// The built-in English fallback is `1 event` or `<count> events`.
  final CalendarMarkerSemanticLabelBuilder? semanticLabelBuilder;

  /// Maximum number of event dots built for one day.
  final int maxVisible;

  /// Diameter of each default event dot.
  final double size;

  /// Horizontal gap between default event dots.
  final double spacing;

  /// Whether a count is displayed when events exceed [maxVisible].
  final bool showOverflowCount;

  final bool _hasMaxVisible;
  final bool _hasSize;
  final bool _hasSpacing;
  final bool _hasShowOverflowCount;

  /// Merges explicitly supplied properties of [other] over this style.
  CalendarMarkerStyle merge(CalendarMarkerStyle? other) {
    if (other == null) return this;
    return CalendarMarkerStyle(
      color: other.color ?? color,
      selectedColor: other.selectedColor ?? selectedColor,
      semanticLabelBuilder: other.semanticLabelBuilder ?? semanticLabelBuilder,
      maxVisible: other._hasMaxVisible ? other.maxVisible : maxVisible,
      size: other._hasSize ? other.size : size,
      spacing: other._hasSpacing ? other.spacing : spacing,
      showOverflowCount: other._hasShowOverflowCount
          ? other.showOverflowCount
          : showOverflowCount,
    );
  }
}

/// Theme-aware visual configuration for a calendar.
@immutable
class CalendarCarouselThemeData {
  /// Creates a collection of partial styles.
  ///
  /// Call [resolve] inside a build method to fill unspecified properties from
  /// the ambient Material theme.
  const CalendarCarouselThemeData({
    this.day = const CalendarDayStyle(),
    this.outsideMonth = const CalendarDayStyle(),
    this.weekend = const CalendarDayStyle(),
    this.withEvents = const CalendarDayStyle(),
    this.today = const CalendarDayStyle(),
    this.disabled = const CalendarDayStyle(),
    this.selected = const CalendarDayStyle(),
    this.header = const CalendarHeaderStyle(),
    this.weekday = const CalendarWeekdayStyle(),
    this.marker = const CalendarMarkerStyle(),
  });

  /// Base style shared by every day.
  final CalendarDayStyle day;

  /// Override for dates outside the page's anchor month.
  final CalendarDayStyle outsideMonth;

  /// Override for locale-defined weekend dates.
  final CalendarDayStyle weekend;

  /// Override for dates whose event list is non-empty.
  final CalendarDayStyle withEvents;

  /// Override for today's date.
  final CalendarDayStyle today;

  /// Override for disabled dates.
  final CalendarDayStyle disabled;

  /// Highest-priority override for the selected date.
  final CalendarDayStyle selected;

  /// Header style.
  final CalendarHeaderStyle header;

  /// Weekday-row style.
  final CalendarWeekdayStyle weekday;

  /// Built-in event-marker style and render limits.
  final CalendarMarkerStyle marker;

  /// Resolves unspecified colors and typography from Flutter's ambient theme.
  CalendarCarouselThemeData resolve(BuildContext context) {
    final material = Theme.of(context);
    final colors = material.colorScheme;
    final bodyStyle = material.textTheme.bodyMedium ?? const TextStyle();
    final fallback = CalendarCarouselThemeData(
      day: CalendarDayStyle(
        textStyle: bodyStyle.copyWith(color: colors.onSurface),
        backgroundColor: Colors.transparent,
        shape: const CircleBorder(),
        border: const BorderSide(color: Colors.transparent),
        alignment: Alignment.center,
      ),
      outsideMonth: CalendarDayStyle(
        textStyle: bodyStyle.copyWith(color: colors.onSurfaceVariant),
      ),
      weekend: CalendarDayStyle(
        textStyle: bodyStyle.copyWith(color: colors.tertiary),
      ),
      withEvents: const CalendarDayStyle(),
      today: CalendarDayStyle(
        textStyle: bodyStyle.copyWith(color: colors.onSecondaryContainer),
        backgroundColor: colors.secondaryContainer,
        border: BorderSide(color: colors.secondary),
      ),
      disabled: CalendarDayStyle(
        textStyle: bodyStyle.copyWith(
          color: colors.onSurface.withValues(alpha: 0.38),
        ),
      ),
      selected: CalendarDayStyle(
        textStyle: bodyStyle.copyWith(color: colors.onPrimary),
        backgroundColor: colors.primary,
        border: BorderSide(color: colors.primary),
      ),
      header: CalendarHeaderStyle(
        textStyle: material.textTheme.titleMedium,
        iconColor: colors.primary,
        backgroundColor: Colors.transparent,
      ),
      weekday: CalendarWeekdayStyle(
        textStyle: material.textTheme.labelMedium?.copyWith(
          color: colors.onSurfaceVariant,
        ),
        backgroundColor: Colors.transparent,
      ),
      marker: CalendarMarkerStyle(
        color: colors.primary,
        selectedColor: colors.onPrimary,
      ),
    );
    return fallback.merge(this);
  }

  /// Merges [other] over this theme.
  CalendarCarouselThemeData merge(CalendarCarouselThemeData? other) {
    if (other == null) return this;
    return CalendarCarouselThemeData(
      day: day.merge(other.day),
      outsideMonth: outsideMonth.merge(other.outsideMonth),
      weekend: weekend.merge(other.weekend),
      withEvents: withEvents.merge(other.withEvents),
      today: today.merge(other.today),
      disabled: disabled.merge(other.disabled),
      selected: selected.merge(other.selected),
      header: header.merge(other.header),
      weekday: weekday.merge(other.weekday),
      marker: marker.merge(other.marker),
    );
  }

  /// Resolves the deterministic visual priority for one day.
  CalendarDayStyle resolveDayStyle({
    required bool isOutsideMonth,
    required bool isWeekend,
    required bool hasEvents,
    required bool isToday,
    required bool isEnabled,
    required bool isSelected,
    CalendarDayStyle? dateStyle,
  }) {
    var result = day;
    if (isWeekend) result = result.merge(weekend);
    if (isOutsideMonth) result = result.merge(outsideMonth);
    if (hasEvents) result = result.merge(withEvents);
    result = result.merge(dateStyle);
    if (isToday) result = result.merge(today);
    if (!isEnabled) result = result.merge(disabled);
    if (isSelected) result = result.merge(selected);
    return result;
  }
}
