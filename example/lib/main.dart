import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';

void main() => runApp(const CalendarDemoApp());

class CalendarDemoApp extends StatelessWidget {
  const CalendarDemoApp({super.key, this.initialDate});

  final DateTime? initialDate;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Calendar Carousel',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: CalendarDemoPage(initialDate: initialDate),
    );
  }
}

class DemoEvent {
  const DemoEvent({
    required this.title,
    required this.color,
    this.description,
    this.location,
    this.icon,
  });

  final String title;
  final String? description;
  final String? location;
  final Widget? icon;
  final Color color;
}

class CalendarDemoPage extends StatefulWidget {
  const CalendarDemoPage({super.key, this.initialDate});

  final DateTime? initialDate;

  @override
  State<CalendarDemoPage> createState() => _CalendarDemoPageState();
}

class _CalendarDemoPageState extends State<CalendarDemoPage> {
  late final DateTime _today;
  late final Map<DateTime, List<DemoEvent>> _eventsByDate;
  late DateTime _selectedDate;
  late DateTime _focusedDate;
  late DateTime _visiblePageAnchor;
  late List<DemoEvent> _selectedEvents;
  CalendarView _view = CalendarView.month;

  @override
  void initState() {
    super.initState();
    final now = widget.initialDate ?? DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    _selectedDate = _today;
    _focusedDate = _today;
    _visiblePageAnchor = DateTime(_today.year, _today.month);
    _eventsByDate = <DateTime, List<DemoEvent>>{
      _today: <DemoEvent>[
        const DemoEvent(
          title: 'Team sync',
          location: 'Studio',
          icon: Icon(Icons.groups_rounded),
          color: Colors.indigo,
        ),
      ],
      _addDays(_today, 2): <DemoEvent>[
        const DemoEvent(
          title: 'Release',
          description: 'Publish the next package version.',
          icon: Icon(Icons.rocket_launch_rounded),
          color: Colors.deepOrange,
        ),
        const DemoEvent(
          title: 'Release notes',
          icon: Icon(Icons.edit_note_rounded),
          color: Colors.teal,
        ),
      ],
      _addDays(_today, 6): <DemoEvent>[
        const DemoEvent(
          title: 'Community call',
          icon: Icon(Icons.forum_rounded),
          color: Colors.purple,
        ),
      ],
    };
    _selectedEvents = _eventsForDate(_selectedDate);
  }

  static DateTime _addDays(DateTime date, int days) =>
      DateTime(date.year, date.month, date.day + days);

  static DateTime _startOfWeek(DateTime date, int firstDayOfWeek) {
    final sundayBasedWeekday = date.weekday % DateTime.daysPerWeek;
    final distance =
        (sundayBasedWeekday - firstDayOfWeek + DateTime.daysPerWeek) %
        DateTime.daysPerWeek;
    return _addDays(date, -distance);
  }

  List<DemoEvent> _eventsForDate(DateTime date) =>
      _eventsByDate[DateTime(date.year, date.month, date.day)] ??
      const <DemoEvent>[];

  void _changeView(Set<CalendarView> selection) {
    final nextView = selection.first;
    final firstDayOfWeek = MaterialLocalizations.of(
      context,
    ).firstDayOfWeekIndex;
    setState(() {
      _view = nextView;
      _focusedDate = _selectedDate;
      _visiblePageAnchor = nextView == CalendarView.month
          ? DateTime(_selectedDate.year, _selectedDate.month)
          : _startOfWeek(_selectedDate, firstDayOfWeek);
    });
  }

  void _selectDate(DateTime date, List<DemoEvent> events) {
    final firstDayOfWeek = MaterialLocalizations.of(
      context,
    ).firstDayOfWeekIndex;
    setState(() {
      _selectedDate = date;
      _focusedDate = date;
      _visiblePageAnchor = _view == CalendarView.month
          ? DateTime(date.year, date.month)
          : _startOfWeek(date, firstDayOfWeek);
      _selectedEvents = events;
    });
  }

  void _showToday() {
    final firstDayOfWeek = MaterialLocalizations.of(
      context,
    ).firstDayOfWeekIndex;
    setState(() {
      _selectedDate = _today;
      _focusedDate = _today;
      _visiblePageAnchor = _view == CalendarView.month
          ? DateTime(_today.year, _today.month)
          : _startOfWeek(_today, firstDayOfWeek);
      _selectedEvents = _eventsForDate(_today);
    });
  }

  void _updateVisiblePage(DateTime pageAnchor) {
    setState(() {
      _focusedDate = pageAnchor;
      _visiblePageAnchor = pageAnchor;
    });
  }

