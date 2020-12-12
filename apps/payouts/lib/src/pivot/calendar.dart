import 'package:flutter/widgets.dart' hide TableCell, TableRow;
import 'package:intl/intl.dart';

import 'foundation.dart';
import 'spinner.dart';
import 'table_pane.dart';

@immutable
class CalendarDate implements Comparable<CalendarDate> {
  const CalendarDate(
    this.year,
    this.month,
    this.day,
  );

  final int year;
  final int month;
  final int day;

  static const List<int> _monthLengths = <int>[31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

  static const int _gregorianCutoverYear = 1582;

  bool get isValid {
    if (year <= _gregorianCutoverYear || year > 9999) {
      return false;
    }

    if (month < 0 || month > 11) {
      return false;
    }

    if (day < 0 || day >= daysInMonth) {
      return false;
    }

    return true;
  }

  /// The day of the week, Monday (1) to Sunday (7).
  ///
  /// In accordance with ISO 8601, a week starts with Monday (which has the
  /// value 1).
  int get weekday => toDateTime().weekday;

  /// Whether the year represented by this calendar date is a leap year.
  bool get isLeapYear => ((year & 3) == 0 && (year % 100 != 0 || year % 400 == 0));

  /// The number of days in the month represented by this calendar date.
  int get daysInMonth {
    int daysInMonth = _monthLengths[month];
    if (isLeapYear && month == 1) {
      daysInMonth++;
    }
    return daysInMonth;
  }

  DateTime toDateTime() {
    return DateTime(year, month + 1, day + 1);
  }

  CalendarDate operator +(int days) {
    int year = this.year;
    int month = this.month;
    int day = this.day + 1;
    if (day >= daysInMonth) {
      day = 0;
      month++;
      if (month > 11) {
        month = 0;
        year++;
      }
    }
    return CalendarDate(year, month, day);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalendarDate && year == other.year && month == other.month && day == other.day;
  }

  @override
  int get hashCode => hashValues(year, month, day);

  @override
  int compareTo(CalendarDate other) {
    int result = year - other.year;
    if (result == 0) {
      result = month - other.month;
      if (result == 0) {
        result = day - other.day;
      }
    }
    return result;
  }
}

class Calendar extends StatefulWidget {
  const Calendar({
    Key? key,
    required this.initialYear,
    required this.initialMonth,
    this.initialSelectedDate,
    this.disabledDateFilter,
  }) : super(key: key);

  final int initialYear;
  final int initialMonth;
  final CalendarDate? initialSelectedDate;
  final Predicate<CalendarDate>? disabledDateFilter;

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late SpinnerController _monthController;
  late SpinnerController _yearController;
  late List<TableRow> _calendarRows;

  static final DateFormat _fullMonth = DateFormat('MMMM');
  static final DateFormat _dayOfWeekShort = DateFormat('E');
  static final int firstDayOfWeek = _dayOfWeekShort.dateSymbols.FIRSTDAYOFWEEK;
  static final DateTime _monday = DateTime(2020, 12, 7);

  void _updateCalendarRows() {
    final int year = _yearController.selectedIndex + CalendarDate._gregorianCutoverYear;
    final int month = _monthController.selectedIndex;
    CalendarDate date = CalendarDate(year, month, 0);
    final int daysInMonth = date.daysInMonth;
    final int firstDayOfMonthOffset = (firstDayOfWeek + 1 + date.weekday) % 7;
    final int lastDayOfMonthOffset = (firstDayOfMonthOffset - 1 + daysInMonth) % 7;
    List<Widget> cells = List<Widget>.filled(firstDayOfMonthOffset, const EmptyTableCell(), growable: true);
    final List<TableRow> rows = <TableRow>[TableRow(children: cells)];
    for (int i = 0; i < daysInMonth; i++) {
      final int rowIndex = (i + firstDayOfMonthOffset) ~/ 7;
      if (rowIndex >= rows.length) {
        cells = <Widget>[];
        rows.add(TableRow(children: cells));
      }
      cells.add(Padding(
        padding: EdgeInsets.all(4),
        child: Text('${date.day + 1}', textAlign: TextAlign.center),
      ));
      date++;
    }
    for (int i = lastDayOfMonthOffset + 1; i < 7; i++) {
      cells.add(const EmptyTableCell());
    }

    setState(() {
      _calendarRows = rows;
    });
  }

  static Widget buildMonth(BuildContext context, int index) {
    String value = '';
    if (index >= 0) {
      // Since we're only rendering the month, the year and day do not matter here.
      final DateTime date = DateTime(2000, index + 1);
      value = _fullMonth.format(date);
    }
    return Spinner.defaultItemBuilder(context, value);
  }

  static Widget buildYear(BuildContext context, int index) {
    String value = '';
    if (index >= 0) {
      final int year = index + CalendarDate._gregorianCutoverYear;
      value = '$year';
    }
    return Spinner.defaultItemBuilder(context, value);
  }

  static Widget buildDayOfWeekHeader(BuildContext context, int index) {
    // Since we're only rendering the month, the year and day do not matter here.
    final int offset = firstDayOfWeek + index;
    final DateTime date = _monday.add(Duration(days: offset));
    return Padding(
      padding: EdgeInsets.fromLTRB(2, 2, 2, 4),
      child: Text(
        _dayOfWeekShort.format(date)[0],
        textAlign: TextAlign.center,
        style: DefaultTextStyle.of(context).style.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _monthController = SpinnerController();
    _yearController = SpinnerController();
    _monthController.selectedIndex = widget.initialMonth;
    _yearController.selectedIndex = widget.initialYear - CalendarDate._gregorianCutoverYear;
    _monthController.addListener(_updateCalendarRows);
    _yearController.addListener(_updateCalendarRows);
    _updateCalendarRows();
  }

  @override
  void didUpdateWidget(Calendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialMonth != oldWidget.initialMonth) {
      _monthController.selectedIndex = widget.initialMonth;
    }
    if (widget.initialYear != oldWidget.initialYear) {
      _yearController.selectedIndex = widget.initialYear - CalendarDate._gregorianCutoverYear;
    }
  }

  @override
  void dispose() {
    _monthController.removeListener(_updateCalendarRows);
    _yearController.removeListener(_updateCalendarRows);
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    _updateCalendarRows();
  }

  @override
  Widget build(BuildContext context) {
    return TablePane(
      horizontalRelativeSize: MainAxisSize.max,
      columns: List<TablePaneColumn>.filled(7, const TablePaneColumn()),
      children: <Widget>[
        TableRow(
          backgroundColor: const Color(0xffdddcd5),
          children: [
            TableCell(
              columnSpan: 7,
              child: Padding(
                padding: EdgeInsets.all(3),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                      child: Spinner(
                        length: 12,
                        isCircular: true,
                        sizeToContent: true,
                        itemBuilder: buildMonth,
                        controller: _monthController,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Spinner(
                      length: 9999 - CalendarDate._gregorianCutoverYear + 1,
                      itemBuilder: buildYear,
                      controller: _yearController,
                    ),
                  ],
                ),
              ),
            ),
            const EmptyTableCell(),
            const EmptyTableCell(),
            const EmptyTableCell(),
            const EmptyTableCell(),
            const EmptyTableCell(),
            const EmptyTableCell(),
          ],
        ),
        TableRow(
          children: List<Widget>.generate(7, (int index) => buildDayOfWeekHeader(context, index)),
        ),
        ..._calendarRows,
      ],
    );
  }
}
