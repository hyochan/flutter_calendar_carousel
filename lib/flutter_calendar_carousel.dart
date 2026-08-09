/// A lazy, accessible Flutter calendar with consistent month and week paging.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/src/calendar_config.dart';
import 'package:flutter_calendar_carousel/src/calendar_date_utils.dart';
import 'package:flutter_calendar_carousel/src/calendar_header.dart';
import 'package:flutter_calendar_carousel/src/calendar_pager.dart';
import 'package:flutter_calendar_carousel/src/calendar_theme.dart';
import 'package:flutter_calendar_carousel/src/calendar_view.dart';
import 'package:flutter_calendar_carousel/src/weekday_row.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' show DateFormat;

export 'package:flutter_calendar_carousel/src/calendar_config.dart';
export 'package:flutter_calendar_carousel/src/calendar_theme.dart';
export 'package:flutter_calendar_carousel/src/calendar_view.dart';

/// Resolves events for a civil year/month/day carrier.
///
/// The value uses local midnight when it exists. If a timezone transition
/// skips midnight, it uses Dart's first representable local time for that
/// date. If the complete civil day is unrepresentable, it uses UTC midnight.
///
/// Keep implementations synchronous, pure, and inexpensive. Non-empty results
/// are copied into the immutable snapshot shared by builders and selection.
typedef EventsForDate<T> = List<T> Function(DateTime date);

/// Reports a selected civil date and the exact events rendered for that cell.
typedef OnDateSelected<T> = void Function(DateTime date, List<T> events);

const double _minimumDayHitExtent = 24;
const double _weekdayChromeExtent = 24;
const double _minimumHeaderChromeExtent = 64;

/// A lazy, accessible month or week calendar for any application event type.
///
/// Place the calendar in a finite-height parent such as a [SizedBox].
class CalendarCarousel<T> extends StatefulWidget {
  /// Creates a calendar whose [view] defaults to [CalendarView.month].
  const CalendarCarousel({
    super.key,
    this.view = CalendarView.month,
    this.selectedDate,
    this.focusedDate,
    this.onDateSelected,
    this.onDateLongPressed,
    this.onPageChanged,
    this.eventsForDate,
    this.isDateEnabled,
    this.firstDate,
    this.lastDate,
    this.locale,
    this.firstDayOfWeek,
    this.dayBuilder,
    this.markerBuilder,
    this.dayStyleResolver,
    this.header = const CalendarHeaderConfig(),
    this.weekdays = const CalendarWeekdayConfig(),
    this.layout = const CalendarLayoutConfig(),
    this.paging = const CalendarPagingConfig(),
    this.theme = const CalendarCarouselThemeData(),
  });

  /// Creates a month calendar with the same options as [CalendarCarousel].
  const CalendarCarousel.month({
    Key? key,
    DateTime? selectedDate,
    DateTime? focusedDate,
    OnDateSelected<T>? onDateSelected,
    ValueChanged<DateTime>? onDateLongPressed,
    ValueChanged<DateTime>? onPageChanged,
    EventsForDate<T>? eventsForDate,
    bool Function(DateTime date)? isDateEnabled,
    DateTime? firstDate,
    DateTime? lastDate,
    Locale? locale,
    CalendarWeekday? firstDayOfWeek,
    CalendarDayBuilder<T>? dayBuilder,
    CalendarMarkerBuilder<T>? markerBuilder,
    CalendarDayStyleResolver<T>? dayStyleResolver,
    CalendarHeaderConfig header = const CalendarHeaderConfig(),
    CalendarWeekdayConfig weekdays = const CalendarWeekdayConfig(),
    CalendarLayoutConfig layout = const CalendarLayoutConfig(),
    CalendarPagingConfig paging = const CalendarPagingConfig(),
    CalendarCarouselThemeData theme = const CalendarCarouselThemeData(),
  }) : this(
         key: key,
         view: CalendarView.month,
         selectedDate: selectedDate,
         focusedDate: focusedDate,
         onDateSelected: onDateSelected,
         onDateLongPressed: onDateLongPressed,
         onPageChanged: onPageChanged,
         eventsForDate: eventsForDate,
         isDateEnabled: isDateEnabled,
         firstDate: firstDate,
         lastDate: lastDate,
         locale: locale,
         firstDayOfWeek: firstDayOfWeek,
         dayBuilder: dayBuilder,
         markerBuilder: markerBuilder,
         dayStyleResolver: dayStyleResolver,
         header: header,
         weekdays: weekdays,
         layout: layout,
         paging: paging,
         theme: theme,
       );

