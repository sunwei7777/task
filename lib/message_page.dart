import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'models/message.dart';
import 'store/message_controller.dart';
import 'message/daily_report_list.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  int _currentTab = 0; // 0: 消息中心, 1: 团队提醒
  int _teamSubTab = 0; // 0: 审批提醒, 1: 汇报异常提醒

  final MessageController _controller = Get.find<MessageController>();

  // 分类显示配置
  static const Map<String, _CategoryDisplay> _categoryConfig = {
    'daily_report': _CategoryDisplay(
      icon: Icons.mic,
      color: Colors.blue,
      label: '每日播报',
    ),
    'off_work_report': _CategoryDisplay(
      icon: Icons.mic,
      color: Colors.blue,
      label: '下班播报',
    ),
    'task_over_time': _CategoryDisplay(
      icon: Icons.alarm,
      color: Colors.orange,
      label: '任务延期',
    ),
    'new_task': _CategoryDisplay(
      icon: Icons.notifications,
      color: Colors.blue,
      label: '新任务',
    ),
    'task_block': _CategoryDisplay(
      icon: Icons.block,
      color: Colors.pink,
      label: '任务阻塞',
    ),
    'task_changed': _CategoryDisplay(
      icon: Icons.refresh,
      color: Colors.green,
      label: '任务变动',
    ),
    // 'task_cancelled': _CategoryDisplay(
    //   icon: Icons.cancel,
    //   color: Colors.grey,
    //   label: '任务作废',
    // ),
  };

  @override
  void initState() {
    super.initState();
    _controller.fetchUnreadCount();
  }

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

  // 格式化时间
  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '';
    // 取 MM-DD 或 HH:mm
    if (timeStr.length >= 16) {
      // 如果包含日期部分，尝试提取
      final parts = timeStr.split(' ');
      if (parts.length >= 2) {
        final dateParts = parts[0].split('-');
        if (dateParts.length >= 3) {
          return '${dateParts[1]}-${dateParts[2]}';
        }
        return parts[1].substring(0, 5);
      }
      return timeStr.substring(5, 10);
    }
    return timeStr;
  }

  // 分类排序：每日播报和下班播报排前面，其余按 pushTime 倒序
  static const List<String> _priorityCategories = [
    'daily_report',
    'off_work_report',
  ];

  List<String> get _sortedCategories {
    final keys = _controller.latestMessages.keys
        .where((k) => _categoryConfig.containsKey(k))
        .toList();
    keys.sort((a, b) {
      final aPriority = _priorityCategories.indexOf(a);
      final bPriority = _priorityCategories.indexOf(b);
      // 优先类别的排在前面
      if (aPriority != -1 && bPriority != -1)
        return aPriority.compareTo(bPriority);
      if (aPriority != -1) return -1;
      if (bPriority != -1) return 1;
      // 其余按 pushTime 倒序
      final ma = _controller.latestMessages[a];
      final mb = _controller.latestMessages[b];
      final ta = ma?.pushTime ?? ma?.createTime ?? '';
      final tb = mb?.pushTime ?? mb?.createTime ?? '';
      return tb.compareTo(ta);
    });
    return keys;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: _currentTab == 0 ? _buildMessageCenter() : _buildTeamReminder(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      titleSpacing: 12,
      title: Row(
        children: [
          Obx(() => _buildTab(0, '消息中心', _controller.totalUnreadCount.value)),
          // SizedBox(width: 24),
          // _buildTab(1, '团队提醒', 4),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String title, int badge) {
    return GestureDetector(
      onTap: () => setState(() => _currentTab = index),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: _currentTab == index
                      ? Color(0xFF3895F2)
                      : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: _currentTab == index
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: _currentTab == index
                    ? Color(0xFF3895F2)
                    : Color(0xFF999999),
              ),
            ),
          ),
          // if (badge > 0)
          //   Positioned(
          //     right: -6,
          //     top: 0,
          //     child: Container(
          //       padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          //       decoration: BoxDecoration(
          //         color: Colors.red,
          //         borderRadius: BorderRadius.circular(10),
          //       ),
          //       child: Text(
          //         badge > 99 ? '99+' : badge.toString(),
          //         style: TextStyle(fontSize: 10, color: Colors.white),
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }

  Widget _buildMessageCenter() {
    return Obx(() {
      if (_controller.isLoading.value && _controller.latestMessages.isEmpty) {
        return Center(child: CircularProgressIndicator());
      }

      final categories = _sortedCategories;
      if (categories.isEmpty) {
        return Center(
          child: Text('暂无消息', style: TextStyle(color: Colors.grey)),
        );
      }

      return RefreshIndicator(
        onRefresh: () => _controller.fetchUnreadCount(),
        child: ListView.builder(
          padding: EdgeInsets.all(0),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final msg = _controller.latestMessages[category];
            return _buildMessageItem(category, msg);
          },
        ),
      );
    });
  }

  Widget _buildMessageItem(String category, MessageItemModel? msg) {
    final config =
        _categoryConfig[category] ??
        _CategoryDisplay(
          icon: Icons.message,
          color: Colors.blue,
          label: msg?.title ?? category,
        );
    final title = _parseContentTitle(msg?.content);
    final badgeCount = _controller.categoryStats[category] ?? 0;
    final time = _formatTime(msg?.pushTime ?? msg?.createTime);

    // 解析每日播报/下班播报统计数据
    Map<String, dynamic>? _dailyReportData;
    Map<String, dynamic>? _offWorkData;
    if (msg?.content != null) {
      final content = msg!.content;
      // 每日播报：解析 JSON
      if (category == 'daily_report') {
        try {
          final parsed = jsonDecode(content);
          if (parsed is Map<String, dynamic> &&
              parsed['content'] is Map<String, dynamic>) {
            _dailyReportData = parsed['content'] as Map<String, dynamic>;
          }
        } catch (_) {}
      }
      // 下班播报：从字符串中提取数字
      if (category == 'off_work_report') {
        final completedReg = RegExp(r'已完成(\d+)条');
        final remainingReg = RegExp(r'剩余(\d+)条');
        final overdueReg = RegExp(r'(\d+)条任务已延期');
        _offWorkData = {
          'completedTasks':
              int.tryParse(completedReg.firstMatch(content)?.group(1) ?? '') ??
              0,
          'remainingTasks':
              int.tryParse(remainingReg.firstMatch(content)?.group(1) ?? '') ??
              0,
          'overdueTasks':
              int.tryParse(overdueReg.firstMatch(content)?.group(1) ?? '') ?? 0,
        };
      }
    }

    final card = GestureDetector(
      onTap: () async {
        await _controller.markCategoryAsRead(category);
        Get.to(
          () => DailyReportListPage(category: category, title: config.label),
        )?.then((_) => _controller.fetchUnreadCount());
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Color(0x0D000000),
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: config.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(config.icon, color: config.color, size: 20),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              config.label,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ),
                          if (time.isNotEmpty)
                            Text(
                              time,
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF999999),
                              ),
                            ),
                        ],
                      ),
                      if (category != 'daily_report' &&
                          category != 'off_work_report') ...[
                        SizedBox(height: 4),
                        Text(
                          title.isNotEmpty ? title : (msg?.title ?? ''),
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF666666),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (badgeCount > 0)
                  Container(
                    margin: EdgeInsets.only(left: 8),
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badgeCount > 99 ? '99+' : badgeCount.toString(),
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
              ],
            ),
            if (_dailyReportData != null) ...[
              const SizedBox(height: 10),
              _buildDailyStats(_dailyReportData),
            ],
            if (_offWorkData != null) ...[
              const SizedBox(height: 10),
              _buildWorkTimeStats(_offWorkData),
            ],
          ],
        ),
      ),
    );
    return card;
  }

  // 每日播报的统计数据
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
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
                  fontSize: 20,
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

  // 下班播报的统计数据
  Widget _buildWorkTimeStats(Map<String, dynamic>? data) {
    final stats = [
      _StatItem('已完成', data?['completedTasks'] ?? 0, const Color(0xFF4CD964)),
      _StatItem('剩余', data?['remainingTasks'] ?? 0, const Color(0xFF3895F2)),
      _StatItem('已延期', data?['overdueTasks'] ?? 0, const Color(0xFFFF6B6B)),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
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
                  fontSize: 20,
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

  Widget _buildTeamReminder() {
    return Column(
      children: [
        _buildSubTabs(),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(0),
            itemCount: _approvalItems.length,
            itemBuilder: (context, index) {
              return _buildApprovalItem(_approvalItems[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubTabs() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _buildSubTab(0, '审批提醒', 2),
          SizedBox(width: 12),
          _buildSubTab(1, '汇报异常提醒', 2),
        ],
      ),
    );
  }

  Widget _buildSubTab(int index, String title, int badge) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _teamSubTab = index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: _teamSubTab == index ? Color(0xFF3895F2) : Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: _teamSubTab == index
                      ? Colors.white
                      : Color(0xFF666666),
                ),
              ),
              if (badge > 0)
                Container(
                  margin: EdgeInsets.only(left: 4),
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: _teamSubTab == index
                        ? Colors.white
                        : Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '($badge)',
                    style: TextStyle(
                      fontSize: 11,
                      color: _teamSubTab == index
                          ? Color(0xFF3895F2)
                          : Color(0xFF666666),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApprovalItem(ApprovalItem item) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.account_circle, color: Color(0xFF3895F2), size: 20),
              SizedBox(width: 8),
              Text(
                item.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, size: 12, color: Color(0xFF999999)),
                    SizedBox(width: 4),
                    Text(
                      item.timeAgo,
                      style: TextStyle(fontSize: 12, color: Color(0xFF999999)),
                    ),
                  ],
                ),
              ),
              Spacer(),
              Text(
                item.status,
                style: TextStyle(
                  fontSize: 12,
                  color: item.status == '未读'
                      ? Color(0xFFFF6B6B)
                      : Color(0xFF999999),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            item.content,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF666666),
              height: 1.5,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Text(
                '关联项目/订单',
                style: TextStyle(fontSize: 12, color: Color(0xFF999999)),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.orderInfo,
                    style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.time,
                style: TextStyle(fontSize: 12, color: Color(0xFF999999)),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  '去查看',
                  style: TextStyle(fontSize: 13, color: Color(0xFF3895F2)),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  // 保留硬编码的审批数据（团队提醒 tab 暂未接入接口）
  final List<ApprovalItem> _approvalItems = [
    ApprovalItem(
      title: '有新订单待审批',
      content: '张三 提交了「TOP-104」生产计划，请尽快到【电脑端】审批处理。请到: 任务中心-待我审核列表处理',
      time: '2023-11-02 09:00',
      timeAgo: '1小时59分',
      status: '未读',
      orderInfo: 'XSDD0017653636763\nTOP-104',
    ),
    ApprovalItem(
      title: '有新订单待审批',
      content: '张三 提交了「TOP-104」生产计划，请尽快到【电脑端】审批处理。请到: 任务中心-待我审核列表处理',
      time: '2023-11-02 09:00',
      timeAgo: '1小时59分',
      status: '未读',
      orderInfo: 'XSDD0017653636763\nTOP-104',
    ),
    ApprovalItem(
      title: '有新订单待审批',
      content: '张三 提交了「TOP-104」生产计划，请尽快到【电脑端】审批处理。请到: 任务中心-待我审核列表处理',
      time: '2023-11-02 09:00',
      timeAgo: '1小时59分',
      status: '已读',
      orderInfo: 'XSDD0017653636763\nTOP-104',
    ),
  ];
}

class _CategoryDisplay {
  final IconData icon;
  final Color color;
  final String label;
  const _CategoryDisplay({
    required this.icon,
    required this.color,
    required this.label,
  });
}

class ApprovalItem {
  final String title;
  final String content;
  final String time;
  final String timeAgo;
  final String status;
  final String orderInfo;

  ApprovalItem({
    required this.title,
    required this.content,
    required this.time,
    required this.timeAgo,
    required this.status,
    required this.orderInfo,
  });
}

class _StatItem {
  final String label;
  final int value;
  final Color color;
  const _StatItem(this.label, this.value, this.color);
}
