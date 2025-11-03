import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/src/default_styles.dart'
    show defaultHeaderTextStyle;

/// - Passing in values for [leftButtonIcon] or [rightButtonIcon] will override [headerIconColor]
/// - Passing in value for [showHeaderButtons] `false` will override [showLeftButton] and [showRightButton] to `false`
class CalendarHeader extends StatelessWidget {
  const CalendarHeader({
    Key? key,
    required this.headerTitle,
    this.headerMargin,
    required this.showHeader,
    this.headerTextStyle,
    this.showHeaderButtons = true,
    this.showLeftButton = true,
    this.showRightButton = true,
    this.headerIconColor,
    this.leftButtonIcon,
    this.rightButtonIcon,
    required this.onLeftButtonPressed,
    required this.onRightButtonPressed,
    this.onHeaderTitlePressed,
  }) : isTitleTouchable = onHeaderTitlePressed != null,
       super(key: key);

  final String headerTitle;
  final EdgeInsetsGeometry? headerMargin;
  final bool showHeader;
  final TextStyle? headerTextStyle;
  final bool showHeaderButtons;
  final bool showLeftButton;
  final bool showRightButton;
  final Color? headerIconColor;
  final Widget? leftButtonIcon;
  final Widget? rightButtonIcon;
  final VoidCallback onLeftButtonPressed;
  final VoidCallback onRightButtonPressed;
  final bool isTitleTouchable;
  final VoidCallback? onHeaderTitlePressed;

  TextStyle get getTextStyle => headerTextStyle ?? defaultHeaderTextStyle;

  Widget _inactiveDimension() => SizedBox.square(dimension: 44);

  Widget _leftButton() {
    if (showLeftButton) {
      return IconButton(
        onPressed: onLeftButtonPressed,
        icon:
            leftButtonIcon ?? Icon(Icons.chevron_left, color: headerIconColor),
      );
    } else if (showRightButton) {
      return _inactiveDimension();
    } else {
      return Container();
    }
  }

  Widget _rightButton() {
    if (showRightButton) {
      return IconButton(
        onPressed: onRightButtonPressed,
        icon: rightButtonIcon ??
            Icon(Icons.chevron_right, color: headerIconColor),
      );
    } else if (showLeftButton) {
      return _inactiveDimension();
    } else {
      return Container();
    }
  }

  Widget _headerTouchable() => TextButton(
    onPressed: onHeaderTitlePressed,
    child: Text(headerTitle, semanticsLabel: headerTitle, style: getTextStyle),
  );

  @override
  Widget build(BuildContext context) => showHeader
      ? Container(
          margin: headerMargin,
          child: DefaultTextStyle(
            style: getTextStyle,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                if (showHeaderButtons) _leftButton() else Container(),
                if (isTitleTouchable)
                  _headerTouchable()
                else
                  Text(headerTitle, style: getTextStyle),
                if (showHeaderButtons) _rightButton() else Container(),
              ],
            ),
          ),
        )
      : Container();
}