  /// Creates a seven-day week calendar with the same options as
  /// [CalendarCarousel].
  const CalendarCarousel.week({
    Key? key,
    DateTime? selectedDate,
    DateTime? focusedDate,
    OnDateSelected<T>? onDateSelected,
    ValueChanged<DateTime>? onDateLongPressed,
    ValueChanged<DateTime>? onPageChanged,
    EventsForDate<T>? eventsForDate,
    bool Function(DateTime date)? isDateEnabled,
    DateTime? firstDate,
    DateTime? lastDate,
    Locale? locale,
    CalendarWeekday? firstDayOfWeek,
    CalendarDayBuilder<T>? dayBuilder,
    CalendarMarkerBuilder<T>? markerBuilder,
    CalendarDayStyleResolver<T>? dayStyleResolver,
    CalendarHeaderConfig header = const CalendarHeaderConfig(),
    CalendarWeekdayConfig weekdays = const CalendarWeekdayConfig(),
    CalendarLayoutConfig layout = const CalendarLayoutConfig(),
    CalendarPagingConfig paging = const CalendarPagingConfig(),
    CalendarCarouselThemeData theme = const CalendarCarouselThemeData(),
  }) : this(
         key: key,
         view: CalendarView.week,
         selectedDate: selectedDate,
         focusedDate: focusedDate,
         onDateSelected: onDateSelected,
         onDateLongPressed: onDateLongPressed,
         onPageChanged: onPageChanged,
         eventsForDate: eventsForDate,
         isDateEnabled: isDateEnabled,
         firstDate: firstDate,
         lastDate: lastDate,
         locale: locale,
         firstDayOfWeek: firstDayOfWeek,
         dayBuilder: dayBuilder,
         markerBuilder: markerBuilder,
         dayStyleResolver: dayStyleResolver,
         header: header,
         weekdays: weekdays,
         layout: layout,
         paging: paging,
         theme: theme,
       );

  /// Page layout rendered by the calendar.
  final CalendarView view;

  /// Controlled selected date, or `null` when no date is selected.
  ///
  /// Update this value from [onDateSelected] to change the visible selection.
  final DateTime? selectedDate;

  /// Date whose month or week should be visible.
  ///
  /// A changed value navigates to its page and is clamped to the date range.
  final DateTime? focusedDate;

  /// Called for an enabled date with its rendered immutable event snapshot.
  final OnDateSelected<T>? onDateSelected;

  /// Called when an enabled date is long-pressed.
  final ValueChanged<DateTime>? onDateLongPressed;

  /// Reports the first date of each reached or requested month or week page.
  final ValueChanged<DateTime>? onPageChanged;

  /// Resolves events for visible dates.
  final EventsForDate<T>? eventsForDate;

  /// Additional predicate for dates inside [firstDate] and [lastDate].
  final bool Function(DateTime date)? isDateEnabled;

  /// Earliest enabled civil date; defaults to today minus 100 years.
  final DateTime? firstDate;

  /// Latest enabled civil date; defaults to today plus 100 years.
  final DateTime? lastDate;

  /// Locale for labels, weekdays, semantics, and the date picker.
  ///
  /// When `null`, the nearest ambient [Localizations] locale is used.
  final Locale? locale;

  /// First visible weekday, or `null` to derive it from [locale].
  final CalendarWeekday? firstDayOfWeek;

  /// Builds content for each rendered date, or returns `null` for the default.
  final CalendarDayBuilder<T>? dayBuilder;

  /// Builds the marker layer for an event date.
  ///
  /// Returning `null` intentionally hides that date's marker.
  final CalendarMarkerBuilder<T>? markerBuilder;

