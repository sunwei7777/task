import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/float_button.dart';
import 'package:flutter_application_1/home_page.dart';
import 'package:flutter_application_1/message_page.dart';
import 'package:flutter_application_1/my_page.dart';
import 'package:flutter_application_1/services/message_sound_service.dart';
import 'package:flutter_application_1/services/websocket_service.dart';
import 'package:flutter_application_1/task_page.dart';
import 'package:flutter_application_1/utils/message_reminder_overlay.dart';
import 'store/message_controller.dart';
import 'tabbar.dart';

class Index extends StatefulWidget {
  const Index({super.key});

  @override
  State<Index> createState() => IndexState();

  static final GlobalKey<IndexState> tabKey = GlobalKey<IndexState>();

  static void switchToTab(int index) {
    final state = tabKey.currentState;
    if (state != null) {
      state._switchTab(index);
    }
  }
}

class IndexState extends State<Index> {
  int _currentIndex = 0;
  final _homeKey = GlobalKey<HomePageState>();
  final _taskKey = GlobalKey<TaskPageState>();

  @override
  void initState() {
    super.initState();
    WebSocketService().addListener(_onWsMessage);
  }

  @override
  void dispose() {
    WebSocketService().removeListener(_onWsMessage);
    MessageReminderOverlay.dismiss();
    MessageSoundService.instance.dispose();
    super.dispose();
  }

  void _onWsMessage(Map<String, dynamic> msg) {
    final payload = _extractMessagePayload(msg);
    final category = _getMessageValue(payload, 'category');

    if (_shouldSkipOverlay(payload, category)) return;

    final reminder = _buildReminderFromPayload(payload);
    if (reminder == null || !mounted) return;

    if (_shouldPlayMessageSound(payload, category)) {
      MessageSoundService.instance.playMessageAlert(
        vibrate: _shouldVibrate(payload),
      );
    }

    MessageReminderOverlay.show(
      messages: [reminder],
      onTap: () => _switchTab(2),
    );
  }

  Map<String, dynamic> _extractMessagePayload(Map<String, dynamic> msg) {
    for (final key in ['data', 'result', 'message']) {
      final value = msg[key];
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
    }
    return msg;
  }

  String? _getMessageValue(Map<String, dynamic> payload, String key) {
    final value = payload[key];
    if (value == null) return null;
    return value.toString();
  }

  bool _shouldSkipOverlay(Map<String, dynamic> payload, String? category) {
    final title = _getMessageValue(payload, 'title');
    final content = _getMessageValue(payload, 'content');

    if (category == 'SYSTEM' && title == '连接成功' && content == 'APP消息推送服务已连接') {
      return true;
    }

    return category == 'heartbeat' ||
        category == 'timerOver' ||
        category == 'TIME_LIMIT_REACHED';
  }

  bool _shouldPlayMessageSound(Map<String, dynamic> payload, String? category) {
    final voiceReminder =
        payload['voiceReminder'] ?? payload['sound'] ?? payload['playSound'];
    if (voiceReminder?.toString() == 'false') {
      return false;
    }

    return true;
  }

  bool _shouldVibrate(Map<String, dynamic> payload) {
    final vibrate = payload['vibrate'] ?? payload['vibration'];
    return vibrate?.toString() != 'false';
  }

  MessageReminderData? _buildReminderFromPayload(Map<String, dynamic> payload) {
    final category = _getMessageValue(payload, 'category');
    if (category == 'new_task') {
      return _buildNewTaskReminder(payload);
    }

    if (category == 'task_changed') {
      return _buildTaskChangedReminder(payload);
    }

    if (category == 'task_block') {
      return _buildTaskBlockReminder(payload);
    }

    if (category == 'report_remark_review') {
      return _buildRemarkReviewReminder(payload);
    }

    final title =
        _getMessageValue(payload, 'title') ??
        _getMessageValue(payload, 'category') ??
        '消息提醒';
    final content = _extractDisplayContent(payload);

    if (content == null || content.trim().isEmpty) {
      return null;
    }

    return MessageReminderData(
      title: title,
      time: _formatMessageTime(_getMessageValue(payload, 'createTime')),
      createdAt: _parseMessageTime(_getMessageValue(payload, 'createTime')),
      segments: _buildMessageSegments(content.trim()),
      icon: _iconForCategory(category),
      iconColor: _iconColorForCategory(category),
      category: category,
    );
  }

