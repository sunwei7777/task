import 'package:flutter/material.dart';

import '../models/task.dart' show CalendarDay;

class WeekCalendar extends StatefulWidget {
  final String static;
  final ValueChanged<Map<String, String>>? onDateChanged;
  final List<CalendarDay> calendarData;

  const WeekCalendar(
    this.static, {
    super.key,
    this.onDateChanged,
    this.calendarData = const [],
  });

  @override
  State<WeekCalendar> createState() => _WeekCalendarState();
}

class _WeekCalendarState extends State<WeekCalendar> {
  static const Color _primary = Color(0xFF2F73FF);
  static const Color _cardBorder = Color(0xFFE1E5EC);
  static const Color _selectedBg = Color(0xFFEAF3FF);
  static const Color _textMain = Color(0xFF172033);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _hasReportColor = Color(0xFF13B886);
  static const Color _noReportColor = Color(0xFFFF7A1A);

  String _selectedView = '日';
  int _currentMonth = DateTime.now().month;
  int _currentYear = DateTime.now().year;
  int _currentWeekIndex = 1000;
  DateTime? _selectedDate;

  DateTime get _activeDate => _selectedDate ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _currentYear = now.year;
    _currentMonth = now.month;
  }

  void _notifyParent() {
    if (widget.onDateChanged == null) return;

    late String dateStr;
    late String timeDimension;
    late List<String> dateRange;

    if (_selectedView == '日') {
      final date = _activeDate;
      dateStr = _dateKey(date);
      dateRange = [dateStr];
      timeDimension = 'day';
    } else if (_selectedView == '周') {
      final weekStart = _currentWeekStart();
      final selectedDate = _isDateInWeek(_activeDate, weekStart)
          ? _activeDate
          : weekStart;
      dateStr = _dateKey(selectedDate);
      dateRange = List.generate(
        7,
        (i) => _dateKey(weekStart.add(Duration(days: i))),
      );
      timeDimension = 'week';
    } else {
      final firstDay = DateTime(_currentYear, _currentMonth, 1);
      final selectedDate =
          _isDateInMonth(_activeDate, _currentYear, _currentMonth)
          ? _activeDate
          : firstDay;
      dateStr = _dateKey(selectedDate);
      final daysInMonth = DateTime(_currentYear, _currentMonth + 1, 0).day;
      dateRange = List.generate(
        daysInMonth,
        (i) => '$_currentYear-${_two(_currentMonth)}-${_two(i + 1)}',
      );
      timeDimension = 'month';
    }

    widget.onDateChanged!({
      'timeDimension': timeDimension,
      'date': dateStr,
      'dateRange': dateRange.join(','),
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.static == 'static') {
      return _buildStaticWeek();
    }

    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Column(
        children: [
          _buildTopBar(),
          const SizedBox(height: 12),
          if (_selectedView == '日')
            _buildDayView()
          else if (_selectedView == '周')
            _buildWeekView()
          else
            _buildMonthView(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '汇报日历',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _textMain,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: const Color(0xFFF0F2F5),
          ),
          child: Row(children: ['日', '周', '月'].map(_buildViewTab).toList()),
        ),
      ],
    );
  }

  Widget _buildViewTab(String value) {
    final selected = _selectedView == value;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _selectedView = value;
          if (value == '日') {
            _currentYear = _activeDate.year;
            _currentMonth = _activeDate.month;
          } else if (value == '周') {
            final today = _todayDate();
            final weekStart = _currentWeekStart();
            _selectedDate = _isDateInWeek(today, weekStart) ? today : weekStart;
            _currentYear = weekStart.year;
            _currentMonth = weekStart.month;
          } else {
            final today = _todayDate();
            _selectedDate = _isDateInMonth(today, _currentYear, _currentMonth)
                ? today
                : DateTime(_currentYear, _currentMonth, 1);
          }
        });
        _notifyParent();
      },
      child: Container(
        width: 36,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x1F000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: selected ? _primary : _textMuted,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDayView() {
    final date = _activeDate;
    return Column(
      children: [
        _buildNavHeader(
          previousText: '上一日',
          title: '${date.year}年${date.month}月${date.day}日',
          nextText: '下一日',
          onPrevious: () => _changeDay(-1),
          onNext: () => _changeDay(1),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 62,
          child: _buildDateCell(date, selected: true, compact: true),
        ),
      ],
    );
  }

  Widget _buildWeekView() {
    final weekStart = _currentWeekStart();
    final weekEnd = weekStart.add(const Duration(days: 6));
    final dates = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    return Column(
      children: [
        _buildNavHeader(
          previousText: '上一周',
          title:
              '${_two(weekStart.month)}-${_two(weekStart.day)} - ${_two(weekEnd.month)}-${_two(weekEnd.day)}',
          nextText: '下一周',
          onPrevious: () => _changeWeek(-1),
          onNext: () => _changeWeek(1),
        ),
        const SizedBox(height: 12),
        _buildWeekdayRow(),
        const SizedBox(height: 6),
        Row(
          children: dates
              .map(
                (date) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: _buildDateCell(
                      date,
                      selected: _isSameDate(date, _activeDate),
                      onTap: () => _selectDate(date),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildMonthView() {
    final firstDay = DateTime(_currentYear, _currentMonth, 1);
    final daysInMonth = DateTime(_currentYear, _currentMonth + 1, 0).day;
    final leadingBlanks = firstDay.weekday - 1;
    final cells = leadingBlanks + daysInMonth;
    final rowCount = (cells / 7).ceil();

    return Column(
      children: [
        _buildNavHeader(
          previousText: '上一月',
          title: '$_currentYear年$_currentMonth月',
          nextText: '下一月',
          onPrevious: () => _changeMonth(-1),
          onNext: () => _changeMonth(1),
        ),
        const SizedBox(height: 12),
        _buildWeekdayRow(),
        const SizedBox(height: 6),
        ...List.generate(rowCount, (row) {
          return Padding(
            padding: EdgeInsets.only(bottom: row == rowCount - 1 ? 0 : 6),
            child: Row(
              children: List.generate(7, (column) {
                final index = row * 7 + column;
                final dayNumber = index - leadingBlanks + 1;
                final hasDate = dayNumber >= 1 && dayNumber <= daysInMonth;
                final date = hasDate
                    ? DateTime(_currentYear, _currentMonth, dayNumber)
                    : null;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: hasDate
                        ? _buildDateCell(
                            date!,
                            selected: _isSameDate(date, _activeDate),
                            onTap: () => _selectDate(date),
                          )
                        : _buildEmptyCell(),
                  ),
                );
              }),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildNavHeader({
    required String previousText,
    required String title,
    required String nextText,
    required VoidCallback onPrevious,
    required VoidCallback onNext,
  }) {
    return Row(
      children: [
        _buildTextArrow(previousText, Icons.chevron_left, onPrevious, true),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _textMain,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _buildTextArrow(nextText, Icons.chevron_right, onNext, false),
      ],
    );
  }

  Widget _buildTextArrow(
    String text,
    IconData icon,
    VoidCallback onTap,
    bool iconBefore,
  ) {
    final children = [
      Icon(icon, color: _primary, size: 18),
      const SizedBox(width: 2),
      Text(
        text,
        style: const TextStyle(
          color: _primary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    ];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 76,
        height: 32,
        child: Row(
          mainAxisAlignment: iconBefore
              ? MainAxisAlignment.start
              : MainAxisAlignment.end,
          children: iconBefore ? children : children.reversed.toList(),
        ),
      ),
    );
  }

  Widget _buildWeekdayRow() {
    return Row(
      children: ['一', '二', '三', '四', '五', '六', '日']
          .map(
            (day) => Expanded(
              child: Text(
                day,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildDateCell(
    DateTime date, {
    required bool selected,
    bool compact = false,
    VoidCallback? onTap,
  }) {
    final dotColor = _statusDotColor(date);
    final height = compact ? 62.0 : 54.0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? _selectedBg : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? _primary : _cardBorder,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (compact) ...[
              Text(
                _weekdayText(date),
                style: const TextStyle(color: _textMuted, fontSize: 12),
              ),
              const SizedBox(height: 5),
            ],
            Text(
              '${date.day}',
              style: const TextStyle(
                color: _textMain,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: 6,
              height: 6,
              child: dotColor == null
                  ? null
                  : DecoratedBox(
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCell() {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _cardBorder, width: 1),
      ),
    );
  }

  Widget _buildStaticWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final dates = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['一', '二', '三', '四', '五', '六', '日']
                .map(
                  (day) => Text(
                    day,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: dates.map((date) {
              final isToday = _isSameDate(date, now);
              return Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isToday ? const Color(0xFF477DF3) : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  isToday ? '今' : '${date.day}',
                  style: TextStyle(
                    fontSize: 16,
                    decoration: TextDecoration.none,
                    color: Colors.white,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _changeDay(int offset) {
    final next = _activeDate.add(Duration(days: offset));
    setState(() {
      _selectedDate = DateTime(next.year, next.month, next.day);
      _currentYear = next.year;
      _currentMonth = next.month;
    });
    _notifyParent();
  }

  void _changeWeek(int offset) {
    setState(() {
      _currentWeekIndex += offset;
      final weekStart = _currentWeekStart();
      _selectedDate = weekStart;
      _currentYear = weekStart.year;
      _currentMonth = weekStart.month;
    });
    _notifyParent();
  }

  void _changeMonth(int offset) {
    setState(() {
      final next = DateTime(_currentYear, _currentMonth + offset, 1);
      _currentYear = next.year;
      _currentMonth = next.month;
      _selectedDate = next;
    });
    _notifyParent();
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = DateTime(date.year, date.month, date.day);
    });
    _notifyParent();
  }

  DateTime _currentWeekStart() {
    final now = DateTime.now();
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    return startOfWeek.add(Duration(days: (_currentWeekIndex - 1000) * 7));
  }

  Color? _statusDotColor(DateTime date) {
    final key = _dateKey(date);
    for (final item in widget.calendarData) {
      if (item.date == key) {
        if (!item.hasReport && _isAfterToday(date)) return null;
        return item.hasReport ? _hasReportColor : _noReportColor;
      }
    }
    return null;
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isDateInWeek(DateTime date, DateTime weekStart) {
    final day = DateTime(date.year, date.month, date.day);
    final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final end = start.add(const Duration(days: 6));
    return !day.isBefore(start) && !day.isAfter(end);
  }

  bool _isDateInMonth(DateTime date, int year, int month) {
    return date.year == year && date.month == month;
  }

  bool _isAfterToday(DateTime date) {
    return DateTime(date.year, date.month, date.day).isAfter(_todayDate());
  }

  DateTime _todayDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${_two(date.month)}-${_two(date.day)}';
  }

  String _two(int value) => value.toString().padLeft(2, '0');

  String _weekdayText(DateTime date) {
    return ['一', '二', '三', '四', '五', '六', '日'][date.weekday - 1];
  }
}
