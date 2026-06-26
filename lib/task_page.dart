import 'package:flutter/material.dart';
import 'package:flutter_application_1/search_page.dart';
import 'package:flutter_application_1/store/task_controller.dart';
import 'package:flutter_application_1/task/select_task.dart';
import 'package:get/get.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({Key? key}) : super(key: key);

  @override
  TaskPageState createState() => TaskPageState();
}

class TaskPageState extends State<TaskPage> {
  void refresh() {
    _taskController.fetchAllTaskTypeCounts(startTime: '', endTime: '');
  }

  int _currentTab = 0;
  final TaskController _taskController = Get.find<TaskController>();

  @override
  void initState() {
    super.initState();
    _taskController.fetchAllTaskTypeCounts(
      startTime: '', //fmtDate(_dateStart),
      endTime: '', //fmtDate(_dateEnd),
    );
  }

  final DateTime _dateEnd = DateTime.now();
  DateTime get _dateStart => _dateEnd.subtract(Duration(days: 7));
  String get _dateRange =>
      '${_dateStart.month.toString().padLeft(2, '0')}-${_dateStart.day.toString().padLeft(2, '0')}~${_dateEnd.month.toString().padLeft(2, '0')}-${_dateEnd.day.toString().padLeft(2, '0')}';

  String fmtDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: Image(image: AssetImage('lib/assets/logo.png')),
                  ),
                ),
                SizedBox(width: 4),
                Text(
                  'Task',
                  style: TextStyle(
                    color: Color(0xFF001111),
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
            Text('任务', style: TextStyle(fontSize: 18, color: Colors.black)),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(0.5),
          child: Container(color: Colors.grey[300], height: 0.5),
        ),
      ),
      body: Column(
        children: [
          // 标签页
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFEDF7FE),
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: Row(
              children: [
                _buildTab('我的任务', 0),
                _buildTab('我指派的', 1),
                _buildTab('抄送我的', 2),
              ],
            ),
          ),
          // 我的任务标题和全部按钮
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SelectTask(title: '全部任务', onTaskSelected: (int p1) {}),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFDCF0FD), Colors.white],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '我的任务',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  Row(
                    children: [
                      Text(
                        '全部',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 13,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 内容区域
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _taskController.fetchAllTaskTypeCounts(
                  startTime: '', endTime: ''),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(12),
                child: Column(
                children: [
                  // 订单任务
                  Obx(() {
                    final c = _taskController.taskTypeCounts[2];
                    return _buildTaskCard(
                      title: '订单任务',
                      color: Color(0xFF0073FF),
                      stats: [
                        {
                          'title': '待处理',
                          'count': '${c?.pendingCount ?? 0}',
                          'color': Colors.black,
                        },
                        {
                          'title': '已超时',
                          'count': '${c?.overtimeCount ?? 0}',
                          'color': Colors.red,
                        },
                        {
                          'title': '已完成',
                          'count': '${c?.completedCount ?? 0}',
                          'color': Color(0xFF0073FF),
                        },
                        {
                          'title': '已取消',
                          'count': '${c?.cancelledCount ?? 0}',
                          'color': Colors.black.withOpacity(0.3),
                        },
                      ],
                    );
                  }),
                  SizedBox(height: 16),

                  // 项目任务
                  Obx(() {
                    final c = _taskController.taskTypeCounts[1];
                    return _buildTaskCard(
                      title: '项目任务',
                      color: Color(0xFF91D5FF),
                      stats: [
                        {
                          'title': '待处理',
                          'count': '${c?.pendingCount ?? 0}',
                          'color': Colors.black,
                        },
                        {
                          'title': '已超时',
                          'count': '${c?.overtimeCount ?? 0}',
                          'color': Colors.red,
                        },
                        {
                          'title': '已完成',
                          'count': '${c?.completedCount ?? 0}',
                          'color': Color(0xFF0073FF),
                        },
                        {
                          'title': '已取消',
                          'count': '${c?.cancelledCount ?? 0}',
                          'color': Colors.black.withOpacity(0.3),
                        },
                      ],
                    );
                  }),
                  SizedBox(height: 16), // 为浮动按钮留出空间

                  Obx(() {
                    final c = _taskController.taskTypeCounts[9];
                    return _buildTaskCard(
                      title: '打样任务',
                      color: Color(0xFFD4C2FE),
                      stats: [
                        {
                          'title': '待处理',
                          'count': '${c?.pendingCount ?? 0}',
                          'color': Colors.black,
                        },
                        {
                          'title': '已超时',
                          'count': '${c?.overtimeCount ?? 0}',
                          'color': Colors.red,
                        },
                        {
                          'title': '已完成',
                          'count': '${c?.completedCount ?? 0}',
                          'color': Color(0xFF0073FF),
                        },
                        {
                          'title': '已取消',
                          'count': '${c?.cancelledCount ?? 0}',
                          'color': Colors.black.withOpacity(0.3),
                        },
                      ],
                    );
                  }),
                  SizedBox(height: 16),

                  // 其他任务
                  Obx(() {
                    final c = _taskController.otherTaskCounts.value;
                    return _buildTaskCard(
                      title: '其他任务',
                      color: Color(0xFF9DE2D0),
                      stats: [
                        {
                          'title': '周期',
                          'count': '${c.periodic}',
                          'color': Colors.black,
                        },
                        {
                          'title': '临时',
                          'count': '${c.temporary}',
                          'color': Colors.black,
                        },
                        {
                          'title': '会议',
                          'count': '${c.meeting}',
                          'color': Colors.black,
                        },
                        {
                          'title': '外派',
                          'count': '${c.dispatch}',
                          'color': Colors.black,
                        },
                      ],
                    );
                  }),
                ],
              ),
            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // setState(() {
          //   _currentTab = index;
          // });
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('模块开发中，敬请期待…'),
              content: Text('相关功能请至后台操作'),
              titleTextStyle: TextStyle(fontSize: 20, color: Colors.black),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('确定'),
                ),
              ],
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _currentTab == index ? Colors.white : Colors.transparent,
            border: _currentTab == index
                ? Border(bottom: BorderSide(color: Color(0xFF0073FF), width: 2))
                : null,
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: _currentTab == index ? Color(0xFF0073FF) : Colors.black,
              fontWeight: _currentTab == index
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard({
    required String title,
    required Color color,
    required List<Map<String, dynamic>> stats,
    bool showAlert = false,
    String? alertText,
  }) {
    return GestureDetector(
      onTap: () {
        // 处理点击事件
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SelectTask(title: title, onTaskSelected: (int p1) {}),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(color: Colors.grey[200]!, blurRadius: 4, spreadRadius: 2),
          ],
        ),
        child: Column(
          children: [
            // 卡片头部
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          color: title == '订单任务' ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 12),
                      // if (title == '其他任务')
                      //   Container(
                      //     padding: EdgeInsets.symmetric(
                      //       horizontal: 8,
                      //       vertical: 2,
                      //     ),
                      //     decoration: BoxDecoration(
                      //       // ignore: deprecated_member_use
                      //       color: Colors.white.withOpacity(0.3),
                      //       borderRadius: BorderRadius.circular(4),
                      //     ),
                      //     child: Row(
                      //       children: [
                      //         Text(
                      //           '最近7天',
                      //           style: TextStyle(
                      //             fontSize: 12,
                      //             color: title == '订单任务'
                      //                 ? Colors.white
                      //                 : Colors.black,
                      //           ),
                      //         ),
                      //         // Icon(
                      //         //   Icons.keyboard_arrow_down,
                      //         //   size: 16,
                      //         //   color: title == '订单任务'
                      //         //       ? Colors.white
                      //         //       : Colors.black,
                      //         // ),
                      //       ],
                      //     ),
                      //   ),
                      // if (title == '其他任务') SizedBox(width: 8),
                      // if (title == '其他任务')
                      //   Text(
                      //     _dateRange,
                      //     style: TextStyle(
                      //       fontSize: 12,
                      //       color: title == '订单任务'
                      //           ? Colors.white
                      //           : Colors.black,
                      //     ),
                      //   ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: title == '订单任务' ? Colors.white : Colors.black,
                  ),
                ],
              ),
            ),

            // 统计数据
            Container(
              margin: EdgeInsets.only(left: 12, right: 12, bottom: 12),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: stats.map((stat) {
                      return Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              Text(
                                stat['count'],
                                style: TextStyle(
                                  fontSize: 20,
                                  color: stat['color'],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (showAlert &&
                                  alertText != null &&
                                  stat['title'] == '已延期')
                                Positioned(
                                  bottom: -35,
                                  child: Image.asset(
                                    'lib/assets/sj.png',
                                    width: 16,
                                    height: 16,
                                  ),
                                ),
                              if (stat.containsKey('badge'))
                                Positioned(
                                  top: -8,
                                  right: -20,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      stat['badge'],
                                      style: TextStyle(
                                        fontSize: 8,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            stat['title'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                  // 提示信息
                  if (showAlert && alertText != null)
                    Container(
                      height: 24,
                      margin: EdgeInsets.only(left: 12, right: 12, top: 9),
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Color(0xFFffECEC),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Center(
                                  child: Text(
                                    '3',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Text(alertText, style: TextStyle(fontSize: 12)),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Row(
                              children: [
                                Text(
                                  '去汇报',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF0073FF),
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 12,
                                  color: Color(0xFF0073FF),
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
          ],
        ),
      ),
    );
  }
}