  /// Adds a date-specific style before today, disabled, and selected styles.
  final CalendarDayStyleResolver<T>? dayStyleResolver;

  /// Header visibility, navigation, picker, and custom-builder configuration.
  final CalendarHeaderConfig header;

  /// Weekday-label visibility, formatting, and builder configuration.
  final CalendarWeekdayConfig weekdays;

  /// Month-grid and day-cell layout configuration.
  final CalendarLayoutConfig layout;

  /// Page gesture, axis, physics, and viewport configuration.
  final CalendarPagingConfig paging;

  /// Calendar visuals merged with the ambient Material theme.
  final CalendarCarouselThemeData theme;

  @override
  State<CalendarCarousel<T>> createState() => _CalendarState<T>();
}

class _CalendarState<T> extends State<CalendarCarousel<T>> {
  late PageController _controller;
  late CalendarPager _pager;
  late DateTime _targetDate;
  late DateTime _minimumDate;
  late DateTime _maximumDate;
  late DateFormat _localeDate;
  late DateFormat _semanticDate;
  late Locale _effectiveLocale;
  late int _firstDayOfWeek;
  int _page = 0;
  int? _requestedPage;
  int _navigationRequest = 0;
  bool _pickerInProgress = false;
  final Set<DateTime> _reportedNavigationAnchors = <DateTime>{};

  @override
  void initState() {
    super.initState();
    _effectiveLocale =
        widget.locale ?? WidgetsBinding.instance.platformDispatcher.locale;
    _setLocale(_effectiveLocale);
    _setBounds();
    _configurePager(
      widget.focusedDate ?? widget.selectedDate ?? DateTime.now(),
    );
    _controller = _createPageController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = widget.locale ?? Localizations.localeOf(context);
    if (locale != _effectiveLocale) {
      _updateLocale(locale);
    }
  }