  void _showLongPress(DateTime date) {
    final dateLabel = MaterialLocalizations.of(context).formatFullDate(date);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Long pressed $dateLabel')));
  }

  Widget _buildEventMarkers(
    BuildContext context,
    CalendarDayDetails<DemoEvent> day,
  ) {
    const maxVisible = 3;
    final visible = day.events.take(maxVisible).toList(growable: false);
    final hiddenCount = day.events.length - visible.length;
    final selectedMarkerColor = Theme.of(context).colorScheme.onPrimary;
    final eventLabel = day.events.length == 1
        ? '1 event'
        : '${day.events.length} events';

    return Semantics(
      label: eventLabel,
      child: ExcludeSemantics(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (final event in visible)
                    Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: day.isSelected
                            ? selectedMarkerColor
                            : event.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  if (hiddenCount > 0)
                    Text(
                      '+$hiddenCount',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: day.isSelected ? selectedMarkerColor : null,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pageControls(BuildContext context, String pageLabel) {
    final label = Text(
      'Visible: $pageLabel',
      style: Theme.of(context).textTheme.labelLarge,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.maxWidth < 240 ||
            MediaQuery.textScalerOf(context).scale(14) > 20;
        return Row(
          crossAxisAlignment: compact
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(child: label),
            if (compact)
              IconButton(
                onPressed: _showToday,
                tooltip: 'Today',
                icon: const Icon(Icons.today_rounded),
              )
            else
              TextButton.icon(
                onPressed: _showToday,
                icon: const Icon(Icons.today_rounded),
                label: const Text('Today'),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final pageLabel = _view == CalendarView.month
        ? localizations.formatMonthYear(_visiblePageAnchor)
        : '${localizations.formatShortDate(_visiblePageAnchor)} – '
              '${localizations.formatShortDate(_addDays(_visiblePageAnchor, 6))}';
    final calendarTheme = CalendarCarouselThemeData(
      selected: CalendarDayStyle(
        backgroundColor: colors.primary,
        textStyle: TextStyle(color: colors.onPrimary),
      ),
      today: CalendarDayStyle(
        backgroundColor: colors.secondaryContainer,
        textStyle: TextStyle(color: colors.onSecondaryContainer),
        border: BorderSide(color: colors.secondary),
      ),
      header: CalendarHeaderStyle(iconColor: colors.primary),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar Carousel')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          SegmentedButton<CalendarView>(
            segments: const <ButtonSegment<CalendarView>>[
              ButtonSegment<CalendarView>(
                value: CalendarView.month,
                icon: Icon(Icons.calendar_view_month_rounded),
                label: Text('Month'),
              ),
              ButtonSegment<CalendarView>(
                value: CalendarView.week,
                icon: Icon(Icons.view_week_rounded),
                label: Text('Week'),
              ),
            ],
            selected: <CalendarView>{_view},
            onSelectionChanged: _changeView,
          ),
          const SizedBox(height: 16),
          _pageControls(context, pageLabel),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: _view == CalendarView.month ? 420 : 190,
              child: CalendarCarousel<DemoEvent>(
                view: _view,
                locale: Localizations.localeOf(context),
                selectedDate: _selectedDate,
                focusedDate: _focusedDate,
                eventsForDate: _eventsForDate,
                firstDate: DateTime(_today.year - 1),
                lastDate: DateTime(_today.year + 1, 12, 31),
                onDateSelected: _selectDate,
                onDateLongPressed: _showLongPress,
                onPageChanged: _updateVisiblePage,
                markerBuilder: _buildEventMarkers,
                header: const CalendarHeaderConfig(enableDatePicker: true),
                weekdays: const CalendarWeekdayConfig(
                  format: CalendarWeekdayFormat.short,
                ),
                layout: const CalendarLayoutConfig(fixedSixWeeks: true),
                paging: const CalendarPagingConfig(),
                theme: calendarTheme,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SelectionCard(
            dateLabel: localizations.formatFullDate(_selectedDate),
            events: _selectedEvents,
          ),
        ],
      ),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  const _SelectionCard({required this.dateLabel, required this.events});

  final String dateLabel;
  final List<DemoEvent> events;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(dateLabel, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (events.isEmpty)
              Text('No events', style: Theme.of(context).textTheme.bodyMedium)
            else
              for (final event in events)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: event.icon ?? const Icon(Icons.event_rounded),
                  title: Text(event.title),
                  subtitle: event.description == null
                      ? (event.location == null ? null : Text(event.location!))
                      : Text(event.description!),
                ),
          ],
        ),
      ),
    );
  }
}