  MessageReminderData? _buildTaskChangedReminder(Map<String, dynamic> payload) {
    final content =
        _buildTaskChangedContent(payload) ?? _extractDisplayContent(payload);
    if (content == null || content.trim().isEmpty) return null;

    return MessageReminderData(
      title: _getMessageValue(payload, 'title') ?? '任务变更提醒',
      time: _formatMessageTime(_getMessageValue(payload, 'createTime')),
      createdAt: _parseMessageTime(_getMessageValue(payload, 'createTime')),
      segments: _buildMessageSegments(content.trim()),
      icon: _iconForCategory('task_changed'),
      iconColor: _iconColorForCategory('task_changed'),
      category: 'task_changed',
      aggregateKey: 'task_changed',
      detailLines: [content.trim()],
    );
  }

  String? _buildTaskChangedContent(Map<String, dynamic> payload) {
    final parsed = _parseMessageContent(payload['content']);
    if (parsed is! Map) return null;

    final detail = _extractMessageDetailMap(parsed);
    if (detail == null) return null;

    final updateName = detail['updateName']?.toString();
    final taskName = detail['taskName']?.toString();
    final taskNo = detail['taskNo']?.toString();
    if (updateName == null ||
        updateName.isEmpty ||
        taskName == null ||
        taskName.isEmpty ||
        taskNo == null ||
        taskNo.isEmpty) {
      return null;
    }

    return '$updateName对任务编号$taskNo「$taskName」，操作了编辑。可能存在交期、负责人、新增、删除等调整，详细修改项请联系修改人。';
  }

  MessageReminderData? _buildTaskBlockReminder(Map<String, dynamic> payload) {
    final content =
        _buildTaskBlockContent(payload) ?? _extractDisplayContent(payload);
    if (content == null || content.trim().isEmpty) return null;

    return MessageReminderData(
      title: _getMessageValue(payload, 'title') ?? '任务阻塞提醒',
      time: _formatMessageTime(_getMessageValue(payload, 'createTime')),
      createdAt: _parseMessageTime(_getMessageValue(payload, 'createTime')),
      segments: _buildMessageSegments(content.trim()),
      icon: _iconForCategory('task_block'),
      iconColor: _iconColorForCategory('task_block'),
      category: 'task_block',
      aggregateKey: 'task_block',
      detailLines: [content.trim()],
    );
  }

  String? _buildTaskBlockContent(Map<String, dynamic> payload) {
    final parsed = _parseMessageContent(payload['content']);
    if (parsed is! Map) return null;

    final detail = _extractMessageDetailMap(parsed);
    if (detail == null) return null;

    final billNo = detail['billNo']?.toString();
    final taskName = detail['taskName']?.toString();
    final blockTaskList = detail['blockTaskList'];
    if (billNo == null ||
        billNo.isEmpty ||
        taskName == null ||
        taskName.isEmpty ||
        blockTaskList is! List ||
        blockTaskList.isEmpty) {
      return null;
    }

    final blockers = <String>[];
    final contacts = <String>{};
    for (final item in blockTaskList) {
      if (item is! Map) continue;

      final blockTaskName = item['blockTaskName']?.toString();
      final blockUserNames = item['blockUserNames']?.toString();
      if (blockTaskName == null ||
          blockTaskName.isEmpty ||
          blockUserNames == null ||
          blockUserNames.isEmpty) {
        continue;
      }

      blockers.add('$blockUserNames的「$blockTaskName」');
      for (final name in blockUserNames.split(RegExp(r'[,，、\s]+'))) {
        if (name.trim().isNotEmpty) contacts.add(name.trim());
      }
    }

    if (blockers.isEmpty) return null;

    final blockerText = blockers.join('、');
    final contactText = contacts.isEmpty ? '相关负责人' : contacts.join('、');
    return '在订单编号$billNo中，您的任务「$taskName」目前被$blockerText阻塞，无法继续推进，请及时与$contactText沟通协调，尽快推进完成。';
  }

