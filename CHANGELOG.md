## [2.5.0]

- Add linter and code formatting ([#386](https://github.com/hyochan/flutter_calendar_carousel/pull/386))
- Upgrade dependencies and integrate linter ([#384](https://github.com/hyochan/flutter_calendar_carousel/pull/384))
- Support Xcode 16 for iOS ([#385](https://github.com/hyochan/flutter_calendar_carousel/pull/385))
- Migrate Gradle to use declarative plugins block in Android example ([#383](https://github.com/hyochan/flutter_calendar_carousel/pull/383))

## [2.4.4]

Upgrade intl to `^0.19.0`

## [2.4.3]

Upgrade intl to `^0.18.1`

## [2.4.2]

Support Flutter version 3+

## [2.4.1]

Update iOS podspec and `info.plist`

## [2.1.0]

Update build config on flutter V2 embedding (#293)

## [2.0.3]

Multiple days selection using `addRange` method [#285](https://github.com/hyochan/flutter_calendar_carousel/pull/285)

## [2.0.2]

Multiple days selection [#282](https://github.com/hyochan/flutter_calendar_carousel/pull/284)

## [2.0.1]

Null safety improvements [#272](https://github.com/hyochan/flutter_calendar_carousel/pull/272)

## [2.0.1]

Added disableDayPressed option [#267](https://github.com/hyochan/flutter_calendar_carousel/pull/267)

## [2.0.0]

Support null-safety [#260](https://github.com/hyochan/flutter_calendar_carousel/pull/260)

## [1.5.3]

- Add `id` to event model [#257](https://github.com/hyochan/flutter_calendar_carousel/pull/257)

## [1.5.2]

- Bump up `intl` dependency [#254](https://github.com/hyochan/flutter_calendar_carousel/pull/254)

## [1.5.1]

- Bugfix when switching month - "The method 'call' was called on null." [#243](https://github.com/hyochan/flutter_calendar_carousel/pull/243)

## [1.5.0]

- Add key to widget constructor [#234](https://github.com/hyochan/flutter_calendar_carousel/pull/234/files)
- Enhance initilizing page numbers [#231](https://github.com/hyochan/flutter_calendar_carousel/pull/231)

## [1.4.12]

- Handle issue [#207](https://github.com/hyochan/flutter_calendar_carousel/issues/207), [#209](https://github.com/hyochan/flutter_calendar_carousel/issues/209)

## [1.4.11]

- Add first day of week offset to week builder [#204](https://github.com/hyochan/flutter_calendar_carousel/pull/204)

## [1.4.10]

- Fix Calendar displays incorrectly when scrolling horizontally [#193](https://github.com/hyochan/flutter_calendar_carousel/pull/193)

## [1.4.9]

- Target date for custom header

## [1.4.8]

- Add ability to set `targetDate` on header [#183](https://github.com/hyochan/flutter_calendar_carousel/pull/183).

## [1.4.7]

- Fix current day showing incorrectly when using `showOnlyCurrentMonthDate` [#181](https://github.com/hyochan/flutter_calendar_carousel/pull/182).

## [1.4.6]

- Set default `minSelectedDate` and `maxSelectedDate` [#179](https://github.com/hyochan/flutter_calendar_carousel/pull/179).

## [1.4.4]

- Expose `pageScrollPhysics` for pageView.

## [1.4.2]

- Add option for setting scrollDirection [#166](https://github.com/hyochan/flutter_calendar_carousel/pull/166)
- Resolve [#123](https://github.com/hyochan/flutter_calendar_carousel/issues/123) in [#165](https://github.com/hyochan/flutter_calendar_carousel/pull/165).

## [1.4.1]

- Resolve [#164](https://github.com/hyochan/flutter_calendar_carousel/issues/164).

## [1.4.0]

- Resolve [#154](https://github.com/hyochan/flutter_calendar_carousel/issues/154).

## [1.3.29]

- Resolve [#157](https://github.com/hyochan/flutter_calendar_carousel/issues/157).

## [1.3.28]

- Allow the use of generic type with Interface [#149](https://github.com/hyochan/flutter_calendar_carousel/pull/149)
- Added doc to custom weekday builder. Weekday number is now supplied to the builder [#150](https://github.com/hyochan/flutter_calendar_carousel/pull/150)

## [1.3.27]

- customDayBuilder fix.
- Remove date_utils dep.

## [1.3.26]

- Support custom day container feature [#145](https://github.com/hyochan/flutter_calendar_carousel/pull/145).

## [1.3.23]

- Support intl >= 0.15.7 < 0.17.0 to inclease `pub` health
- Removed deprecated methods ~~`markedDates`~~, ~~`markedDateColor`~~
- Fixes [#101](https://github.com/hyochan/flutter_calendar_carousel/issues/101)
- Fixes [#104](https://github.com/hyochan/flutter_calendar_carousel/issues/104)
- Fixes [#112](https://github.com/hyochan/flutter_calendar_carousel/issues/112)
- Fixes [#119](https://github.com/hyochan/flutter_calendar_carousel/issues/119)
- Support long pressed as a feature request[#103](https://github.com/hyochan/flutter_calendar_carousel/issues/103)
- Support semantic label as a feature request [#139](https://github.com/hyochan/flutter_calendar_carousel/issues/139)
- Expose `dayCrossAxisAlignment` and `dayMainAxisAlignment` to resolve [#122](https://github.com/hyochan/flutter_calendar_carousel/issues/122)
- Expose `showIconBehindDayText` to resolve [#131](https://github.com/hyochan/flutter_calendar_carousel/issues/131)
- Fixes [#94](https://github.com/hyochan/flutter_calendar_carousel/issues/94)

## [1.3.20]

- Support intl >= 0.15.7

## [1.3.19]

- Improved customizability for weekday containers [#141](https://github.com/hyochan/flutter_calendar_carousel/pull/141)

## [1.3.18]

- Fix vertical scroll behavior for weekFormat calendar view.
- Reformat code with dartfmt

## [1.3.17]

- Added feature to only show dates from today adding `showOnlyCurrentMonthDate` parameter.

## [1.3.16]

- Added feature for change first day of the week.

## [1.3.15+]

- Ability to disable horizontal scroll to change month with `isScrollable` param.
  - Resolve [#74](https://github.com/hyochan/flutter_calendar_carousel/issues/74)
- Show events in `week` calendar.
  - Resolve [#66](https://github.com/hyochan/flutter_calendar_carousel/issues/66)
- Update breaking docs in pub.
- Expose event list to user.
- Remove print.
- Pass first date of week to onCalendarChanged in week view [#88](https://github.com/hyochan/flutter_calendar_carousel/pull/88)
- Support for passing in custom widgets for next and previous month arrow icons [#95](https://github.com/hyochan/flutter_calendar_carousel/pull/95)

## [1.3.14]

- Code refactoring [#77](https://github.com/hyochan/flutter_calendar_carousel/pull/77)
  - Seperate weekday widget

## [1.3.13]

- Code refactoring [#73](https://github.com/hyochan/flutter_calendar_carousel/pull/73)
  - Seperate header.
  - Add first basic test code.
  - Add composable header widget

## [1.3.12]

- Setting dot icon per event [#71](https://github.com/hyochan/flutter_calendar_carousel/pull/71)

## [1.3.11]

- Fixed `selectledDayTextStyle` property not being respected [#65](https://github.com/hyochan/flutter_calendar_carousel/pull/65).

## [1.3.10]

- Add property for static six week format to keep calendar height consistent between months [#62](https://github.com/hyochan/flutter_calendar_carousel/pull/62).

## [1.3.9]

- Changed priority for `today` higher than `prevMonth` and `nextMonth` and `thisMonth`.

## [1.3.7]

- Ability to choose the weekday format on the constructor [#47](https://github.com/hyochan/flutter_calendar_carousel/pull/47).

## [1.3.6]

- custom event type added [#49](https://github.com/hyochan/flutter_calendar_carousel/pull/49).

## [1.3.5]

- headerTitleTouchable and onHeaderTitlePressed props added [#44](https://github.com/hyochan/flutter_calendar_carousel/pull/44).

## [1.3.4]

- Bug fix. PrevDaysTextStyle and PrevDaysTextStyle overwrite weekendTextStyle [#41](https://github.com/hyochan/flutter_calendar_carousel/issues/41).

## [1.3.3]

- Fixed FlatButton fill and border color. [#37](https://github.com/hyochan/flutter_calendar_carousel/pull/37)
- EventList bug fixing. [#37](https://github.com/hyochan/flutter_calendar_carousel/pull/36)

## [1.3.2]

- Mapping events for better performance. [#34](https://github.com/hyochan/flutter_calendar_carousel/pull/34).

## [1.3.1]

- weekdays bug fix.

## [1.3.0]

- Better localization support for `weekDays`. Setting manually weekdays isn't required now. Related [#23](https://github.com/hyochan/flutter_calendar_carousel/pull/23).
- Add custom icons in event [#28](https://github.com/hyochan/flutter_calendar_carousel/pull/28).

## [1.2.3]

- Add custom physics parameter. Feature in [#21](https://github.com/hyochan/flutter_calendar_carousel/pull/21).

## [1.2.2]

- headerTextStyle fix[#17](https://github.com/hyochan/flutter_calendar_carousel/issues/17).
- Can show or hide header button with `showHeaderButton` attribute.

## [1.2.1]

- Week-format shows current week [#15](https://github.com/hyochan/flutter_calendar_carousel/issues/15).

## [1.2.0]

- Support carousel week calendar.

## [1.1.11]

- Ability to customize weekend days [#13](https://github.com/hyochan/flutter_calendar_carousel/issues/13).

## [1.1.10]

- Support weekFormat but without carousel.

## [1.1.9]

- Updated readme.

## [1.1.8]

- Render multiple marked dates.
- `markedDates` is deprecated. Use `markedDatesMap` instead.

## [1.1.3]

- Mark dates with non-zero times.

## [1.1.2]

- Implemented a way to change the header text style.

## [1.1.1]

- Expose new variables.
  - headerMargin, childAspectRatio, weekDayMargin

## [1.1.0]

- Give proper text color in weekend when it is today.
- Compare month and year for marking today's date. Resolve #3.

## [1.0.3]

- Fixed pub broken image.

## [1.0.2]

- Use `Position` widget to mark the dates.

## [1.0.1]

- Show markedDates.

## [0.2.0]

- Customizable headerWidget.
- Setting weekdays visibility
- Customizable weekend color.

## [0.1.3]

- Rename the top-level "docs" directory to "doc".

## [0.1.1]

- Added readme.

## [0.1.0]

- First release
