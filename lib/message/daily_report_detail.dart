import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/message.dart';
import '../services/message_service.dart';
import '../task/task_look.dart';

class DailyReportDetailPage extends StatefulWidget {
  final MessageItemModel message;

  const DailyReportDetailPage({Key? key, required this.message})
    : super(key: key);

  @override
  State<DailyReportDetailPage> createState() => _DailyReportDetailPageState();
}

class _DailyReportDetailPageState extends State<DailyReportDetailPage> {
  final MessageService _service = MessageService();
  WorkTimeReport? _workTimeReport;
  bool _isLoading = true;

  bool get _isOffWork => widget.message.category == 'off_work_report';
  bool get _isTaskBlock => widget.message.category == 'task_block';
  bool get _isTaskChanged => widget.message.category == 'task_changed';
  bool get _isNewTask => widget.message.category == 'new_task';
  bool get _isTaskOverdue => widget.message.category == 'task_over_time';

  @override
  void initState() {
    super.initState();
    if (_isOffWork) {
      _fetchWorkTimeReport();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _fetchWorkTimeReport() async {
    final result = await _service.fetchMyWorkTimeReport();
    if (mounted) {
      setState(() {
        _workTimeReport = result;
        _isLoading = false;
      });
    }
  }

  // 解析 content JSON
  Map<String, dynamic>? get _parsed {
    try {
      final obj = jsonDecode(widget.message.content);
      if (obj is Map<String, dynamic>) return obj;
    } catch (_) {}
    return null;
  }

  // 提取标题
  String get _title {
    final t = _parsed?['title'];
    return t?.toString() ?? widget.message.title;
  }

  // 提取子内容
  Map<String, dynamic>? get _contentData {
    final c = _parsed?['content'];
    if (c is Map<String, dynamic>) return c;
    return null;
  }

  // 格式化日期显示
  String _formatDate(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '';
    try {
      final now = DateTime.now();
      final date = DateTime.parse(timeStr.split(' ')[0]);
      final diff = now.difference(date).inDays;
      if (diff == 0) return '今天';
      if (diff == 1) return '昨天';
      return '${date.month}月${date.day}日';
    } catch (_) {
      return timeStr.substring(0, 10);
    }
  }

  // 格式化时间显示
  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '';
    final parts = timeStr.split(' ');
    if (parts.length >= 2) {
      return parts[1].substring(0, 5);
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3895F2),
        elevation: 0,
        title: const Text(
          '查看详情',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // if (!_isTaskOverdue) ...[
                  //   const SizedBox(height: 16),
                  //   _buildHeader(),
                  // ],
                  if (_isTaskBlock) ...[
                    const SizedBox(height: 16),
                    _buildTaskBlockDetail(),
                  ] else if (_isTaskChanged) ...[
                    const SizedBox(height: 16),
                    _buildTaskChangedDetail(),
                  ] else if (_isNewTask) ...[
                    const SizedBox(height: 16),
                    _buildNewTaskDetail(),
                  ] else if (_isTaskOverdue) ...[
                    const SizedBox(height: 16),
                    _buildTaskOverdueDetail(),
                  ] else if (!_isOffWork) ...[
                    const SizedBox(height: 16),
                    _buildContent(),
                    const SizedBox(height: 16),
                    _buildDailyStats(),
                  ],
                  if (_workTimeReport != null) ...[
                    const SizedBox(height: 16),
                    _buildWorkTimeStats(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    final dateStr = _isOffWork
        ? _workTimeReport?.createTime
        : _contentData?['createTime']?.toString() ?? widget.message.createTime;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.message.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const Spacer(),
              Text(
                '已读',
                style: TextStyle(fontSize: 12, color: const Color(0xFF999999)),
              ),
            ],
          ),
          if (dateStr != null && dateStr.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '${_formatDate(dateStr)} ${_formatTime(dateStr)}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _title,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF666666),
          height: 1.6,
        ),
      ),
    );
  }

