class EventList<T> {
  Map<DateTime, List<T>> events;

  EventList({required this.events});

  void add(DateTime date, T event) {
    final eventsOfDate = events[date];
    if (eventsOfDate == null) {
      events[date] = [event];
    } else {
      eventsOfDate.add(event);
    }
  }

  void addAll(DateTime date, List<T> events) {
    final eventsOfDate = this.events[date];
    if (eventsOfDate == null) {
      this.events[date] = events;
    } else {
      eventsOfDate.addAll(events);
    }
  }

  bool remove(DateTime date, T event) {
    final eventsOfDate = events[date];
    return eventsOfDate != null ? eventsOfDate.remove(event) : false;
  }

  List<T> removeAll(DateTime date) {
    return events.remove(date) ?? [];
  }

  void clear() {
    events.clear();
  }

  List<T> getEvents(DateTime date) {
    return events[date] ?? [];
  }
}
