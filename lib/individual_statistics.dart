import 'package:flutter/material.dart';
import 'package:flutter_application_1/draw_progress.dart';
import 'package:flutter_application_1/report_item.dart';
import 'package:flutter_application_1/select_task_bottom.dart';
import 'package:flutter_application_1/week_calendar.dart';

class IndividualStatistics extends StatefulWidget {
  const IndividualStatistics({super.key});

  @override
  State<IndividualStatistics> createState() => _IndividualStatisticsState();
}

class _IndividualStatisticsState extends State<IndividualStatistics> {
  List<Report> reports = [
    Report(
      title: '外派水星检查',
      creator: '陈圆圆',
      progress: '80%',
      reportType: '正常',
      duration: '3小时25分',
      startTime: '11-02 09:11:00',
      endTime: '12:31',
      submitter: '张三',
      reportTime: '11-02 06:00:31',
    ),
    Report(
      title: '外派水星检查1',
      creator: '陈圆圆',
      progress: '80%',
      reportType: '正常',
      duration: '3小时25分',
      startTime: '11-02 09:11:00',
      endTime: '12:31',
      submitter: '张三',
      reportTime: '11-02 06:00:31',
    ),
    Report(
      title: '外派水星检查2',
      creator: '陈圆圆',
      progress: '80%',
      reportType: '正常',
      duration: '3小时25分',
      startTime: '11-02 09:11:00',
      endTime: '12:31',
      submitter: '张三',
      reportTime: '11-02 06:00:31',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEEEEEE),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        title: Text('个人统计', style: TextStyle(fontSize: 18)),
        centerTitle: true,
        // leading: IconButton(
        //   icon: Icon(
        //     Icons.arrow_back_ios, // 图标类型
        //     size: 20, // 图标大小
        //   ),
        //   onPressed: () => Navigator.pop(context),
        // ),
      ),
      body: ListView(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(bottom: 12),
            child: WeekCalendar('dynamic'),
          ),
          Card(
            color: Colors.white,
            margin: EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            // ignore: deprecated_member_use
            shadowColor: Colors.grey.withOpacity(0.1),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('时间统计', style: TextStyle(fontSize: 16)),
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
                      children: [Text('在线总时长'), Text('2小时57分')],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Color(0xFFE9F6F3)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('登入时间 09:31:08', style: TextStyle(fontSize: 12)),
                        Text('登出时间 17:28:08', style: TextStyle(fontSize: 12)),
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
            // ignore: deprecated_member_use
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
                          style: TextStyle(fontSize: 14, color: Colors.white),
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
                      children: [Text('汇报时长'), Text('1小时57分')],
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Center(
                    child: DrawProgress(
                      total: 100,
                      completed: 50,
                      inProgress: 20,
                      delayed: 30,
                      totalTimeText: '14',
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
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 12,
                                    color: Colors.green,
                                  ),
                                  SizedBox(width: 8.0),
                                  Text('完成 1', style: TextStyle(fontSize: 12)),
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
                                  Text('进行中 2', style: TextStyle(fontSize: 12)),
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
                                  Text('延误 6', style: TextStyle(fontSize: 12)),
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
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('全部汇报 (72)'),
                // IconButton(icon: Icon(Icons.filter_list), onPressed: () {}),
                Row(
                  children: [
                    Icon(
                      Icons.filter_alt_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 4),
                    Text(
                      '筛选',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ...reports.map(
            (report) => Column(
              children: [
                ReportItem(
                  title: report.title,
                  creator: report.creator,
                  progress: report.progress,
                  reportType: report.reportType,
                  duration: report.duration,
                  startTime: report.startTime,
                  endTime: report.endTime,
                  submitter: report.submitter,
                  reportTime: report.reportTime,
                ),
                SizedBox(height: 10.0),
              ],
            ),
          ),
          SizedBox(height: 16.0),
        ],
      ),
    );
  }
}

class Report {
  final String title;
  final String creator;
  final String progress;
  final String reportType;
  final String duration;
  final String startTime;
  final String endTime;
  final String submitter;
  final String reportTime;

  Report({
    required this.title,
    required this.creator,
    required this.progress,
    required this.reportType,
    required this.duration,
    required this.startTime,
    required this.endTime,
    required this.submitter,
    required this.reportTime,
  });
}
