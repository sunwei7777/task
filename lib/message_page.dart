import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'models/message.dart';
import 'store/message_controller.dart';
import 'store/remark_controller.dart';
import 'message/daily_report_list.dart';
import 'message/remark_detail_page.dart';
import 'report/report_form.dart';
import 'assets/app_styles.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  /// 角标计数的分类：消息中心 + 团队提醒（审批提醒、汇报异常提醒）
  static const List<String> badgeCategoryKeys = [
    'daily_report',
    'off_work_report',
    'task_over_time',
    'new_task',
    'task_block',
    'task_changed',
    'order_message',
    'pre_report',
  ];

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  int _currentTab = 0; // 0: 消息中心, 1: 团队提醒
  int _teamSubTab = 0; // 0: 审批提醒, 1: 汇报异常提醒

  final MessageController _controller = Get.find<MessageController>();
  final RemarkController _remarkController = Get.put(RemarkController());
  final ScrollController _remarkScrollController = ScrollController();
  final ScrollController _preReportScrollController = ScrollController();
  final ScrollController _orderMessageScrollController = ScrollController();

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
  };

  @override
  void initState() {
    super.initState();
    _controller.fetchUnreadCount();
    _remarkScrollController.addListener(_onRemarkScroll);
    _preReportScrollController.addListener(_onPreReportScroll);
    _orderMessageScrollController.addListener(_onOrderMessageScroll);
  }

  @override
  void dispose() {
    _remarkScrollController.removeListener(_onRemarkScroll);
    _remarkScrollController.dispose();
    _preReportScrollController.removeListener(_onPreReportScroll);
    _preReportScrollController.dispose();
    _orderMessageScrollController.removeListener(_onOrderMessageScroll);
    _orderMessageScrollController.dispose();
    super.dispose();
  }

  void _onRemarkScroll() {
    if (_remarkScrollController.position.pixels >=
            _remarkScrollController.position.maxScrollExtent - 100 &&
        !_remarkController.isLoadingMore.value &&
        _remarkController.hasMore.value) {
      _remarkController.loadMore();
    }
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
          Obx(() {
            final msgCenterUnread = _categoryConfig.keys.fold<int>(
              0,
              (sum, key) => sum + (_controller.categoryStats[key] ?? 0),
            );
            return _buildTab(0, '消息中心', msgCenterUnread);
          }),
          SizedBox(width: 24),
          Obx(() {
            final teamUnread =
                (_controller.categoryStats['order_message'] ?? 0) +
                (_controller.categoryStats['pre_report'] ?? 0);
            return _buildTab(1, '团队提醒', teamUnread);
          }),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String title, int badge) {
    return GestureDetector(
      onTap: () {
        setState(() => _currentTab = index);
        if (index == 1) {
          switch (_teamSubTab) {
            case 0:
              _controller.fetchMessages('order_message');
            case 1:
              _controller.fetchMessages('pre_report');
            case 2:
              _remarkController.refresh();
          }
        }
      },
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
          if (badge > 0)
            Positioned(
              right: -6,
              top: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge > 99 ? '99+' : badge.toString(),
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ),
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
        if (_teamSubTab == 2) _buildRemarkFilter(),
        Expanded(
          child: _teamSubTab == 2
              ? Stack(
                  children: [
                    _buildRemarkList(),
                    // 底部批量已读栏
                    Obx(() {
                      if (_remarkController.selectedReviewIds.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Text(
                                '已选 ${_remarkController.selectedReviewIds.length} 项',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const Spacer(),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFEF7D33),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                onPressed: () =>
                                    _remarkController.batchMarkReadSelected(),
                                child: const Text(
                                  '批量已读',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                )
              : _teamSubTab == 0
              ? _buildOrderMessageList()
              : _teamSubTab == 1
              ? _buildPreReportList()
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  // 备注处理列表
  Widget _buildRemarkList() {
    return Obx(() {
      if (_remarkController.isLoading.value &&
          _remarkController.remarkList.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_remarkController.remarkList.isEmpty) {
        return const Center(
          child: Text('暂无备注处理', style: TextStyle(color: Colors.grey)),
        );
      }

      return RefreshIndicator(
        onRefresh: () => _remarkController.refresh(),
        child: ListView.builder(
          controller: _remarkScrollController,
          padding: EdgeInsets.all(0),
          itemCount: _remarkController.remarkList.length + 1,
          itemBuilder: (context, index) {
            if (index >= _remarkController.remarkList.length) {
              return _buildRemarkLoadMore();
            }
            return _buildRemarkItem(_remarkController.remarkList[index]);
          },
        ),
      );
    });
  }

  Widget _buildRemarkLoadMore() {
    return Obx(() {
      if (_remarkController.isLoadingMore.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      }
      if (!_remarkController.hasMore.value) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text(
              '— 加载完成 —',
              style: TextStyle(fontSize: 13, color: Color(0xFF999999)),
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  // 备注处理 - 单个列表项
  Widget _buildRemarkItem(RemarkReviewItem item) {
    final statusLabel = item.readStatus == 0 ? '未读' : '已读';
    final statusColor = item.readStatus == 0
        ? const Color(0xFFFF6B6B)
        : const Color(0xFF999999);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0D000000),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部标题栏
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    if (item.viewRole == 'reviewer')
                      Obx(
                        () => GestureDetector(
                          onTap: () =>
                              _remarkController.toggleSelection(item.reviewId),
                          child: Container(
                            width: 22,
                            height: 22,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    _remarkController.isSelected(item.reviewId)
                                    ? const Color(0xFF3895F2)
                                    : const Color(0xFFCCCCCC),
                                width: 2,
                              ),
                              color: _remarkController.isSelected(item.reviewId)
                                  ? const Color(0xFF3895F2)
                                  : Colors.white,
                            ),
                            child: _remarkController.isSelected(item.reviewId)
                                ? const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3895F2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.list,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.processName.isNotEmpty ? item.processName : '备注处理',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: item.readStatus == 0
                      ? const Color(0x1AFF6B6B)
                      : const Color(0x1A999999),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(fontSize: 12, color: statusColor),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => Get.to(() => RemarkDetailPage(detail: item)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // 备注内容
                if (item.remark.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.expectFinishDate.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              '预计到货时间：${item.expectFinishDate}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        Text(
                          item.remark,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (item.remark.isNotEmpty) const SizedBox(height: 10),
                // 单号款号行
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (item.billNo.isNotEmpty)
                      Expanded(
                        child: Text(
                          '单号：${item.billNo}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (item.styleCode.isNotEmpty)
                      Text(
                        '款号：${item.styleCode}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                // 提交人与时间
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '提交人：${item.reporterName}',
                      style: const TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      item.submitTime,
                      style: const TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                // 处理人意见（取每个 reviewer 的 comments 第一条）
                if (item.reviewers.any((r) => r.comments.isNotEmpty)) ...[
                  const SizedBox(height: 10),
                  ...item.reviewers.where((r) => r.comments.isNotEmpty).map((
                    reviewer,
                  ) {
                    final lastComment = reviewer.comments.last;
                    final readLabel = reviewer.readStatus == 1 ? '已读' : '未读';
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBE8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    reviewer.reviewerName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  // Container(
                                  //   padding: const EdgeInsets.symmetric(
                                  //     horizontal: 6,
                                  //     vertical: 1,
                                  //   ),
                                  //   decoration: BoxDecoration(
                                  //     color: reviewer.readStatus == 1
                                  //         ? const Color(0xFFE6F9EF)
                                  //         : const Color(0x1AFF6B6B),
                                  //     borderRadius: BorderRadius.circular(3),
                                  //   ),
                                  //   child: Text(
                                  //     readLabel,
                                  //     style: TextStyle(
                                  //       fontSize: 11,
                                  //       color: reviewer.readStatus == 1
                                  //           ? const Color(0xFF4CD964)
                                  //           : const Color(0xFFFF6B6B),
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                              Text(
                                lastComment.createTime,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF999999),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            lastComment.content,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
                // 按钮区：reviewer 显示标记已读+发送意见，非 reviewer 显示快捷提交
                const SizedBox(height: 12),
                if (item.viewRole == 'reviewer')
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFEF7D33),
                            side: const BorderSide(color: Color(0xFFEF7D33)),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          onPressed: () {
                            _remarkController.batchMarkRead([item.reviewId]);
                          },
                          child: const Text(
                            '标记已读',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2B64FF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          onPressed: () {
                            _showSendOpinionDialog(item.reviewId);
                          },
                          child: const Text(
                            '发送意见',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: const WidgetStatePropertyAll<Color>(
                          Color(0xFFB3E5FC),
                        ),
                        foregroundColor: const WidgetStatePropertyAll<Color>(
                          Colors.blue,
                        ),
                        padding: const WidgetStatePropertyAll<EdgeInsets>(
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        shape:
                            const WidgetStatePropertyAll<
                              RoundedRectangleBorder
                            >(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(4),
                                ),
                              ),
                            ),
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => ReportForm(taskId: item.taskId),
                        );
                      },
                      child: const Text('快捷提交', style: TextStyle(fontSize: 14)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSendOpinionDialog(int reviewId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("发送意见"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                maxLength: 60,
                minLines: 1,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "请输入意见",
                  border: AppStyles.border,
                  enabledBorder: AppStyles.enabledBorder,
                  focusedBorder: AppStyles.focusedBorder,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                buildCounter:
                    (
                      context, {
                      required int currentLength,
                      required bool isFocused,
                      required int? maxLength,
                    }) {
                      return Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "$currentLength/$maxLength",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("取消"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2B64FF),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final text = controller.text.trim();
                if (text.isEmpty) return;
                Navigator.of(ctx).pop();
                _remarkController.submitComment(reviewId, text);
              },
              child: const Text("确定"),
            ),
          ],
        );
      },
    );
  }

  // 获取指定任务类型的未读数
  int _getTaskTypeUnread(int? taskType) {
    final map = _remarkController.unreadByTaskType;
    if (taskType == null) {
      // 全部：汇总所有类型
      return map.values.fold(0, (a, b) => a + b);
    }
    return map[taskType] ?? 0;
  }

  // 备注处理筛选栏：任务类型 Tab + 筛选按钮
  Widget _buildRemarkFilter() {
    final taskTypes = [
      {'label': '全部', 'value': null},
      {'label': '项目管理', 'value': 2},
      {'label': '项目集', 'value': 1},
      {'label': '打样', 'value': 9},
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Obx(() {
              final selected = _remarkController.currentTaskType.value;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: taskTypes.map((t) {
                    final isSelected = selected == t['value'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => _remarkController.selectTaskType(
                          t['value'] as int?,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF3895F2)
                                : const Color(0xFFF5F7FA),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                t['label'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF666666),
                                ),
                              ),
                              if (_getTaskTypeUnread(t['value'] as int?) > 0)
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFFFF4444),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _getTaskTypeUnread(
                                        t['value'] as int?,
                                      ).toString(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? const Color(0xFF3895F2)
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            }),
          ),
          GestureDetector(
            onTap: _showFilterBottomSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFDDDDDD)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Obx(() {
                final hasFilter =
                    _remarkController.currentReadStatus.value != null ||
                    _remarkController.currentBillNo.value.isNotEmpty ||
                    _remarkController.currentStyleCode.value.isNotEmpty ||
                    _remarkController.currentExpectFinishDate.value.isNotEmpty;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.filter_alt_outlined,
                      size: 14,
                      color: hasFilter
                          ? const Color(0xFF3895F2)
                          : const Color(0xFF666666),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '筛选',
                      style: TextStyle(
                        fontSize: 13,
                        color: hasFilter
                            ? const Color(0xFF3895F2)
                            : const Color(0xFF666666),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    final filterOptions = [
      {'label': '全部', 'value': null},
      {'label': '未读', 'value': 0},
      {'label': '已读', 'value': 1},
    ];
    var selectedReadStatus = _remarkController.currentReadStatus.value;
    var billNoCtrl = TextEditingController(
      text: _remarkController.currentBillNo.value,
    );
    var styleCodeCtrl = TextEditingController(
      text: _remarkController.currentStyleCode.value,
    );
    var dateCtrl = TextEditingController(
      text: _remarkController.currentExpectFinishDate.value,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.65,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // 顶部标题栏
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey[300]!,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('筛选内容', style: TextStyle(fontSize: 18)),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close, size: 20),
                        ),
                      ],
                    ),
                  ),
                  // 筛选内容
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 备注状态
                          const Text(
                            '备注状态',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: filterOptions.map((option) {
                              final isSelected =
                                  selectedReadStatus == option['value'];
                              return GestureDetector(
                                onTap: () {
                                  setSheetState(() {
                                    selectedReadStatus =
                                        option['value'] as int?;
                                  });
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFFE6F2FF)
                                            : Colors.grey[100],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        option['label'] as String,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isSelected
                                              ? const Color(0xFF0073FF)
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Positioned(
                                        child: Container(
                                          width: 12,
                                          height: 12,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF208BDE),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(4),
                                              bottomRight: Radius.circular(4),
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            size: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                          // 订单编号
                          const Text(
                            '订单编号',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: billNoCtrl,
                            decoration: InputDecoration(
                              hintText: '请输入订单编号',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // 款号
                          const Text(
                            '款号',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: styleCodeCtrl,
                            decoration: InputDecoration(
                              hintText: '请输入款号',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // 预计完成时间
                          const Text(
                            '预计完成时间',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: dateCtrl,
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: '请选择预计完成时间',
                              suffixIcon: const Icon(Icons.calendar_today),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                final formatted =
                                    '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                                dateCtrl.text = formatted;
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 底部按钮
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey[200]!, width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setSheetState(() {
                                selectedReadStatus = null;
                                billNoCtrl.clear();
                                styleCodeCtrl.clear();
                                dateCtrl.clear();
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey[300]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: const Text(
                              '清空全部',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _remarkController.applyFilter(
                                readStatus: selectedReadStatus,
                                billNo: billNoCtrl.text,
                                styleCode: styleCodeCtrl.text,
                                expectFinishDate: dateCtrl.text,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0073FF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: const Text(
                              '确定',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSubTabs() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Obx(
            () => _buildSubTab(
              0,
              '审批提醒',
              _controller.categoryStats['order_message'] ?? 0,
              onTap: () {
                setState(() => _teamSubTab = 0);
                _controller.markCategoryAsRead('order_message');
                _controller.fetchMessages('order_message');
              },
            ),
          ),
          SizedBox(width: 12),
          Obx(
            () => _buildSubTab(
              1,
              '汇报异常提醒',
              _controller.categoryStats['pre_report'] ?? 0,
              onTap: () {
                setState(() => _teamSubTab = 1);
                _controller.markCategoryAsRead('pre_report');
                _controller.fetchMessages('pre_report');
              },
            ),
          ),
          SizedBox(width: 12),
          _buildSubTab(
            2,
            '备注处理',
            0,
            onTap: () {
              setState(() => _teamSubTab = 2);
              _remarkController.refresh();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubTab(
    int index,
    String title,
    int badge, {
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap ?? (() => setState(() => _teamSubTab = index)),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
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

  // 审批提醒 - 滚动加载更多
  void _onOrderMessageScroll() {
    if (_orderMessageScrollController.position.pixels >=
            _orderMessageScrollController.position.maxScrollExtent - 100 &&
        !_controller.isLoadingMore.value &&
        _controller.hasMore.value) {
      _controller.loadMore();
    }
  }

  // 审批提醒 - 列表
  Widget _buildOrderMessageList() {
    return Obx(() {
      if (_controller.isLoadingMessages.value &&
          _controller.messageList.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      final messages = _controller.messageList;
      if (messages.isEmpty) {
        return const Center(
          child: Text('暂无审批提醒', style: TextStyle(color: Colors.grey)),
        );
      }

      return RefreshIndicator(
        onRefresh: () => _controller.fetchMessages('order_message'),
        child: ListView.builder(
          controller: _orderMessageScrollController,
          padding: EdgeInsets.all(0),
          itemCount: messages.length + 1,
          itemBuilder: (context, index) {
            if (index >= messages.length) {
              return _buildOrderMessageLoadMore();
            }
            return _buildOrderMessageItem(messages[index]);
          },
        ),
      );
    });
  }

  // 审批提醒 - 加载更多指示器
  Widget _buildOrderMessageLoadMore() {
    return Obx(() {
      if (_controller.isLoadingMore.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      }
      if (!_controller.hasMore.value) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text(
              '— 加载完成 —',
              style: TextStyle(fontSize: 13, color: Color(0xFF999999)),
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  // 审批提醒 - 单条消息
  Widget _buildOrderMessageItem(MessageItemModel msg) {
    // 解析 content JSON
    String type = '';
    String billNo = '';
    String styleCode = '';
    int remainTime = 0;
    String approvalLevelName = '';
    String rejectLevelName = '';
    String rejectReason = '';

    if (msg.content.isNotEmpty) {
      try {
        final parsed = jsonDecode(msg.content);
        if (parsed is Map<String, dynamic>) {
          type = parsed['type']?.toString() ?? '';
          billNo = parsed['billNo']?.toString() ?? '';
          styleCode = parsed['styleCode']?.toString() ?? '';
          remainTime = (parsed['remainTime'] as num?)?.toInt() ?? 0;
          approvalLevelName = parsed['approvalLevelName']?.toString() ?? '';
          rejectLevelName = parsed['rejectLevelName']?.toString() ?? '';
          rejectReason = parsed['rejectReason']?.toString() ?? '';
        }
      } catch (_) {}
    }

    final isPending = type == 'approval_pending';
    final isRejected = type == 'approval_rejected';
    final isPassed = type == 'approval_passed';
    final time = _formatTime(msg.pushTime ?? msg.createTime);
    // 剩余时间转换
    final remainHours = remainTime > 0 ? (remainTime ~/ 60) : 0;
    final remainMins = remainTime > 0 ? (remainTime % 60) : 0;
    final remainText = remainHours > 0
        ? '${remainHours}小时${remainMins > 0 ? '$remainMins分钟' : ''}'
        : '$remainMins分钟';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0D000000),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行：图标 + 标题 + 时间 + 已读
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isPassed
                      ? const Color(0xFF4CD964).withValues(alpha: 0.1)
                      : isRejected
                      ? const Color(0xFFFF6B6B).withValues(alpha: 0.1)
                      : const Color(0xFF3895F2).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isPassed
                      ? Icons.check_circle
                      : isRejected
                      ? Icons.cancel
                      : Icons.task_alt,
                  color: isPassed
                      ? const Color(0xFF4CD964)
                      : isRejected
                      ? const Color(0xFFFF6B6B)
                      : const Color(0xFF3895F2),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      msg.title.isNotEmpty
                          ? msg.title
                          : (isPassed
                                ? '审批已通过'
                                : isPending
                                ? '订单待审批'
                                : '审批已驳回'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isPassed
                            ? const Color(0xFF4CD964)
                            : isRejected
                            ? const Color(0xFFFF6B6B)
                            : const Color(0xFF333333),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (time.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                msg.isRead == 0 ? '未读' : '已读',
                style: TextStyle(
                  fontSize: 12,
                  color: msg.isRead == 0
                      ? const Color(0xFFFF6B6B)
                      : const Color(0xFF999999),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 详情卡片
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 审批通过
                if (isPassed)
                  _orderInfoRow(
                    '状态',
                    '已通过',
                    valueColor: const Color(0xFF4CD964),
                  ),
                // 审批/驳回级别
                if (isPending && approvalLevelName.isNotEmpty)
                  _orderInfoRow('审批级别', approvalLevelName),
                if (isRejected && rejectLevelName.isNotEmpty)
                  _orderInfoRow(
                    '驳回级别',
                    rejectLevelName,
                    valueColor: const Color(0xFFFF6B6B),
                  ),
                // 驳回原因
                if (isRejected && rejectReason.isNotEmpty)
                  _orderInfoRow(
                    '驳回原因',
                    rejectReason,
                    valueColor: const Color(0xFFFF6B6B),
                  ),
                // 订单号
                if (billNo.isNotEmpty) _orderInfoRow('订单号', billNo),
                // 款号
                if (styleCode.isNotEmpty) _orderInfoRow('款号', styleCode),
                // 剩余时间
                if (remainTime > 0)
                  _orderInfoRow(
                    '剩余时间',
                    remainText,
                    valueColor: remainTime < 60
                        ? const Color(0xFFFF6B6B)
                        : const Color(0xFFFF9500),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 审批提醒 - 信息行
  Widget _orderInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: valueColor ?? const Color(0xFF333333),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 汇报异常提醒 - 滚动加载更多
  void _onPreReportScroll() {
    if (_preReportScrollController.position.pixels >=
            _preReportScrollController.position.maxScrollExtent - 100 &&
        !_controller.isLoadingMore.value &&
        _controller.hasMore.value) {
      _controller.loadMore();
    }
  }

  // 汇报异常提醒 - 列表
  Widget _buildPreReportList() {
    return Obx(() {
      if (_controller.isLoadingMessages.value &&
          _controller.messageList.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      final messages = _controller.messageList;
      if (messages.isEmpty) {
        return const Center(
          child: Text('暂无汇报异常', style: TextStyle(color: Colors.grey)),
        );
      }

      return RefreshIndicator(
        onRefresh: () => _controller.fetchMessages('pre_report'),
        child: ListView.builder(
          controller: _preReportScrollController,
          padding: EdgeInsets.all(0),
          itemCount: messages.length + 1,
          itemBuilder: (context, index) {
            if (index >= messages.length) {
              return _buildPreReportLoadMore();
            }
            return _buildPreReportItem(messages[index]);
          },
        ),
      );
    });
  }

  // 汇报异常提醒 - 加载更多指示器
  Widget _buildPreReportLoadMore() {
    return Obx(() {
      if (_controller.isLoadingMore.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      }
      if (!_controller.hasMore.value) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text(
              '— 加载完成 —',
              style: TextStyle(fontSize: 13, color: Color(0xFF999999)),
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  // 汇报异常提醒 - 单条消息
  Widget _buildPreReportItem(MessageItemModel report) {
    // 解析 content JSON
    String taskName = '';
    int taskProgress = 0;
    List preTasks = [];
    String billNo = '';
    String reporterName = '';

    if (report.content.isNotEmpty) {
      try {
        final parsed = jsonDecode(report.content);
        if (parsed is Map<String, dynamic>) {
          taskName = parsed['taskName']?.toString() ?? '';
          taskProgress = (parsed['taskProgress'] as num?)?.toInt() ?? 0;
          preTasks = (parsed['preTasks'] as List?) ?? [];
          billNo = parsed['billNo']?.toString() ?? '';
          reporterName = parsed['reporterName']?.toString() ?? '';
        }
      } catch (_) {}
    }

    final time = _formatTime(report.pushTime ?? report.createTime);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0D000000),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行：图标 + 标签 + 时间 + 已读状态
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.warning_amber,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '汇报异常',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    if (time.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
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
          const SizedBox(height: 12),
          // 任务详情卡片
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 当前任务 + 进度
                Row(
                  children: [
                    const Text(
                      '当前任务：',
                      style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
                    ),
                    Expanded(
                      child: Text(
                        taskName.isNotEmpty ? taskName : '-',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: taskProgress >= 100
                            ? const Color(0xFF4CD964)
                            : const Color(0xFF3895F2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$taskProgress%',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                // 前置任务未完成
                if (preTasks.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Text(
                    '前置任务未完成：',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFFF6B6B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...preTasks.map((pt) {
                    final ptMap = pt as Map<String, dynamic>;
                    final ptName = ptMap['taskName']?.toString() ?? '';
                    final ptProgress =
                        (ptMap['taskProgress'] as num?)?.toInt() ?? 0;
                    final ptDirector = ptMap['director']?.toString() ?? '';
                    final upstreamBlockedCount =
                        (ptMap['upstreamBlockedCount'] as num?)?.toInt() ?? 0;
                    final upstreamTasks = ptMap['upstreamTasks'] as List? ?? [];
                    final hasUpstream =
                        upstreamBlockedCount > 0 && upstreamTasks.isNotEmpty;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: GestureDetector(
                        onTap: hasUpstream
                            ? () =>
                                  _showUpstreamBottomSheet(ptMap, upstreamTasks)
                            : null,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 14,
                              color: Color(0xFFFF6B6B),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          ptName.isNotEmpty ? ptName : '未知任务',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF333333),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (hasUpstream) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 1,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF2F2),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: const Color(0x1AFF6B6B),
                                            ),
                                          ),
                                          child: Text(
                                            '$upstreamBlockedCount个阻塞',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Color(0xFFFF6B6B),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      Text(
                                        '进度$ptProgress%',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFFFF6B6B),
                                        ),
                                      ),
                                      if (hasUpstream)
                                        const Icon(
                                          Icons.chevron_right,
                                          size: 16,
                                          color: Color(0xFFCCCCCC),
                                        ),
                                    ],
                                  ),
                                  if (ptDirector.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      '负责人：$ptDirector',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF999999),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          // 底部：单号 + 汇报人
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (billNo.isNotEmpty)
                Expanded(
                  child: Text(
                    '单号：$billNo',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF999999),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (reporterName.isNotEmpty)
                Text(
                  '汇报人：$reporterName',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF999999),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // 前置任务的上游阻塞层级弹出层
  void _showUpstreamBottomSheet(
    Map<String, dynamic> currentTask,
    List upstreamTasks,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // 顶部标题栏
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          '上游阻塞任务链',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: const Icon(Icons.close, size: 20),
                      ),
                    ],
                  ),
                ),
                // 层级列表（当前任务 + 上游任务）
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildUpstreamItem(
                        currentTask,
                        depth: 0,
                        isCurrent: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 递归构建上游任务项
  Widget _buildUpstreamItem(
    Map<String, dynamic> task, {
    int depth = 0,
    bool isCurrent = false,
  }) {
    final taskName = task['taskName']?.toString() ?? '';
    final progress = (task['taskProgress'] as num?)?.toInt() ?? 0;
    final director = task['director']?.toString() ?? '';
    final blockedCount = (task['blockedCount'] as num?)?.toInt() ?? 0;
    final children =
        (task['upstreamTasks'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    final color = isCurrent
        ? const Color(0xFFFF6B6B)
        : depth <= 1
        ? const Color(0xFFFF9500)
        : depth == 2
        ? const Color(0xFF3895F2)
        : const Color(0xFF999999);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(left: depth * 16.0, bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(6),
            border: Border(left: BorderSide(color: color, width: 3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      taskName.isNotEmpty ? taskName : '未知任务',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (blockedCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '阻塞$blockedCount个',
                        style: TextStyle(fontSize: 10, color: color),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Text(
                    '进度$progress%',
                    style: TextStyle(fontSize: 12, color: color),
                  ),
                ],
              ),
              if (director.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  '负责人：$director',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ],
          ),
        ),
        // 递归渲染子任务
        for (final child in children)
          _buildUpstreamItem(child, depth: depth + 1),
      ],
    );
  }
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

class _StatItem {
  final String label;
  final int value;
  final Color color;
  const _StatItem(this.label, this.value, this.color);
}