  // 下班播报的统计数据
  Widget _buildWorkTimeStats() {
    final report = _workTimeReport!;
    final stats = [
      _StatItem('已完成', report.completedTasks, const Color(0xFF4CD964)),
      _StatItem('剩余', report.remainingTasks, const Color(0xFF3895F2)),
      _StatItem('已延期', report.overdueTasks, const Color(0xFFFF6B6B)),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: stats.map((item) {
          return Column(
            children: [
              Text(
                item.value.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: item.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // 每日播报的统计数据
  Widget _buildDailyStats() {
    final data = _contentData;
    if (data == null) return const SizedBox.shrink();

    final stats = [
      _StatItem('任务总数', data['totalTasks'] ?? 0, const Color(0xFF3895F2)),
      _StatItem('新增', data['newTasks'] ?? 0, const Color(0xFF4CD964)),
      _StatItem('已延期', data['overdueTasks'] ?? 0, const Color(0xFFFF6B6B)),
      _StatItem(
        '即将到期',
        data['pendingNearExpireTasks'] ?? 0,
        const Color(0xFFFF9500),
      ),
      _StatItem('已取消', data['canceledTasks'] ?? 0, const Color(0xFF999999)),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: stats.map((item) {
          return Column(
            children: [
              Text(
                item.value.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: item.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // 任务阻塞详情
  Widget _buildTaskBlockDetail() {
    final data = _contentData;
    if (data == null) return const SizedBox.shrink();

    final blockTasks = data['blockTaskList'] as List? ?? [];

    return Column(
      children: [
        // 阻塞提示区域
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const Text(
              //   '有前置工序阻碍你，催促完成',
              //   style: TextStyle(
              //     fontSize: 14,
              //     fontWeight: FontWeight.bold,
              //     color: Color(0xFFE74C3C),
              //   ),
              // ),
              // const SizedBox(height: 16),
              _buildBlockInfoRow(
                '任务编号',
                data['taskNo']?.toString() ?? '',
                onTap: () =>
                    _goToTaskDetail(taskNo: data['taskNo']?.toString()),
              ),
              _buildBlockInfoRow('受阻任务', data['taskName']?.toString() ?? ''),
              _buildBlockInfoRow('订单号', data['billNo']?.toString() ?? ''),
              _buildBlockInfoRow('款号', data['styleCode']?.toString() ?? ''),
              _buildBlockInfoRow('责任人', data['userName']?.toString() ?? ''),
              _buildBlockInfoRow('开始时间', data['startTime']?.toString() ?? ''),
              _buildBlockInfoRow('计划完成', data['endTime']?.toString() ?? ''),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // 阻塞工序列表
        ...blockTasks.map((task) => _buildBlockTaskCard(task)),
      ],
    );
  }

  // 阻塞信息行
  Widget _buildBlockInfoRow(String label, String value, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 90,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF999999),
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 13,
                          color: onTap != null
                              ? const Color(0xFF3895F2)
                              : const Color(0xFF333333),
                        ),
                      ),
                    ),
                    if (onTap != null)
                      const Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: Color(0xFFCCCCCC),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // 阻塞工序卡片
  Widget _buildBlockTaskCard(dynamic task) {
    final taskMap = task as Map<String, dynamic>;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '工序',
                style: TextStyle(fontSize: 12, color: Color(0xFF999999)),
              ),
              const SizedBox(width: 12),
              Text(
                taskMap['blockTaskName']?.toString() ?? '',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF3895F2),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '阻塞人：${taskMap['blockUserNames']?.toString() ?? ''}',
            style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
          ),
        ],
      ),
    );
  }

  // 任务变动详情
  Widget _buildTaskChangedDetail() {
    final data = _contentData;
    if (data == null) return const SizedBox.shrink();

    final changes = data['changes'] as List? ?? [];
    final cancelled = data['cancelled'] == true;

    return Column(
      children: [
        // 任务基本信息
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 提示标题
              // Text(
              //   _title,
              //   style: const TextStyle(
              //     fontSize: 14,
              //     fontWeight: FontWeight.bold,
              //     color: Color(0xFFE74C3C),
              //   ),
              // ),
              // const SizedBox(height: 16),
              _buildBlockInfoRow(
                '任务编号',
                data['taskNo']?.toString() ?? '',
                onTap: () =>
                    _goToTaskDetail(taskNo: data['taskNo']?.toString()),
              ),
              _buildBlockInfoRow('任务名称', data['taskName']?.toString() ?? ''),
              _buildBlockInfoRow('订单号', data['billNo']?.toString() ?? ''),
              _buildBlockInfoRow('款号', data['styleCode']?.toString() ?? ''),
              _buildBlockInfoRow('责任人', data['userName']?.toString() ?? ''),
              _buildBlockInfoRow('修改人', data['updateName']?.toString() ?? ''),
              if (cancelled) _buildBlockInfoRow('状态', '已取消'),
            ],
          ),
        ),
        // 变动明细
        if (changes.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '变动明细',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 12),
                for (var change in changes)
                  _buildChangeItem(
                    (change as Map<String, dynamic>)['field']?.toString() ?? '',
                    change['oldVal']?.toString() ?? '',
                    change['newVal']?.toString() ?? '',
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // 变动明细单项
  Widget _buildChangeItem(String field, String oldVal, String newVal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              field,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF3895F2),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
                children: [
                  TextSpan(
                    text: oldVal,
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Color(0xFF999999),
                    ),
                  ),
                  const TextSpan(text: ' → '),
                  TextSpan(
                    text: newVal,
                    style: const TextStyle(
                      color: Color(0xFFE74C3C),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 新任务详情
  Widget _buildNewTaskDetail() {
    final taskList = _parsed?['list'] as List? ?? [];

    return Column(
      children: [
        // 提示标题
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3895F2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // 新任务列表
        for (var task in taskList)
          _buildNewTaskCard(task as Map<String, dynamic>),
      ],
    );
  }

  // 新任务卡片
  Widget _buildNewTaskCard(Map<String, dynamic> task) {
    return GestureDetector(
      onTap: () => _goToTaskDetail(taskNo: task['taskNo']?.toString() ?? ''),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF3895F2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '新任务',
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task['taskName']?.toString() ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF333333),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task['taskNo']?.toString() ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFCCCCCC)),
          ],
        ),
      ),
    );
  }

  // 格式化毫秒时间戳
  String _formatTimestamp(int? ms) {
    if (ms == null) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${dt.month}月${dt.day}日 ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  // 任务延期详情
  Widget _buildTaskOverdueDetail() {
    final taskList = _parsed?['list'] as List? ?? [];

    return Column(
      children: [
        // 提示标题
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF6B6B),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // 延期任务列表
        for (var task in taskList)
          _buildOverdueTaskCard(task as Map<String, dynamic>),
      ],
    );
  }

  // 延期任务卡片
  Widget _buildOverdueTaskCard(Map<String, dynamic> task) {
    final startStr = _formatTimestamp(task['startTime'] as int?);
    final endStr = _formatTimestamp(task['endTime'] as int?);

    return GestureDetector(
      onTap: () => _goToTaskDetail(taskNo: task['taskNo']?.toString()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B6B),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '已延期',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          task['taskName']?.toString() ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF333333),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.numbers,
                        size: 14,
                        color: Color(0xFF999999),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        task['taskNo']?.toString() ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.schedule,
                        size: 14,
                        color: Color(0xFF999999),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '$startStr ~ $endStr',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF999999),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFCCCCCC)),
          ],
        ),
      ),
    );
  }

  void _goToTaskDetail({String? taskNo}) {
    if (taskNo == null || taskNo.isEmpty) return;
    Get.to(() => TaskLook(isHasDetail: true, taskNo: taskNo));
  }
}

class _StatItem {
  final String label;
  final int value;
  final Color color;
  const _StatItem(this.label, this.value, this.color);
}