  @override
  void didUpdateWidget(CalendarCarousel<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldPager = _pager;
    final hadPendingRequest = _requestedPage != null;
    final hadActiveScroll =
        _controller.hasClients &&
        _controller.position.isScrollingNotifier.value;
    final oldPage = _requestedPage ?? _page;
    final oldAnchor = _targetDate;
    final oldFirstDayOfWeek = _firstDayOfWeek;
    final oldMinimumDate = _minimumDate;
    final oldMaximumDate = _maximumDate;

    final locale = widget.locale ?? Localizations.localeOf(context);
    if (locale != _effectiveLocale) {
      _setLocale(locale);
    } else {
      _firstDayOfWeek = _resolveFirstDayOfWeek();
    }
    _setBounds();

    final structureChanged =
        oldWidget.view != widget.view ||
        oldFirstDayOfWeek != _firstDayOfWeek ||
        oldMinimumDate != _minimumDate ||
        oldMaximumDate != _maximumDate;
    final axisChanged = oldWidget.paging.axis != widget.paging.axis;
    final viewportChanged =
        oldWidget.paging.viewportFraction != widget.paging.viewportFraction;
    final focusChanged = !_sameNullableDate(
      oldWidget.focusedDate,
      widget.focusedDate,
    );
    if (!structureChanged &&
        !axisChanged &&
        !viewportChanged &&
        !focusChanged) {
      return;
    }

    final DateTime requestedTarget;
    if (focusChanged && widget.focusedDate != null) {
      requestedTarget = widget.focusedDate!;
    } else if (_requestedPage != null) {
      requestedTarget = _focusDateForPage(oldPager, oldPage);
    } else if (structureChanged && widget.focusedDate != null) {
      requestedTarget = widget.focusedDate!;
    } else if (structureChanged &&
        widget.selectedDate != null &&
        _isDateOnPage(widget.selectedDate!, oldPager, oldPage)) {
      requestedTarget = widget.selectedDate!;
    } else if (structureChanged) {
      requestedTarget = _focusDateForPage(oldPager, oldPage);
    } else {
      requestedTarget = _targetDate;
    }

    _configurePager(requestedTarget);
    if (structureChanged ||
        axisChanged ||
        viewportChanged ||
        (focusChanged &&
            widget.focusedDate != null &&
            (hadPendingRequest || hadActiveScroll)) ||
        !isSameDate(oldAnchor, _targetDate)) {
      _replaceController();
      if (!isSameDate(oldAnchor, _targetDate)) {
        _notifyPageChangedUnlessReported(_targetDate);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateLocale(Locale locale) {
    final oldPager = _pager;
    final oldPage = _requestedPage ?? _page;
    final oldAnchor = _targetDate;
    final oldFirstDayOfWeek = _firstDayOfWeek;
    _setLocale(locale);
    if (oldFirstDayOfWeek == _firstDayOfWeek) return;

    final target = _requestedPage != null
        ? _focusDateForPage(oldPager, oldPage)
        : widget.focusedDate ??
              (widget.selectedDate != null &&
                      _isDateOnPage(widget.selectedDate!, oldPager, oldPage)
                  ? widget.selectedDate!
                  : _focusDateForPage(oldPager, oldPage));
    _configurePager(target);
    _replaceController();
    if (!isSameDate(oldAnchor, _targetDate)) {
      _notifyPageChangedUnlessReported(_targetDate);
    }
  }

  void _setLocale(Locale locale) {
    _effectiveLocale = locale;
    final requestedLocale = locale.toString();
    initializeDateFormatting(requestedLocale);
    final localeName = _resolveIntlLocale(locale);
    _localeDate = DateFormat.yMMM(localeName);
    _semanticDate = DateFormat.yMMMMd(localeName);
    _firstDayOfWeek = _resolveFirstDayOfWeek();
  }

  String _resolveIntlLocale(Locale locale) {
    final language = locale.languageCode;
    final country = locale.countryCode;
    final script = locale.scriptCode;
    final candidates = <String>[
      locale.toString(),
      if (country != null) '${language}_$country',
      if (script != null) '${language}_$script',
      language,
      'en_US',
    ];
    return candidates.firstWhere(DateFormat.localeExists);
  }

  int _resolveFirstDayOfWeek() =>
      widget.firstDayOfWeek?.sundayBasedIndex ??
      (_localeDate.dateSymbols.FIRSTDAYOFWEEK + 1) % DateTime.daysPerWeek;

  void _setBounds() {
    final today = DateTime.now();
    _minimumDate = dateOnly(
      widget.firstDate ?? DateTime(today.year - 100, today.month, today.day),
    );
    _maximumDate = dateOnly(
      widget.lastDate ?? DateTime(today.year + 100, today.month, today.day),
    );
    if (_minimumDate.isAfter(_maximumDate)) {
      throw ArgumentError.value(
        widget.firstDate,
        'firstDate',
        'must be on or before lastDate',
      );
    }
  }

  void _configurePager(DateTime target) {
    _pager = CalendarPager(
      view: widget.view,
      minimumDate: _minimumDate,
      maximumDate: _maximumDate,
      firstDayOfWeek: _firstDayOfWeek,
    );
    _page = _pager.pageFor(target);
    _targetDate = _pager.anchorForPage(_page);
  }

  PageController _createPageController() => PageController(
    initialPage: _page,
    keepPage: true,
    viewportFraction: widget.paging.viewportFraction,
  );

  void _replaceController() {
    final oldController = _controller;
    _navigationRequest++;
    _requestedPage = null;
    _controller = _createPageController();
    oldController.dispose();
    _clearReportedNavigationAnchorsAfterFrame();
  }

  bool _sameNullableDate(DateTime? first, DateTime? second) {
    if (first == null || second == null) return first == second;
    return isSameDate(first, second);
  }

  bool _isDateOnPage(DateTime date, CalendarPager pager, int page) {
    final normalizedDate = dateOnly(date);
    if (normalizedDate.isBefore(pager.minimumDate) ||
        normalizedDate.isAfter(pager.maximumDate)) {
      return false;
    }
    final anchor = pager.anchorForPage(page);
    if (pager.view == CalendarView.month) {
      return isSameMonth(normalizedDate, anchor);
    }
    final distance = calendarDaysBetween(anchor, normalizedDate);
    return distance >= 0 && distance < DateTime.daysPerWeek;
  }

  DateTime _focusDateForPage(CalendarPager pager, int page) {
    final anchor = pager.anchorForPage(page);
    return pager.view == CalendarView.week
        ? addCalendarDays(anchor, 3)
        : anchor;
  }

  @override
  Widget build(BuildContext context) {
    final resolvedTheme = widget.theme.resolve(context);
    final labelDate = widget.view == CalendarView.week
        ? addCalendarDays(_targetDate, 3)
        : _targetDate;
    final headerDetails = CalendarHeaderDetails(
      pageAnchor: _targetDate,
      label: _localeDate.format(labelDate),
      view: widget.view,
      style: resolvedTheme.header,
      onPrevious: _canMoveByPage(-1) ? () => _moveByPage(-1) : null,
      onNext: _canMoveByPage(1) ? () => _moveByPage(1) : null,
      onTitlePressed: widget.header.enableDatePicker
          ? _selectDateFromPicker
          : null,
    );

    final header = CalendarHeader(
      config: widget.header,
      details: headerDetails,
    );
    final weekdayRow = WeekdayRow(
      firstDayOfWeek: _firstDayOfWeek,
      localeDate: _localeDate,
      config: widget.weekdays,
      style: resolvedTheme.weekday,
    );
    final pages = PageView.builder(
      key: ValueKey<PageController>(_controller),
      itemCount: _pager.pageCount,
      physics: widget.paging.enabled
          ? widget.paging.physics
          : const NeverScrollableScrollPhysics(),
      scrollDirection: widget.paging.axis,
      onPageChanged: _handlePageChanged,
      controller: _controller,
      itemBuilder: (context, index) => widget.view == CalendarView.week
          ? _buildWeekPage(index, resolvedTheme)
          : _buildMonthPage(index, resolvedTheme),
      pageSnapping: true,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedHeight) {
          return Column(
            children: <Widget>[
              header,
              weekdayRow,
              Expanded(child: pages),
            ],
          );
        }

        final maximumHeight = math.max(0.0, constraints.maxHeight);
        final possibleRows = widget.view == CalendarView.week ? 1 : 6;
        final pageHeightFraction = widget.paging.axis == Axis.vertical
            ? widget.paging.viewportFraction
            : 1.0;
        final minimumPageViewportHeight = math.min(
          maximumHeight,
          possibleRows * _minimumDayHitExtent / pageHeightFraction,
        );
        var chromeBudget = maximumHeight - minimumPageViewportHeight;
        final showWeekdays =
            widget.weekdays.visible && chromeBudget >= _weekdayChromeExtent;
        if (showWeekdays) chromeBudget -= _weekdayChromeExtent;
        final showHeader =
            widget.header.visible && chromeBudget >= _minimumHeaderChromeExtent;

        return Column(
          children: <Widget>[
            if (showHeader)
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: chromeBudget),
                child: ClipRect(child: header),
              ),
            if (showWeekdays)
              SizedBox(
                height: _weekdayChromeExtent,
                child: ClipRect(child: weekdayRow),
              ),
            Expanded(child: pages),
          ],
        );
      },
    );
  }

  Widget _buildMonthPage(int page, CalendarCarouselThemeData theme) {
    final month = _pager.anchorForPage(page);
    final layout = CalendarMonthLayout(
      month: month,
      firstDayOfWeek: _firstDayOfWeek,
      forceSixWeeks: widget.layout.fixedSixWeeks,
    );
    return _buildDayGrid(
      itemCount: layout.itemCount,
      pageAnchor: month,
      dateAt: layout.dateAt,
      theme: theme,
    );
  }

  Widget _buildWeekPage(int page, CalendarCarouselThemeData theme) {
    final anchor = _pager.anchorForPage(page);
    final dates = _pager.datesForWeekPage(page);
    return _buildDayGrid(
      itemCount: dates.length,
      pageAnchor: anchor,
      dateAt: (index) => dates[index],
      theme: theme,
    );
  }

  Widget _buildDayGrid({
    required int itemCount,
    required DateTime pageAnchor,
    required DateTime Function(int index) dateAt,
    required CalendarCarouselThemeData theme,
  }) {
    final today = dateOnly(DateTime.now());
    return LayoutBuilder(
      builder: (context, constraints) {
        final rowCount = (itemCount / DateTime.daysPerWeek).ceil();
        final fitAspectRatio =
            constraints.hasBoundedWidth &&
                constraints.hasBoundedHeight &&
                constraints.maxHeight > 0
            ? (constraints.maxWidth / DateTime.daysPerWeek) /
                  (constraints.maxHeight / rowCount)
            : widget.layout.dayAspectRatio;
        final dayAspectRatio = math.max(
          widget.layout.dayAspectRatio,
          fitAspectRatio,
        );
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: DateTime.daysPerWeek,
            childAspectRatio: dayAspectRatio,
          ),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            final date = dateAt(index);
            final monthPosition = widget.view == CalendarView.week
                ? CalendarMonthPosition.current
                : _monthPosition(date, pageAnchor);
            if (widget.view == CalendarView.month &&
                (!widget.layout.showOutsideDays ||
                    widget.paging.viewportFraction < 1) &&
                monthPosition != CalendarMonthPosition.current) {
              return SizedBox.shrink(key: ValueKey<DateTime>(date));
            }

            final events = _eventsForDate(date);
            final isEnabled = _isEnabled(date);
            final isSelected =
                widget.selectedDate != null &&
                isSameDate(date, widget.selectedDate!);
            final isToday = isSameDate(date, today);
            final isWeekend = _localeDate.dateSymbols.WEEKENDRANGE.contains(
              cldrWeekday(date),
            );
            var preStateStyle = theme.day;
            if (isWeekend) preStateStyle = preStateStyle.merge(theme.weekend);
            if (monthPosition != CalendarMonthPosition.current) {
              preStateStyle = preStateStyle.merge(theme.outsideMonth);
            }
            if (events.isNotEmpty) {
              preStateStyle = preStateStyle.merge(theme.withEvents);
            }
            final draft = CalendarDayDetails<T>(
              date: date,
              events: events,
              isEnabled: isEnabled,
              isSelected: isSelected,
              isToday: isToday,
              isWeekend: isWeekend,
              monthPosition: monthPosition,
              pageAnchor: pageAnchor,
              style: preStateStyle,
            );
            final dateStyle = widget.dayStyleResolver?.call(context, draft);
            final style = theme.resolveDayStyle(
              isOutsideMonth: monthPosition != CalendarMonthPosition.current,
              isWeekend: isWeekend,
              hasEvents: events.isNotEmpty,
              isToday: isToday,
              isEnabled: isEnabled,
              isSelected: isSelected,
              dateStyle: dateStyle,
            );
            final details = CalendarDayDetails<T>(
              date: date,
              events: events,
              isEnabled: isEnabled,
              isSelected: isSelected,
              isToday: isToday,
              isWeekend: isWeekend,
              monthPosition: monthPosition,
              pageAnchor: pageAnchor,
              style: style,
            );
            return KeyedSubtree(
              key: ValueKey<DateTime>(date),
              child: _renderDay(context, details, theme.marker),
            );
          },
        );
      },
    );
  }

  CalendarMonthPosition _monthPosition(DateTime date, DateTime pageAnchor) {
    final comparison =
        date.year * 12 + date.month - (pageAnchor.year * 12 + pageAnchor.month);
    if (comparison < 0) return CalendarMonthPosition.previous;
    if (comparison > 0) return CalendarMonthPosition.next;
    return CalendarMonthPosition.current;
  }

  List<T> _eventsForDate(DateTime date) {
    final resolver = widget.eventsForDate;
    if (resolver == null) return const <Never>[];
    final events = resolver(date);
    if (events.isEmpty) return const <Never>[];
    return List<T>.unmodifiable(events);
  }

  bool _isEnabled(DateTime date) {
    final normalized = dateOnly(date);
    return !normalized.isBefore(_minimumDate) &&
        !normalized.isAfter(_maximumDate) &&
        (widget.isDateEnabled?.call(normalized) ?? true);
  }

  Widget _renderDay(
    BuildContext context,
    CalendarDayDetails<T> details,
    CalendarMarkerStyle markerStyle,
  ) {
    final dayContent =
        widget.dayBuilder?.call(context, details) ?? _defaultDay(details);
    final markerBuilder = widget.markerBuilder;
    final Widget? marker;
    if (details.events.isEmpty) {
      marker = null;
    } else if (markerBuilder == null) {
      marker = _defaultMarker(
        context,
        details.events.length,
        markerStyle,
        isSelected: details.isSelected,
      );
    } else {
      marker = markerBuilder(context, details);
    }
    final content = marker == null
        ? dayContent
        : Stack(
            fit: StackFit.expand,
            children: <Widget>[
              dayContent,
              IgnorePointer(child: marker),
            ],
          );
    final baseShape = details.style.shape ?? const CircleBorder();
    final visualShape = details.style.border == null
        ? baseShape
        : baseShape.copyWith(side: details.style.border);
    final hasInteraction =
        widget.onDateSelected != null || widget.onDateLongPressed != null;
    final decoration = ShapeDecoration(
      color: details.style.backgroundColor,
      shape: visualShape,
    );
    final visual = Padding(
      padding: EdgeInsets.all(widget.layout.dayPadding),
      child: hasInteraction
          ? Ink(decoration: decoration, child: content)
          : DecoratedBox(decoration: decoration, child: content),
    );
    final semantics = Semantics(
      label: _semanticDate.format(details.date),
      selected: details.isSelected,
      child: visual,
    );

    if (!hasInteraction) {
      return SizedBox.expand(child: semantics);
    }

    return SizedBox.expand(
      child: TextButton(
        style: TextButton.styleFrom(
          minimumSize: Size.zero,
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: EdgeInsets.zero,
          shape: visualShape.copyWith(side: BorderSide.none),
          backgroundColor: Colors.transparent,
        ),
        onPressed: details.isEnabled && widget.onDateSelected != null
            ? () => widget.onDateSelected!(details.date, details.events)
            : null,
        onLongPress: details.isEnabled && widget.onDateLongPressed != null
            ? () => widget.onDateLongPressed!(details.date)
            : null,
        child: semantics,
      ),
    );
  }

  Widget _defaultDay(CalendarDayDetails<T> details) => SizedBox.expand(
    child: Align(
      alignment: details.style.alignment ?? Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: ExcludeSemantics(
          child: Text(
            '${details.date.day}',
            style: details.style.textStyle,
            maxLines: 1,
            softWrap: false,
          ),
        ),
      ),
    ),
  );

  Widget _defaultMarker(
    BuildContext context,
    int eventCount,
    CalendarMarkerStyle style, {
    required bool isSelected,
  }) {
    final color = isSelected ? style.selectedColor ?? style.color : style.color;
    final visibleCount = math.min(eventCount, style.maxVisible);
    final hiddenCount = eventCount - visibleCount;
    final children = <Widget>[
      for (var index = 0; index < visibleCount; index++)
        Container(
          width: style.size,
          height: style.size,
          margin: EdgeInsets.symmetric(horizontal: style.spacing / 2),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      if (hiddenCount > 0 && style.showOverflowCount)
        Padding(
          padding: EdgeInsets.only(left: style.spacing),
          child: Text(
            '+$hiddenCount',
            maxLines: 1,
            softWrap: false,
            style: TextStyle(color: color, fontSize: 9),
          ),
        ),
    ];
    final semanticLabel =
        style.semanticLabelBuilder?.call(context, eventCount) ??
        (eventCount == 1 ? '1 event' : '$eventCount events');
    return Semantics(
      label: semanticLabel,
      child: ExcludeSemantics(
        child: children.isEmpty
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: children,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  bool _canMoveByPage(int offset) {
    final target = (_requestedPage ?? _page) + offset;
    return target >= 0 && target < _pager.pageCount;
  }

  void _moveByPage(int offset) {
    _moveToPage((_requestedPage ?? _page) + offset, reportRequest: true);
  }

  void _moveToPage(
    int page, {
    bool animate = true,
    bool reportRequest = false,
  }) {
    if (page < 0 ||
        page >= _pager.pageCount ||
        page == (_requestedPage ?? _page)) {
      return;
    }
    final controller = _controller;
    final request = ++_navigationRequest;
    _requestedPage = page;
    if (reportRequest && widget.onPageChanged != null) {
      final anchor = _pager.anchorForPage(page);
      _reportedNavigationAnchors.add(anchor);
      _notifyPageChanged(anchor);
    }
    if (!animate) {
      controller.jumpToPage(page);
      return;
    }
    controller
        .animateToPage(
          page,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        )
        .whenComplete(() {
          if (mounted &&
              request == _navigationRequest &&
              identical(controller, _controller)) {
            _requestedPage = null;
            _clearReportedNavigationAnchorsAfterFrame();
          }
        });
  }

  void _handlePageChanged(int page) {
    if (_requestedPage == page) _requestedPage = null;
    final anchor = _pager.anchorForPage(page);
    final wasReported = _reportedNavigationAnchors.contains(anchor);
    if (page == _page) return;
    setState(() {
      _page = page;
      _targetDate = anchor;
    });
    if (!wasReported) _notifyPageChanged(anchor);
  }

  void _notifyPageChangedUnlessReported(DateTime date) {
    if (!_reportedNavigationAnchors.contains(dateOnly(date))) {
      _notifyPageChanged(date);
    }
  }

  void _clearReportedNavigationAnchorsAfterFrame() {
    if (_reportedNavigationAnchors.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reportedNavigationAnchors.clear();
    });
  }

  void _notifyPageChanged(DateTime date) {
    final callback = widget.onPageChanged;
    if (callback == null) return;
    final normalizedDate = dateOnly(date);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) callback(normalizedDate);
    });
  }

  Future<void> _selectDateFromPicker() async {
    if (_pickerInProgress) return;
    _pickerInProgress = true;
    try {
      final initialDate = await _nearestEnabledDate(
        clampDate(
          widget.selectedDate ?? widget.focusedDate ?? _targetDate,
          _minimumDate,
          _maximumDate,
        ),
      );
      if (!mounted || initialDate == null) return;
      final selected = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: _minimumDate,
        lastDate: _maximumDate,
        selectableDayPredicate: _isEnabled,
        locale: _supportsMaterialLocale(_effectiveLocale)
            ? _effectiveLocale
            : null,
      );
      if (!mounted || selected == null || !_isEnabled(selected)) return;
      final normalized = dateOnly(selected);
      final events = _eventsForDate(normalized);
      widget.onDateSelected?.call(normalized, events);
      _moveToPage(_pager.pageFor(normalized), animate: false);
    } finally {
      _pickerInProgress = false;
    }
  }

  Future<DateTime?> _nearestEnabledDate(DateTime preferredDate) async {
    if (_isEnabled(preferredDate)) return preferredDate;
    final maximumDistance = calendarDaysBetween(_minimumDate, _maximumDate);
    for (var distance = 1; distance <= maximumDistance; distance++) {
      final after = addCalendarDays(preferredDate, distance);
      if (!after.isAfter(_maximumDate) && _isEnabled(after)) return after;
      final before = addCalendarDays(preferredDate, -distance);
      if (!before.isBefore(_minimumDate) && _isEnabled(before)) return before;
      if (distance % 2048 == 0) {
        await Future<void>.delayed(Duration.zero);
        if (!mounted) return null;
      }
    }
    return null;
  }

  bool _supportsMaterialLocale(Locale locale) {
    final localizations = context
        .findAncestorWidgetOfExactType<Localizations>();
    if (localizations == null) return false;
    for (final delegate in localizations.delegates) {
      if (delegate.type != MaterialLocalizations ||
          !delegate.isSupported(locale)) {
        continue;
      }
      if (!identical(delegate, DefaultMaterialLocalizations.delegate)) {
        return true;
      }
      return locale.languageCode == 'en' &&
          locale.scriptCode == null &&
          (locale.countryCode == null || locale.countryCode == 'US');
    }
    return false;
  }
}
