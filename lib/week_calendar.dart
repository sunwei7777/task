import 'package:flutter/material.dart';

class WeekCalendar extends StatefulWidget {
  final String static;
  const WeekCalendar(this.static, {super.key});

  @override
  State<WeekCalendar> createState() => _WeekCalendarState();
}

class _WeekCalendarState extends State<WeekCalendar> {
  String _selectedView = '日';
  int _currentMonth = DateTime.now().month; // 当前显示的月份
  int _currentYear = DateTime.now().year; // 当前显示的年份
  int _currentWeekIndex = 1000; // 当前周索引，用于计算日期范围
  DateTime? _selectedDate; // 选中的日期

  @override
  Widget build(BuildContext context) {
    // 获取当前日期
    DateTime now = DateTime.now();
    // 计算本周的开始日期（周一）
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    return Container(
      margin: widget.static == 'static'
          ? EdgeInsets.only(top: 16)
          : EdgeInsets.zero,
      child: Column(
        children: [
          // 日历标题
          if (widget.static == 'dynamic')
            Padding(
              padding: EdgeInsets.only(bottom: 8, left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$_currentMonth月',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Color(0xFFEBEBEB),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedView = '日';
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 2,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: _selectedView == '日'
                                  ? Colors.white
                                  : Colors.transparent,
                              boxShadow: _selectedView == '日'
                                  ? [
                                      BoxShadow(
                                        color: Color(
                                          0xFF8D8D8D,
                                        ), // rgba(141,141,141,0.5)
                                        offset: Offset(0, 1), // 0px 1px
                                        blurRadius: 2, // 2px
                                        spreadRadius: 0, // 0px
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Text('日', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedView = '周';
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 2,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: _selectedView == '周'
                                  ? Colors.white
                                  : Colors.transparent,
                              boxShadow: _selectedView == '周'
                                  ? [
                                      BoxShadow(
                                        color: Color(
                                          0xFF8D8D8D,
                                        ), // rgba(141,141,141,0.5)
                                        offset: Offset(0, 1), // 0px 1px
                                        blurRadius: 2, // 2px
                                        spreadRadius: 0, // 0px
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Text('周', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedView = '月';
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 2,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: _selectedView == '月'
                                  ? Colors.white
                                  : Colors.transparent,
                              boxShadow: _selectedView == '月'
                                  ? [
                                      BoxShadow(
                                        color: Color(
                                          0xFF8D8D8D,
                                        ), // rgba(141,141,141,0.5)
                                        offset: Offset(0, 1), // 0px 1px
                                        blurRadius: 2, // 2px
                                        spreadRadius: 0, // 0px
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Text('月', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          _selectedView == '日'
              ? Column(
                  children: [
                    // 星期标题
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['一', '二', '三', '四', '五', '六', '日'].map((day) {
                        return Text(
                          day,
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.static == 'static'
                                ? Colors.white
                                : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.none,
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 8),
                    // 日期网格 - 支持一周一周的滑动
                    SizedBox(
                      height: 40,
                      child: PageView.builder(
                        physics: widget.static == 'static'
                            ? NeverScrollableScrollPhysics() // 静态模式不可滑动
                            : null,
                        controller: PageController(
                          initialPage: _currentWeekIndex,
                        ), // 从中间开始，避免左滑限制
                        onPageChanged: widget.static == 'static'
                            ? null // 静态模式不处理页面变化
                            : (index) {
                                setState(() {
                                  _currentWeekIndex = index;
                                  // 计算当前页面对应的周开始日期
                                  int weekOffset = index - 1000;
                                  DateTime weekStart = startOfWeek.add(
                                    Duration(days: weekOffset * 7),
                                  );

                                  // 更新当前显示的月份和年份
                                  _currentMonth = weekStart.month;
                                  _currentYear = weekStart.year;
                                });
                              },
                        itemBuilder: (context, index) {
                          // 计算当前页面对应的周开始日期
                          int weekOffset = index - 1000;
                          DateTime weekStart = startOfWeek.add(
                            Duration(days: weekOffset * 7),
                          );

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: List.generate(7, (dayIndex) {
                              DateTime date = weekStart.add(
                                Duration(days: dayIndex),
                              );
                              bool isToday =
                                  date.day == now.day &&
                                  date.month == now.month &&
                                  date.year == now.year;

                              bool isSelected =
                                  _selectedDate != null &&
                                  date.day == _selectedDate!.day &&
                                  date.month == _selectedDate!.month &&
                                  date.year == _selectedDate!.year;

                              return GestureDetector(
                                onTap: widget.static == 'static'
                                    ? null // 静态模式不可点击
                                    : () {
                                        // 日期点击事件
                                        print(
                                          '选中日期: ${date.year}-${date.month}-${date.day}',
                                        );
                                        setState(() {
                                          _selectedDate = date;
                                        });
                                      },
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Color(0xFFE3F2FD)
                                        : (isToday && _selectedDate == null)
                                        ? Color(0xFF477DF3)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Center(
                                    child: Text(
                                      isToday ? '今' : '${date.day}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        decoration: TextDecoration.none,
                                        color: isSelected
                                            ? Color(0xFF477DF3)
                                            : (isToday && _selectedDate == null)
                                            ? Colors.white
                                            : widget.static == 'static'
                                            ? Colors.white
                                            : Colors.grey[600],
                                        fontWeight: isToday || isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                    ),
                  ],
                )
              : _selectedView == '周'
              ? Padding(
                  padding: EdgeInsets.only(top: 8, left: 16, right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 左箭头
                      GestureDetector(
                        onTap: widget.static == 'static'
                            ? null // 静态模式不可点击
                            : () {
                                setState(() {
                                  _currentWeekIndex--;
                                });
                              },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[200],
                          ),
                          child: Icon(
                            Icons.chevron_left,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      // 日期范围
                      Text(
                        _getWeekDateRange(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 16),
                      // 右箭头
                      GestureDetector(
                        onTap: widget.static == 'static'
                            ? null // 静态模式不可点击
                            : () {
                                setState(() {
                                  _currentWeekIndex++;
                                });
                              },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[200],
                          ),
                          child: Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: EdgeInsets.only(top: 8, left: 16, right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 左箭头
                      GestureDetector(
                        onTap: widget.static == 'static'
                            ? null // 静态模式不可点击
                            : () {
                                setState(() {
                                  if (_currentMonth > 1) {
                                    _currentMonth--;
                                  } else {
                                    _currentMonth = 12;
                                    _currentYear--;
                                  }
                                });
                              },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[200],
                          ),
                          child: Icon(
                            Icons.chevron_left,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      // 日期范围
                      Text(
                        '$_currentYear年$_currentMonth月',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 16),
                      // 右箭头
                      GestureDetector(
                        onTap: widget.static == 'static'
                            ? null // 静态模式不可点击
                            : () {
                                setState(() {
                                  if (_currentMonth < 12) {
                                    _currentMonth++;
                                  } else {
                                    _currentMonth = 1;
                                    _currentYear++;
                                  }
                                });
                              },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[200],
                          ),
                          child: Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  // 获取当前周的日期范围
  String _getWeekDateRange() {
    int weekOffset = _currentWeekIndex - 1000;
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    DateTime weekStart = startOfWeek.add(Duration(days: weekOffset * 7));
    DateTime weekEnd = weekStart.add(Duration(days: 6));

    // 格式化为 "10月1 - 10月7日" 样式
    return '${weekStart.month}月${weekStart.day} - ${weekEnd.month}月${weekEnd.day}日';
  }

  @override
  void initState() {
    super.initState();
    // 初始化当前年份
    _currentYear = DateTime.now().year;
  }
}
