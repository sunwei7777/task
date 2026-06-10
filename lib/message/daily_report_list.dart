import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/message.dart';
import '../store/message_controller.dart';
import 'daily_report_detail.dart';
import '../task/task_look.dart';

class DailyReportListPage extends StatefulWidget {
  final String category;
  final String title;

  const DailyReportListPage({
    Key? key,
    this.category = 'daily_report',
    this.title = '每日播报',
  }) : super(key: key);

  @override
  State<DailyReportListPage> createState() => _DailyReportListPageState();
}

class _DailyReportListPageState extends State<DailyReportListPage> {
  final MessageController _controller = Get.find<MessageController>();
  final ScrollController _scrollController = ScrollController();

  // 从 content JSON 中提取标题
  String _parseContentTitle(String? content) {
    if (content == null || content.isEmpty) return '';
    try {
      final map = jsonDecode(content);
      if (map is Map && map.containsKey('title')) {
        return map['title'].toString();
      }
    } catch (_) {}
    return content;
  }

  Map<String, dynamic>? _parseContentMap(String? content) {
    if (content == null || content.isEmpty) return null;
    try {
      final value = jsonDecode(content);
      if (value is Map) return Map<String, dynamic>.from(value);
    } catch (_) {}
    return null;
  }

  List<Map<String, dynamic>> _parseNewTaskItems(String? content) {
    final map = _parseContentMap(content);
    if (map == null) return const [];

    final list = map['list'];
    if (list is List) {
      return list
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    final nestedContent = map['content'];
    if (nestedContent is Map && nestedContent['list'] is List) {
      return (nestedContent['list'] as List)
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    return const [];
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
      return '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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
  void initState() {
    super.initState();
    _controller.fetchMessages(widget.category);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !_controller.isLoadingMore.value &&
        _controller.hasMore.value) {
      _controller.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3895F2),
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.more_vert, color: Colors.white),
        //     onPressed: () {},
        //   ),
        // ],
      ),
      body: Obx(() {
        if (_controller.isLoadingMessages.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final reports = _controller.messageList;
        if (reports.isEmpty) {
          return Center(
            child: Text(
              '暂无${widget.title}',
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _controller.fetchMessages(widget.category),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: reports.length + 1,
                  itemBuilder: (context, index) {
                    if (index >= reports.length) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: _controller.hasMore.value
                              ? Container(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF0073FF),
                                    ),
                                  ),
                                )
                              : Text(
                                  '— 加载完成 —',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF999999),
                                  ),
                                ),
                        ),
                      );
                    }
                    return _buildReportItem(reports[index]);
                  },
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Map<String, dynamic>? _parseDailyReportData(String? content) {
    if (content == null || content.isEmpty) return null;
    try {
      final parsed = jsonDecode(content);
      if (parsed is Map<String, dynamic> &&
          parsed['content'] is Map<String, dynamic>) {
        return parsed['content'] as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  Map<String, dynamic>? _parseOffWorkReportData(String? content) {
    if (content == null || content.isEmpty) return null;
    final completedReg = RegExp(r'已完成(\d+)条');
    final remainingReg = RegExp(r'剩余(\d+)条');
    final overdueReg = RegExp(r'(\d+)条任务已延期');
    return {
      'completedTasks':
          int.tryParse(completedReg.firstMatch(content)?.group(1) ?? '') ?? 0,
      'remainingTasks':
          int.tryParse(remainingReg.firstMatch(content)?.group(1) ?? '') ?? 0,
      'overdueTasks':
          int.tryParse(overdueReg.firstMatch(content)?.group(1) ?? '') ?? 0,
    };
  }

  Widget _buildReportItem(MessageItemModel report) {
    final displayTitle = _parseContentTitle(report.content);
    final isNewTask = widget.category == 'new_task';
    final isDailyReport = widget.category == 'daily_report';
    final isOffWork = widget.category == 'off_work_report';
    final showTitle = widget.category == 'task_over_time';
    final newTaskItems = isNewTask
        ? _parseNewTaskItems(report.content)
        : const [];
    final dailyReportData = isDailyReport
        ? _parseDailyReportData(report.content)
        : null;
    final offWorkData = isOffWork
        ? _parseOffWorkReportData(report.content)
        : null;
    final taskDetailData =
        (widget.category == 'task_block' || widget.category == 'task_changed')
        ? _parseContentMap(report.content)
        : null;
    final taskContentData = taskDetailData?['content'] is Map<String, dynamic>
        ? taskDetailData!['content'] as Map<String, dynamic>
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 日期和状态行
          Row(
            children: [
              // const Icon(Icons.circle, size: 10, color: Color(0xFF3895F2)),
              // const SizedBox(width: 8),
              Text(
                _formatDate(report.createTime),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF333333),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _formatTime(report.createTime),
                style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
              ),
              const Spacer(),
              Text(
                report.isRead == 0 ? '未读' : '已读',
                style: TextStyle(
                  fontSize: 12,
                  color: report.isRead == 0
                      ? const Color(0xFFFF6B6B)
                      : const Color(0xFF999999),
                ),
              ),
            ],
          ),
          if (showTitle && displayTitle.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Text(
                displayTitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  height: 1.6,
                ),
              ),
            ),
          ],
          if (taskContentData != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: _buildTaskBriefInfo(taskContentData),
            ),
          ],
          if (dailyReportData != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _buildDailyStats(dailyReportData),
            ),
          ],
          if (offWorkData != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _buildWorkTimeStats(offWorkData),
            ),
          ],
          if (newTaskItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...newTaskItems.map((task) => _buildNewTaskPreview(report, task)),
          ],
          if (widget.category != 'off_work_report' &&
              !isDailyReport &&
              (!isNewTask || newTaskItems.isEmpty)) ...[
            const SizedBox(height: 12),
            // 查看详情按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    if (report.isRead == 0) {
                      _controller.markAsRead([report.id]);
                    }
                    Get.to(() => DailyReportDetailPage(message: report));
                  },
                  child: const Text(
                    '查看详情',
                    style: TextStyle(fontSize: 14, color: Color(0xFF3895F2)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNewTaskPreview(
    MessageItemModel report,
    Map<String, dynamic> task,
  ) {
    final taskName = task['taskName']?.toString() ?? '';
    final taskNo = task['taskNo']?.toString() ?? '';
    final billNo = task['billNo']?.toString() ?? '';
    final styleCode = task['styleCode']?.toString() ?? '';
    final taskType = _taskTypeLabel(task['taskType']);

    return GestureDetector(
      onTap: () {
        if (report.isRead == 0) {
          _controller.markAsRead([report.id]);
        }
        if (taskNo.isEmpty) {
          Get.to(() => DailyReportDetailPage(message: report));
          return;
        }
        Get.to(() => TaskLook(isHasDetail: true, taskNo: taskNo));
      },
      child: Container(
        margin: const EdgeInsets.only(left: 18, right: 18, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFF),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5EEFF)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                    taskName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF333333),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (taskNo.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      taskNo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                  if (billNo.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '订单: $billNo',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFAAAAAA),
                      ),
                    ),
                  ],
                  if (styleCode.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      '款号: $styleCode',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFAAAAAA),
                      ),
                    ),
                  ],
                  if (taskType.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      '类型: $taskType',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFAAAAAA),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: Color(0xFFCCCCCC)),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyStats(Map<String, dynamic> data) {
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: stats.map((item) {
          return Column(
            children: [
              Text(
                item.value.toString(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: item.color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.label,
                style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTaskBriefInfo(Map<String, dynamic> data) {
    final taskNo = data['taskNo']?.toString() ?? '';
    final taskName = data['taskName']?.toString() ?? '';
    final billNo = data['billNo']?.toString() ?? '';
    final styleCode = data['styleCode']?.toString() ?? '';
    final userName = data['userName']?.toString() ?? '';
    final updateName = data['updateName']?.toString() ?? '';
    final cancelled = data['cancelled'] == true;
    final changes = data['changes'] as List? ?? [];

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (taskNo.isNotEmpty) _infoRow('任务编号', taskNo),
          if (taskName.isNotEmpty) _infoRow('任务名称', taskName),
          if (billNo.isNotEmpty) _infoRow('订单号', billNo),
          if (styleCode.isNotEmpty) _infoRow('款号', styleCode),
          if (userName.isNotEmpty) _infoRow('责任人', userName),
          if (updateName.isNotEmpty) _infoRow('修改人', updateName),
          if (cancelled) _infoRow('状态', '已取消'),
          if (changes.isNotEmpty)
            _infoRow(
              '变动项',
              changes
                  .map(
                    (c) =>
                        (c as Map<String, dynamic>)['field']?.toString() ?? '',
                  )
                  .join('、'),
            ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Color(0xFF333333)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkTimeStats(Map<String, dynamic>? data) {
    final stats = [
      _StatItem('已完成', data?['completedTasks'] ?? 0, const Color(0xFF4CD964)),
      _StatItem('剩余', data?['remainingTasks'] ?? 0, const Color(0xFF3895F2)),
      _StatItem('已延期', data?['overdueTasks'] ?? 0, const Color(0xFFFF6B6B)),
    ];

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: stats.map((item) {
          return Column(
            children: [
              Text(
                item.value.toString(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: item.color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.label,
                style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _taskTypeLabel(dynamic type) {
    final s = type?.toString() ?? '';
    const labels = {
      'PROJECT_TASK': '项目任务',
      'ORDER_TASK': '订单任务',
      'ORDER_TASK_DY': '打样任务',
      'TEMP_TASK': '临时任务',
      'CYCLE_DAILY': '周期任务-按日',
      'CYCLE_WEEKLY': '周期任务-按星期',
      'CYCLE_MONTHLY': '周期任务-按月',
      'MEETING_TASK': '会议任务',
      'OUTBOUND_TASK': '外派任务',
    };
    return labels[s] ?? s;
  }
}

class _StatItem {
  final String label;
  final int value;
  final Color color;
  const _StatItem(this.label, this.value, this.color);
}
