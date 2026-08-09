import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/src/calendar_config.dart';
import 'package:flutter_calendar_carousel/src/calendar_view.dart';

const double _compactHeaderWidth = kMinInteractiveDimension * 2 + 24;

/// Internal renderer for the configured calendar header.
class CalendarHeader extends StatelessWidget {
  const CalendarHeader({
    super.key,
    required this.config,
    required this.details,
  });

  final CalendarHeaderConfig config;
  final CalendarHeaderDetails details;

  @override
  Widget build(BuildContext context) {
    if (!config.visible) return const SizedBox.shrink();
    final customHeader = config.builder?.call(context, details);
    return Container(
      margin: config.margin,
      color: details.style.backgroundColor,
      child: customHeader ?? _defaultHeader(context),
    );
  }

  Widget _defaultHeader(BuildContext context) => DefaultTextStyle(
    style: details.style.textStyle ?? DefaultTextStyle.of(context).style,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            config.showNavigationButtons &&
            constraints.hasBoundedWidth &&
            constraints.maxWidth < _compactHeaderWidth;
        if (compact) {
          return Row(
            children: <Widget>[
              Expanded(child: _previousButton(context)),
              Expanded(child: _title()),
              Expanded(child: _nextButton(context)),
            ],
          );
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            if (config.showNavigationButtons) _previousButton(context),
            Expanded(child: _title()),
            if (config.showNavigationButtons) _nextButton(context),
          ],
        );
      },
    ),
  );

  Widget _previousButton(BuildContext context) => IconButton(
    onPressed: details.onPrevious,
    tooltip: MaterialLocalizations.of(context).previousPageTooltip,
    icon:
        config.previousIcon ??
        Icon(Icons.chevron_left, color: details.style.iconColor),
  );

  Widget _nextButton(BuildContext context) => IconButton(
    onPressed: details.onNext,
    tooltip: MaterialLocalizations.of(context).nextPageTooltip,
    icon:
        config.nextIcon ??
        Icon(Icons.chevron_right, color: details.style.iconColor),
  );

  Widget _title() {
    final title = Text(
      details.label,
      semanticsLabel: details.label,
      style: details.style.textStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
    final onPressed = details.onTitlePressed;
    return onPressed == null
        ? title
        : TextButton(onPressed: onPressed, child: title);
  }
}
