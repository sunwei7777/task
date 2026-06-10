import 'package:flutter/material.dart';
import 'package:flutter_application_1/draw_progress.dart';
import 'package:flutter_application_1/report/report_item.dart';
import 'package:flutter_application_1/services/task_service.dart';
import 'package:flutter_application_1/task/select_task_bottom.dart';
import 'package:flutter_application_1/utils/week_calendar.dart';
import '../models/task.dart' hide ReportItem;

class IndividualStatistics extends StatefulWidget {
  const IndividualStatistics({super.key});

  @override
  State<IndividualStatistics> createState() => _IndividualStatisticsState();
}

class _IndividualStatisticsState extends State<IndividualStatistics> {
  final TaskService _taskService = TaskService();
  MyReportResult? _data;
  bool _isLoading = true;
  String _timeDimension = 'day';
  String _date = '';
  List<String> _dateRange = [];

  @override
  void initState() {
    super.initState();
    _date = _todayStr();
    _dateRange = [_todayStr()];
    _loadData();
  }

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadData({
    String? timeDimension,
    String? date,
    List<String>? dateRange,
  }) async {
    if (timeDimension != null) _timeDimension = timeDimension;
    if (date != null) _date = date;
    if (dateRange != null) _dateRange = dateRange;
    setState(() => _isLoading = true);
    final result = await _taskService.fetchMyReport(
      timeDimension: _timeDimension,
      date: _date,
      dateRange: _dateRange,
    );
    if (mounted) {
      setState(() {
        _data = result;
        _isLoading = false;
      });
    }
  }

  String _formatOnlineTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    return '${hours}小时${minutes}分';
  }

  String _formatSelectedDateLabel() {
    final parts = _date.split('-');
    if (parts.length != 3) return _date;

    final month = int.tryParse(parts[1]) ?? 0;
    final day = int.tryParse(parts[2]) ?? 0;
    if (month == 0 || day == 0) return _date;

    return '$month-${day.toString().padLeft(2, '0')}';
  }

  String _formatClockText(String? value) {
    if (value == null || value.trim().isEmpty) return '--';
    final text = value.trim();
    if (text.contains(' ')) {
      return text.split(' ').last;
    }
    if (text.contains('T')) {
      final parsed = DateTime.tryParse(text);
      if (parsed != null) {
        return '${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}:${parsed.second.toString().padLeft(2, '0')}';
      }
    }
    return text;
  }

  Widget _buildTimeSummaryCards(MyReportResult? data) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Row(
        children: [
          Expanded(
            child: _buildTimeSummaryCard(
              title: '总在线时长',
              value: data != null
                  ? _formatOnlineTime(data.timeStats.totalOnlineTime)
                  : '--',
              color: Color(0xFFD5F7E5),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: _buildTimeSummaryCard(
              title: '已汇报时长',
              value: data != null
                  ? _formatOnlineTime(data.timeStats.reportedTime)
                  : '--',
              color: Color(0xFFDCEBFF),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: _buildTimeSummaryCard(
              title: '已汇报任务数',
              value: data != null ? '${data.timeStats.reportedTasks}' : '--',
              color: Color(0xFFEBD7FF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSummaryCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      height: 88,
      padding: EdgeInsets.fromLTRB(12, 12, 8, 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Color(0xFF5E6A7D), fontSize: 13),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Color(0xFF09152F),
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    return Scaffold(
      backgroundColor: Color(0xFFEEEEEE),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        title: Text('个人统计', style: TextStyle(fontSize: 18)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(bottom: 12),
            child: WeekCalendar(
              'dynamic',
              calendarData: data?.calendarData ?? const [],
              onDateChanged: (params) {
                _loadData(
                  timeDimension: params['timeDimension'],
                  date: params['date'],
                  dateRange: params['dateRange']!.split(','),
                );
              },
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                if (_isLoading)
                  Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (!_isLoading) ...[
                  _buildTimeSummaryCards(data),
                  Card(
                    color: Colors.white,
                    margin: EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    shadowColor: Colors.grey.withOpacity(0.1),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '时间统计 (${_formatSelectedDateLabel()})',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 16),
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color(0xFFE9F6F3),
                              border: Border(
                                bottom: BorderSide(
                                  color: Color(0x77DDDBDB),
                                  width: 0.5,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('在线总时长'),
                                Text(
                                  data != null
                                      ? _formatOnlineTime(
                                          data.dailyStats.onlineTime,
                                        )
                                      : '--',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF09152F),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Color(0xFFE9F6F3)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '登入时间  ${_formatClockText(data?.dailyStats.loginTime)}',
                                  style: TextStyle(fontSize: 12),
                                ),
                                Text(
                                  '登出时间  ${_formatClockText(data?.dailyStats.logoutTime)}',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    color: Colors.white,
                    margin: EdgeInsets.only(left: 12, right: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    shadowColor: Colors.grey.withOpacity(0.1),
                    child: Container(
                      padding: EdgeInsets.only(left: 12.0, right: 12.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('任务统计', style: TextStyle(fontSize: 16)),
                              ElevatedButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (cotext) {
                                      return SelectTaskBottom(
                                        isReport: 'report',
                                        onTaskSelected: (int index) {
                                          print(index);
                                        },
                                      );
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF0073FF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  minimumSize: Size(0, 32),
                                ),
                                child: Text(
                                  '补汇报',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.0),
                          Container(
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Color(0xFFEFF5FF),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('汇报时长'),
                                Text(
                                  data != null
                                      ? _formatOnlineTime(
                                          data.dailyStats.reportedTime,
                                        )
                                      : '--',
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16.0),
                          Center(
                            child: DrawProgress(
                              total: data != null
                                  ? (data.dailyStats.completedCount +
                                            data.dailyStats.inProgressCount +
                                            data.dailyStats.delayedCount)
                                        .toDouble()
                                  : 100,
                              completed: (data?.dailyStats.completedCount ?? 0)
                                  .toDouble(),
                              inProgress:
                                  (data?.dailyStats.inProgressCount ?? 0)
                                      .toDouble(),
                              delayed: (data?.dailyStats.delayedCount ?? 0)
                                  .toDouble(),
                              totalTimeText: data != null
                                  ? '${data.dailyStats.reportCount}'
                                  : '0',
                              totalCountText: '汇报数量',
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: 2,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  bottom: 10,
                                  left: 0,
                                  right: 0,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.circle,
                                            size: 12,
                                            color: Colors.green,
                                          ),
                                          SizedBox(width: 8.0),
                                          Text(
                                            '完成 ${data?.dailyStats.completedCount ?? 0}',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: 16.0),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.circle,
                                            size: 12,
                                            color: Colors.blue,
                                          ),
                                          SizedBox(width: 8.0),
                                          Text(
                                            '进行中 ${data?.dailyStats.inProgressCount ?? 0}',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: 16.0),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.circle,
                                            size: 12,
                                            color: Colors.red,
                                          ),
                                          SizedBox(width: 8.0),
                                          Text(
                                            '延误 ${data?.dailyStats.delayedCount ?? 0}',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (data != null && data.reportDataList.isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('全部汇报 (${data.reportDataList.length})'),
                        ],
                      ),
                    ),
                    ...data.reportDataList.map(
                      (item) => Column(
                        children: [
                          ReportItem(data: item),
                          SizedBox(height: 10.0),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 16.0),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
