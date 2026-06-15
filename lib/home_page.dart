import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/individual_statistics.dart';
import 'package:flutter_application_1/report/report_details.dart';
import 'package:flutter_application_1/task/select_task_bottom.dart';
import 'package:flutter_application_1/home/time_nosubmit.dart';
import 'package:flutter_application_1/home/toast_custom.dart';
import 'package:flutter_application_1/utils/week_calendar.dart';
import 'package:flutter_application_1/services/storage_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_application_1/models/task.dart';
import 'package:flutter_application_1/services/message_service.dart';
import 'package:flutter_application_1/services/task_service.dart';
import 'package:flutter_application_1/services/websocket_service.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/store/task_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> with WidgetsBindingObserver {
  int _currentIndex = 0;
  Duration _duration = Duration();
  Timer? _timer;
  Timer? _timerStatusPollTimer;
  Map<String, dynamic>? _userInfo;
  // 从 TaskController 获取当前任务
  late TaskController _taskController;
  final TaskService _taskService = TaskService();
  final MessageService _messageService = MessageService();
  DailyStats? _todayStats;
  bool? _voiceEnabled;
  bool _isLoadingVoiceStatus = false;
  bool _isClockActionRunning = false;
  bool _isTimerLimitDialogShowing = false;
  bool _isRefreshingTimerLimit = false;
  bool _isSyncingTimerStatus = false;

  String get _todayStr {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> loadTodayStats() async {
    _loadVoiceStatus();
    final result = await _taskService.fetchMyReport(
      timeDimension: 'day',
      date: _todayStr,
      dateRange: [_todayStr],
    );
    if (mounted && result != null) {
      setState(() => _todayStats = result.dailyStats);
    }
  }

  Future<void> _loadVoiceStatus() async {
    if (_isLoadingVoiceStatus) return;
    _isLoadingVoiceStatus = true;
    try {
      final status = await _taskService.getVoiceStatus();
      if (mounted && status != null) {
        setState(() => _voiceEnabled = status);
      }
    } catch (_) {
      // 首页按钮状态刷新失败时不打断页面展示，下次进入首页会再查。
    } finally {
      _isLoadingVoiceStatus = false;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
    );
    // 获取 TaskController 实例
    _taskController = Get.find<TaskController>();
    _loadUserInfo();
    loadTodayStats();
    _restoreTimerState();
    WebSocketService().addListener(_onWsMessage);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    WebSocketService().removeListener(_onWsMessage);
    // 取消定时器，避免在组件销毁后仍然调用setState()
    _timer?.cancel();
    _stopTimerStatusPolling();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _currentIndex != 0) {
      // 从后台回到前台且正在计时，同步一次状态
      _syncTimerStatus();
    }
  }

  bool _isTimerLimitReachedStatus(Map<String, dynamic>? status) {
    if (status == null) return false;
    return (status['timerStatus'] == 3 || status['timerStatus'] == 4) &&
        status['reportStatus'] == 0;
  }

  Future<void> _showTimerLimitDialog(Map<String, dynamic> status) async {
    if (!mounted || _isTimerLimitDialogShowing) return;

    _isTimerLimitDialogShowing = true;
    try {
      await showDialog(
        context: context,
        builder: (context) => TimeNosubmit(timerStatus: status),
      );
    } finally {
      _isTimerLimitDialogShowing = false;
    }
  }

  String? _getWsCategory(Map<String, dynamic> msg) {
    final category = msg['category'];
    if (category != null) return category.toString();

    for (final key in ['data', 'result', 'message']) {
      final value = msg[key];
      if (value is Map && value['category'] != null) {
        return value['category'].toString();
      }
    }

    return null;
  }

  void _startTimerStatusPolling() {
    if (_timerStatusPollTimer != null) return;

    _timerStatusPollTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted || _currentIndex == 0) {
        _stopTimerStatusPolling();
        return;
      }
      _syncTimerStatus();
    });
  }

  void _stopTimerStatusPolling() {
    _timerStatusPollTimer?.cancel();
    _timerStatusPollTimer = null;
  }

  /// 重置计时状态并从服务端刷新
  Future<void> _resetTimerAndRefresh() async {
    if (_isRefreshingTimerLimit) return;
    _isRefreshingTimerLimit = true;

    _timer?.cancel();
    _stopTimerStatusPolling();
    if (mounted) {
      setState(() {
        _currentIndex = 0;
        _duration = Duration();
      });
    }

    try {
      final status = await _taskService.getTimerStatus();
      if (!mounted) return;

      if (_isTimerLimitReachedStatus(status)) {
        await _showTimerLimitDialog(status!);
      }
    } catch (e) {
      // Ignore refresh failures; lifecycle sync will re-check timer status.
    } finally {
      _isRefreshingTimerLimit = false;
    }
  }

  /// WebSocket 消息回调
  void _onWsMessage(Map<String, dynamic> msg) {
    final category = _getWsCategory(msg);
    if (category == 'timerOver' && _currentIndex != 0) {
      _resetTimerAndRefresh();
    } else if (category == 'TIME_LIMIT_REACHED') {
      // 计时已自动停止，刷新计时器状态
      _resetTimerAndRefresh();
    }
  }

  // 加载用户信息
  void _loadUserInfo() async {
    final userInfo = await StorageService.getUserInfo();
    if (mounted) {
      setState(() {
        _userInfo = userInfo;
      });
    }
  }

  // 格式化手机号显示（加密中间4位）
  String _formatPhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) {
      return '';
    }
    if (phone.length == 11) {
      return '${phone.substring(0, 3)}****${phone.substring(7)}';
    }
    return phone;
  }

  Future<void> _handleClockButtonTap() async {
    final voiceEnabled = _voiceEnabled;
    if (voiceEnabled == null || _isClockActionRunning) return;

    final isClockOut = voiceEnabled;
    final confirmed = await _showClockConfirmDialog(isClockOut: isClockOut);
    if (confirmed != true || !mounted) return;

    setState(() => _isClockActionRunning = true);
    try {
      final success = isClockOut
          ? await _taskService.clockOut()
          : await _taskService.clockIn();
      if (!mounted) return;

      if (success) {
        if (isClockOut) {
          await _messageService.fetchMyWorkTimeReport();
          if (!mounted) return;
        }
        setState(() => _voiceEnabled = !isClockOut);
        _loadVoiceStatus();
      }
    } catch (e) {
      if (!mounted) return;
      ToastCustom.showToast(
        context,
        isClockOut ? '下班失败' : '上班失败',
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => _isClockActionRunning = false);
      }
    }
  }

  Future<bool?> _showClockConfirmDialog({required bool isClockOut}) {
    final actionText = isClockOut ? '下班' : '上班';
    final content = isClockOut
        ? '「下班」后，今天APP内所有任务提醒将不以语音播报通知（每天09:00自动打开）。'
        : '「上班」后，APP内所有任务提醒将以语音播报通知。';

    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          titlePadding: EdgeInsets.fromLTRB(24, 22, 24, 0),
          contentPadding: EdgeInsets.fromLTRB(24, 12, 24, 24),
          actionsPadding: EdgeInsets.zero,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color(0xFFFF8800),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  '确定【$actionText】吗?',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.8,
              color: Color(0xFF374151),
            ),
          ),
          actions: [
            Container(height: 1, color: Color(0xFFE5E7EB)),
            SizedBox(
              height: 50,
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        '取消',
                        style: TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  Container(width: 1, color: Color(0xFFE5E7EB)),
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(
                        '确定',
                        style: TextStyle(
                          color: Color(0xFF0073FF),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildClockButton() {
    final voiceEnabled = _voiceEnabled;
    if (voiceEnabled == null) return SizedBox.shrink();

    final text = voiceEnabled ? '我要下班' : '我要上班';
    final accentColor = voiceEnabled ? Color(0xFF6EE7B7) : Color(0xFFFFC15A);
    final bgColor = voiceEnabled ? Color(0x1A6EE7B7) : Color(0x1AFFC15A);
    final borderColor = voiceEnabled ? Color(0x666EE7B7) : Color(0x66FFC15A);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleClockButtonTap,
      child: Container(
        margin: EdgeInsets.only(left: 8, right: 10),
        padding: EdgeInsets.symmetric(horizontal: 9),
        height: 30,
        constraints: BoxConstraints(minWidth: 62),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: _isClockActionRunning
            ? SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: accentColor,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Container(
                  //   width: 6,
                  //   height: 6,
                  //   decoration: BoxDecoration(
                  //     color: accentColor,
                  //     shape: BoxShape.circle,
                  //   ),
                  // ),
                  // SizedBox(width: 6),
                  Text(
                    text,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
      ),
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
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 14,
                left: 14,
                right: 14,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      ClipOval(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: Image(
                            image: AssetImage('lib/assets/logo.png'),
                          ),
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Task',
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
                    padding: EdgeInsets.only(left: 12),
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color(0xFF2D3767),
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Color(0xFF0073FF),
                          child: Text(
                            (_userInfo?['realName']?.toString() ?? '?')
                                .substring(0, 1),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                // 姓名部分
                                TextSpan(
                                  text: _userInfo?['realName'] ?? '未知用户',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                // 电话号码部分
                                TextSpan(
                                  text:
                                      '（${_formatPhoneNumber(_userInfo?['phone'] ?? _userInfo?['userName'])}）',
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildClockButton(),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => IndividualStatistics(),
                        ),
                      );
                      loadTodayStats();
                    },
                    child: Container(
                      width: double.infinity,
                      height: 48,
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
                                        fontSize: 16, // 较小字体
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
                                      text:
                                          '${(_todayStats?.onlineTime ?? 0) ~/ 3600}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '小时',
                                      style: TextStyle(
                                        // ignore: deprecated_member_use
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 16, // 较小字体
                                        fontWeight: FontWeight.normal,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          '${((_todayStats?.onlineTime ?? 0) % 3600) ~/ 60}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '分',
                                      style: TextStyle(
                                        // ignore: deprecated_member_use
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 16, // 较小字体
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
                                fontSize: 16, // 较小字体
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
                                            fontSize: 16, // 较小字体
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
                                          text:
                                              '${_todayStats?.reportCount ?? 0}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
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
                                  // 设置当前任务
                                  _taskController.setCurrentTask(
                                    _taskController.allTasks[index],
                                  );
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
                          child: Obx(
                            () => Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: Image(
                                          image: AssetImage(
                                            'lib/assets/yj.png',
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      (_taskController.currentTask.value ==
                                              null)
                                          ? Text(
                                              '选择任务开始工作',
                                              style: TextStyle(
                                                // ignore: deprecated_member_use
                                                color: Color(0xFF208BDE),
                                                fontSize: 16, // 较小字体
                                                fontWeight: FontWeight.normal,
                                                decoration: TextDecoration.none,
                                              ),
                                            )
                                          : Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  _taskController
                                                      .currentTask
                                                      .value!
                                                      .taskName,
                                                  style: TextStyle(
                                                    fontSize: 14, // 较小字体
                                                    color: Color(0xFF444444),
                                                    fontWeight: FontWeight.bold,
                                                    decoration:
                                                        TextDecoration.none,
                                                  ),
                                                ),
                                                Text(
                                                  '创建人：${_taskController.currentTask.value!.creatorName}',
                                                  style: TextStyle(
                                                    fontSize: 12, // 较小字体
                                                    color: Color(0xFF444444),
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    decoration:
                                                        TextDecoration.none,
                                                  ),
                                                ),
                                              ],
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
                            '最早 0:00 - 最晚 22:00',
                            style: TextStyle(
                              color: Color(0xFF999999),
                              fontSize: 16,
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
            SizedBox(width: 170, height: 170),
            Positioned(
              right: -20,
              bottom: -14,
              child: Image.asset('lib/assets/bee.png', width: 190, height: 190),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // 获取父容器的最大高度
        double parentHeight = constraints.maxHeight;
        // 计算子元素高度（30%）
        double imageHeight = parentHeight * 0.4;
        double sizedBoxHeight = parentHeight * 0.1;
        return Container(
          color: Color(0xFFF8FBFF),
          child: Column(
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
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    SizedBox(width: 40),
                    Text(
                      _formatDuration(_duration),
                      style: TextStyle(
                        color: Color(0xFF3D3F5F),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: sizedBoxHeight >= 30 ? 30 : sizedBoxHeight),
              Image.asset(
                _currentIndex == 1
                    ? 'lib/assets/bee.gif'
                    : 'lib/assets/beesleep.png',
                width: imageHeight >= 150 ? 150 : imageHeight,
                height: imageHeight >= 150 ? 150 : imageHeight,
              ),
              SizedBox(height: sizedBoxHeight >= 30 ? 30 : sizedBoxHeight),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _currentIndex != 1
                        ? () => _stopTimer('resume')
                        : () => _stopTimer('pause'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentIndex == 1
                          ? Color(0xFFFF7B00)
                          : Color(0xFF1BA17D),
                      padding: EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 12,
                      ),
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
                      padding: EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      '结束',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _startTimer() async {
    if (_currentIndex == 1) {
      _startTimerStatusPolling();
      return;
    }

    try {
      // 先查询计时状态
      final status = await _taskService.getTimerStatus();

      if (status != null && status['hasActive'] == true) {
        // PC端开启的计时，APP不接管
        if (status['deviceType'] == 1) {
          if (mounted) {
            ToastCustom.showToast(context, '操作失败', 'PC端正在计时，请在PC端操作');
          }
          return;
        }
        final timerStatus = status['timerStatus'];

        if (timerStatus == 1) {
          // 计时中 → 恢复到计时状态
          _restoreActiveTimer(status);
          return;
        } else if (timerStatus == 2) {
          // 已暂停 → 恢复到暂停状态
          _restorePausedTimer(status);
          return;
        }
      }

      // 计时已结束且未汇报 → 弹出补汇报弹窗
      if (_isTimerLimitReachedStatus(status)) {
        await _showTimerLimitDialog(status!);
        return;
      }

      // 没有进行中的计时，正常开启新计时
      await _taskService.startTimer(deviceType: 2);
      _currentIndex = 1;
      setState(() {});
      _startTimerStatusPolling();
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _duration += Duration(seconds: 1);
          });
        } else {
          timer.cancel();
        }
      });
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg =
          (data is Map ? data['errorMsg'] : null) ?? e.message ?? '网络异常';
      ToastCustom.showToast(context, '启动计时失败', msg.toString());
    } on Exception catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      ToastCustom.showToast(context, '启动计时失败', msg);
    } catch (e) {
      ToastCustom.showToast(context, '启动计时失败', '未知错误，请重试');
    }
  }

  /// 恢复计时中状态
  void _restoreActiveTimer(Map<String, dynamic> status) {
    final seconds = status['accumulatedSeconds'] ?? 0;
    _duration = Duration(
      seconds: seconds is int ? seconds : int.tryParse(seconds.toString()) ?? 0,
    );
    _currentIndex = 1;
    _timer?.cancel();
    _startTimerStatusPolling();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _duration += Duration(seconds: 1);
        });
      } else {
        timer.cancel();
      }
    });
    setState(() {});
  }

  /// 恢复已暂停状态
  void _restorePausedTimer(Map<String, dynamic> status) {
    final seconds = status['accumulatedSeconds'] ?? 0;
    _duration = Duration(
      seconds: seconds is int ? seconds : int.tryParse(seconds.toString()) ?? 0,
    );
    _currentIndex = 2;
    _timer?.cancel();
    _startTimerStatusPolling();
    setState(() {});
  }

  /// 从后台回到前台时同步计时状态
  Future<void> _syncTimerStatus() async {
    if (_isSyncingTimerStatus) return;
    _isSyncingTimerStatus = true;

    try {
      final status = await _taskService.getTimerStatus();
      if (!mounted || status == null) return;

      if (status['hasActive'] != true) {
        // 后端已结束计时
        _timer?.cancel();
        _stopTimerStatusPolling();

        if (_isTimerLimitReachedStatus(status)) {
          _currentIndex = 0;
          _duration = Duration();
          setState(() {});
          await _showTimerLimitDialog(status);
        } else {
          _currentIndex = 0;
          _duration = Duration();
          setState(() {});
        }
      } else if (status['timerStatus'] == 1) {
        // PC端计时，APP不同步
        if (status['deviceType'] == 1) {
          _timer?.cancel();
          _stopTimerStatusPolling();
          _currentIndex = 0;
          _duration = Duration();
          setState(() {});
          return;
        }
        // 同步后端累计时长，校准本地时钟
        final seconds = status['accumulatedSeconds'] ?? 0;
        _duration = Duration(
          seconds: seconds is int
              ? seconds
              : int.tryParse(seconds.toString()) ?? 0,
        );
        _startTimerStatusPolling();
        setState(() {});
      } else if (status['timerStatus'] == 2) {
        final seconds = status['accumulatedSeconds'] ?? 0;
        _duration = Duration(
          seconds: seconds is int
              ? seconds
              : int.tryParse(seconds.toString()) ?? 0,
        );
        _currentIndex = 2;
        _timer?.cancel();
        _startTimerStatusPolling();
        setState(() {});
      }
    } catch (e) {
      // 静默忽略
    } finally {
      _isSyncingTimerStatus = false;
    }
  }

  /// 页面加载时恢复计时状态
  void _restoreTimerState() async {
    try {
      final status = await _taskService.getTimerStatus();
      if (!mounted || status == null) return;

      // PC端开启的计时，APP不接管
      if (status['deviceType'] == 1) return;

      if (status['hasActive'] == true) {
        final timerStatus = status['timerStatus'];
        if (timerStatus == 1) {
          _restoreActiveTimer(status);
        } else if (timerStatus == 2) {
          _restorePausedTimer(status);
        }
      } else if (_isTimerLimitReachedStatus(status)) {
        _currentIndex = 0;
        _duration = Duration();
        setState(() {});
      }
    } catch (e) {
      // 静默处理，不影响页面正常加载
    }
  }

  void _stopTimer(String type) async {
    try {
      if (type == 'pause') {
        await _taskService.pauseTimer();
        _currentIndex = 2;
        _timer?.cancel();
        _startTimerStatusPolling();
        setState(() {});
      } else if (type == 'resume') {
        await _taskService.resumeTimer();
        _currentIndex = 1;
        _timer?.cancel();
        _startTimerStatusPolling();
        _timer = Timer.periodic(Duration(seconds: 1), (timer) {
          if (mounted) {
            setState(() {
              _duration += Duration(seconds: 1);
            });
          } else {
            timer.cancel();
          }
        });
        setState(() {});
      } else if (type == 'end') {
        await _taskService.stopTimer();
        _currentIndex = 0;
        _timer?.cancel();
        _stopTimerStatusPolling();
        _duration = Duration();
        setState(() {});
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ReportDetails('dynamic')),
        );
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg =
          (data is Map ? data['errorMsg'] : null) ?? e.message ?? '网络异常';
      ToastCustom.showToast(context, '操作失败', msg.toString());
    } on Exception catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      ToastCustom.showToast(context, '操作失败', msg);
    } catch (e) {
      ToastCustom.showToast(context, '操作失败', '未知错误，请重试');
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
