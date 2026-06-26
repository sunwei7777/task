import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/message.dart';
import '../task/task_look.dart';

class DailyReportDetailPage extends StatefulWidget {
  final MessageItemModel message;

  const DailyReportDetailPage({Key? key, required this.message})
    : super(key: key);

  @override
  State<DailyReportDetailPage> createState() => _DailyReportDetailPageState();
}

class _DailyReportDetailPageState extends State<DailyReportDetailPage> {
  bool get _isTaskChanged => widget.message.category == 'task_changed';
  bool get _isTaskOverdue => widget.message.category == 'task_over_time';

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

  // 格式化毫秒时间戳
  String _formatTimestamp(int? ms) {
    if (ms == null) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${dt.month}月${dt.day}日 ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _isTaskChanged
            ? _buildTaskChangedDetail()
            : _isTaskOverdue
            ? _buildTaskOverdueDetail()
            : const SizedBox.shrink(),
      ),
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

  // 任务变动详情
  Widget _buildTaskChangedDetail() {
    final data = _contentData;
    if (data == null) return const SizedBox.shrink();

    final changes = data['changes'] as List? ?? [];
    final cancelled = data['cancelled'] == true;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

  // 任务延期详情
  Widget _buildTaskOverdueDetail() {
    final taskList = _parsed?['list'] as List? ?? [];

    return Column(
      children: [
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
        for (var task in taskList)
          _buildOverdueTaskCard(task as Map<String, dynamic>),
      ],
    );
  }

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