  Map? _extractMessageDetailMap(Map parsed) {
    final content = parsed['content'];
    if (content is Map) return content;
    return parsed;
  }

  MessageReminderData _buildNewTaskReminder(Map<String, dynamic> payload) {
    final count = _getNewTaskCount(payload['content']);
    final title = _getMessageValue(payload, 'title') ?? '您有新任务，请及时查看';
    final time = _formatMessageTime(_getMessageValue(payload, 'createTime'));

    return MessageReminderData(
      title: title,
      time: time,
      createdAt: _parseMessageTime(_getMessageValue(payload, 'createTime')),
      segments: _buildMessageSegments('您有$count条新任务，请及时查看'),
      icon: _iconForCategory('new_task'),
      iconColor: _iconColorForCategory('new_task'),
      category: 'new_task',
      aggregateKey: 'new_task',
      count: count,
    );
  }

  MessageReminderData _buildRemarkReviewReminder(Map<String, dynamic> payload) {
    final parsed = _parseMessageContent(payload['content']);
    final detail = (parsed is Map<String, dynamic>)
        ? parsed
        : <String, dynamic>{};
    final reporterName = detail['reporterName']?.toString() ?? '';
    final taskName = detail['taskName']?.toString() ?? '';
    final billNo = detail['billNo']?.toString() ?? '';
    final taskNo = detail['taskNo']?.toString() ?? '';
    final remark = detail['remark']?.toString() ?? '';

    final title = _getMessageValue(payload, 'title') ?? '汇报备注查阅提醒';
    final time = _formatMessageTime(_getMessageValue(payload, 'createTime'));

    final buffer = StringBuffer();
    if (reporterName.isNotEmpty) buffer.write('$reporterName');
    if (taskName.isNotEmpty) buffer.write('的「$taskName」');
    buffer.write('有新的备注需要您查阅处理');
    if (remark.isNotEmpty) buffer.write('\n备注：$remark');

    final detailLines = <String>[];
    if (taskNo.isNotEmpty) detailLines.add('任务编号：$taskNo');
    if (billNo.isNotEmpty) detailLines.add('订单号：$billNo');

    return MessageReminderData(
      title: title,
      time: time,
      createdAt: _parseMessageTime(_getMessageValue(payload, 'createTime')),
      segments: _buildMessageSegments(buffer.toString()),
      icon: _iconForCategory('report_remark_review'),
      iconColor: _iconColorForCategory('report_remark_review'),
      category: 'report_remark_review',
      detailLines: detailLines,
    );
  }

  int _getNewTaskCount(dynamic content) {
    final parsed = _parseMessageContent(content);
    if (parsed is Map) {
      final list = parsed['list'];
      if (list is List && list.isNotEmpty) return list.length;

      final title = parsed['title']?.toString();
      final titleCount = _extractFirstNumber(title);
      if (titleCount != null) return titleCount;
    }

    final text = parsed?.toString() ?? content?.toString() ?? '';
    return _extractFirstNumber(text) ?? 1;
  }

  dynamic _parseMessageContent(dynamic content) {
    if (content is! String) return content;
    final value = content.trim();
    if (!value.startsWith('{') && !value.startsWith('[')) return value;

    try {
      return jsonDecode(value);
    } catch (_) {
      return value;
    }
  }

