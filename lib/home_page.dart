import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/individual_statistics.dart';
import 'package:flutter_application_1/report_details.dart';
import 'package:flutter_application_1/select_task_bottom.dart';
import 'package:flutter_application_1/week_calendar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  Duration _duration = Duration();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _setSystemUIOverlayStyle();
  }

  void _setSystemUIOverlayStyle() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 背景图
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Color(0xFF185DF2),
            image: DecorationImage(
              image: AssetImage('lib/assets/homebg.png'),
              fit: BoxFit.contain,
              alignment: Alignment.topCenter,
            ),
          ),
        ),
        Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 34, left: 14, right: 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Image(image: AssetImage('lib/assets/logo.png')),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '企业名称',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    padding: EdgeInsets.only(left: 10),
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(0xFF2D3767),
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Image(
                            image: AssetImage('lib/assets/user.png'),
                          ),
                        ),
                        SizedBox(width: 4),
                        Text.rich(
                          TextSpan(
                            children: [
                              // 姓名部分
                              TextSpan(
                                text: '张三',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              // 电话号码部分
                              TextSpan(
                                text: '（187****4567）',
                                style: TextStyle(
                                  // ignore: deprecated_member_use
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14, // 较小字体
                                  fontWeight: FontWeight.normal,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => IndividualStatistics(),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(0xFF477DF3),
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        boxShadow: [
                          // 外部阴影: 0px 2px 4px 0px rgba(193,193,193,0.73)
                          BoxShadow(
                            color: Color(0x29150E9C), // rgba(21, 14, 156, 0.16)
                            offset: Offset(0, 2), // 0px 2px
                            blurRadius: 6, // 6px
                            spreadRadius: 0, // 0px
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: Center(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '今日在线',
                                      style: TextStyle(
                                        // ignore: deprecated_member_use
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 14, // 较小字体
                                        fontWeight: FontWeight.normal,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    WidgetSpan(
                                      child: SizedBox(width: 4),
                                      alignment: PlaceholderAlignment
                                          .middle, // 添加8像素间距
                                    ),
                                    TextSpan(
                                      text: '2',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '小时',
                                      style: TextStyle(
                                        // ignore: deprecated_member_use
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 14, // 较小字体
                                        fontWeight: FontWeight.normal,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '58',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '分',
                                      style: TextStyle(
                                        // ignore: deprecated_member_use
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 14, // 较小字体
                                        fontWeight: FontWeight.normal,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            child: Text(
                              "|",
                              style: TextStyle(
                                // ignore: deprecated_member_use
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14, // 较小字体
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '今日汇报',
                                          style: TextStyle(
                                            // ignore: deprecated_member_use
                                            color: Colors.white.withOpacity(
                                              0.8,
                                            ),
                                            fontSize: 14, // 较小字体
                                            fontWeight: FontWeight.normal,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                        WidgetSpan(
                                          child: SizedBox(width: 4),
                                          alignment: PlaceholderAlignment
                                              .middle, // 添加8像素间距
                                        ),
                                        TextSpan(
                                          text: '0/8',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14,
                                    // ignore: deprecated_member_use
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  WeekCalendar('static'),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 10),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFFE3F1FF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16), // 上左圆角
                    topRight: Radius.circular(16), // 上右圆角
                  ),
                ),
                child: Container(
                  margin: EdgeInsets.only(
                    top: 12,
                    left: 10,
                    right: 10,
                    bottom: 10,
                  ),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xFFffffff),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    boxShadow: [
                      // 外部阴影: 0px 2px 4px 0px rgba(193,193,193,0.73)
                      BoxShadow(
                        color: Color(0xBAC1C1C1), // rgba(193,193,193,0.73)
                        offset: Offset(0, 2), // 0px 2px
                        blurRadius: 4, // 4px
                        spreadRadius: 0, // 0px
                      ),
                      // 内阴影: inset 0px -1px 0px 0px rgba(231,233,235,0.6)
                      BoxShadow(
                        color: Color(0x99E7E9EB), // rgba(231,233,235,0.6)
                        offset: Offset(0, -1), // 0px -1px
                        blurRadius: 0, // 0px
                        spreadRadius: 0, // 0px
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (cotext) {
                              return SelectTaskBottom(
                                onTaskSelected: (int index) {
                                  print(index);
                                },
                              );
                            },
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xFFE7E9EB),
                                width: .5,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Image(
                                        image: AssetImage('lib/assets/yj.png'),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      '选择任务开始工作',
                                      style: TextStyle(
                                        // ignore: deprecated_member_use
                                        color: Color(0xFF208BDE),
                                        fontSize: 14, // 较小字体
                                        fontWeight: FontWeight.normal,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  // ignore: deprecated_member_use
                                  color: Color(0xFFB2B2B2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          switchInCurve: Curves.easeInOut,
                          switchOutCurve: Curves.easeInOut,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          child: _currentIndex == 0
                              ? KeyedSubtree(
                                  key: ValueKey('start_time'),
                                  child: _buildStartTime(),
                                )
                              : KeyedSubtree(
                                  key: ValueKey('in_progress'),
                                  child: _buildInProgress(),
                                ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: Center(
                          child: Text(
                            '最早 0:00 - 最晚 23:59',
                            style: TextStyle(
                              color: Color(0xFF999999),
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 开始
  Widget _buildStartTime() {
    return Center(
      child: GestureDetector(
        onTap: () {
          _startTimer();
        },
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            SizedBox(width: 150, height: 150),
            Positioned(
              right: -20,
              bottom: -14,
              child: Image.asset('lib/assets/bee.png', width: 170, height: 170),
            ),
            Text(
              '开始工作',
              style: TextStyle(
                color: Color(0xFF001111),
                fontSize: 16,
                fontWeight: FontWeight.normal,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 进行中
  Widget _buildInProgress() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: _currentIndex == 1
                ? Color(0xFFF0EFEE)
                : Color(0xFFFFF1E4), // 浅灰色背景
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min, // 内容自适应宽度
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _currentIndex == 1 ? '计时中' : '已暂停',
                style: TextStyle(
                  color: _currentIndex == 1
                      ? Color(0xFF008863)
                      : Color(0xFFFF7B00),
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  decoration: TextDecoration.none,
                ),
              ),
              SizedBox(width: 10),
              Text(
                _formatDuration(_duration),
                style: TextStyle(
                  color: Color(0xFF3D3F5F),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Image.asset(
          _currentIndex == 1 ? 'lib/assets/bee.gif' : 'lib/assets/beesleep.png',
          width: 90,
          height: 90,
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: _currentIndex != 1
                  ? _startTimer
                  : () => _stopTimer('pause'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentIndex == 1
                    ? Color(0xFFFF7B00)
                    : Color(0xFF1BA17D),
                padding: EdgeInsets.symmetric(horizontal: 40),
              ),
              child: Text(
                _currentIndex != 1 ? '继续' : '暂停',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () => _stopTimer('end'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3895F2),
                padding: EdgeInsets.symmetric(horizontal: 40),
              ),
              child: Text(
                '结束',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _startTimer() {
    if (_currentIndex != 1) {
      _currentIndex = 1;
      setState(() {});
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          _duration += Duration(seconds: 1);
        });
      });
    }
  }

  void _stopTimer(String type) {
    _currentIndex = 2;
    _timer?.cancel();
    setState(() {});
    if (type == 'end') {
      //跳转汇报详情页面
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ReportDetails('dynamic')),
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }
}