  String? _extractDisplayContent(Map<String, dynamic> payload) {
    final rawContent =
        payload['content'] ?? payload['msg'] ?? payload['message'];
    final parsed = _parseMessageContent(rawContent);

    if (parsed is Map) {
      final title = parsed['title'];
      if (title != null && title.toString().trim().isNotEmpty) {
        return title.toString();
      }

      final content = parsed['content'];
      if (content is String && content.trim().isNotEmpty) {
        return content;
      }

      return null;
    }

    if (parsed == null) return null;
    return parsed.toString();
  }

  int? _extractFirstNumber(String? value) {
    if (value == null) return null;
    final match = RegExp(r'\d+').firstMatch(value);
    if (match == null) return null;
    return int.tryParse(match.group(0)!);
  }

  List<MessageReminderSegment> _buildMessageSegments(String content) {
    final segments = <MessageReminderSegment>[];
    final pattern = RegExp(r'(\d+\s*个?任务(?:即将)?(?:已)?(?:延期|逾期)?|\d+)');
    var start = 0;

    for (final match in pattern.allMatches(content)) {
      if (match.start > start) {
        segments.add(
          MessageReminderSegment(content.substring(start, match.start)),
        );
      }
      final value = match.group(0)!;
      segments.add(
        MessageReminderSegment(
          value,
          color: value.contains('延期') || value.contains('逾期')
              ? const Color(0xFFF14F5E)
              : const Color(0xFF1D8BFF),
        ),
      );
      start = match.end;
    }

    if (start < content.length) {
      segments.add(MessageReminderSegment(content.substring(start)));
    }

    return segments.isEmpty ? [MessageReminderSegment(content)] : segments;
  }

  String _formatMessageTime(String? rawTime) {
    final time = _parseMessageTime(rawTime);
    return '${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  DateTime _parseMessageTime(String? rawTime) {
    if (rawTime == null || rawTime.trim().isEmpty) {
      return DateTime.now();
    }

    final normalized = rawTime.trim().replaceFirst(' ', 'T');
    return DateTime.tryParse(normalized) ?? DateTime.now();
  }

  IconData _iconForCategory(String? category) {
    switch (category) {
      case 'DAILY_REPORT':
      case 'daily':
        return Icons.event_note;
      case 'MENTION':
      case 'AT_ME':
        return Icons.alternate_email;
      case 'new_task':
        return Icons.assignment;
      case 'task_changed':
        return Icons.edit_note;
      case 'task_block':
        return Icons.block;
      case 'report_remark_review':
        return Icons.rate_review;
      default:
        return Icons.campaign;
    }
  }

  Color _iconColorForCategory(String? category) {
    switch (category) {
      case 'DAILY_REPORT':
      case 'daily':
        return const Color(0xFF19A7FF);
      case 'MENTION':
      case 'AT_ME':
        return const Color(0xFFFF5A3D);
      case 'new_task':
        return const Color(0xFF19A7FF);
      case 'task_changed':
        return const Color(0xFFFF7A1A);
      case 'task_block':
        return const Color(0xFFE74C3C);
      case 'report_remark_review':
        return const Color(0xFF3895F2);
      default:
        return const Color(0xFFFF7A1A);
    }
  }

  void _onTabChanged(int index) {
    setState(() => _currentIndex = index);
    if (index == 0) {
      _homeKey.currentState?.loadTodayStats();
    } else if (index == 1) {
      _taskKey.currentState?.refresh();
    } else if (index == 2) {
      if (Get.isRegistered<MessageController>()) {
        Get.find<MessageController>().fetchUnreadCount();
      }
    }
  }

  void _switchTab(int index) {
    _onTabChanged(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          Stack(
            children: [
              HomePage(key: _homeKey),
              FloatButton(),
            ],
          ),
          Stack(
            children: [
              TaskPage(key: _taskKey),
              FloatButton(),
            ],
          ),
          MessagePage(),
          MyPage(),
        ],
      ),
      bottomNavigationBar: Tabbar(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
      ),
    );
  }
}
