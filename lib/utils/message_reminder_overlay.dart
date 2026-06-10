import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/navigator_key.dart';

class MessageReminderOverlay {
  static OverlayEntry? _currentEntry;
  static GlobalKey<_MessageReminderOverlayState>? _currentOverlayKey;
  static final List<MessageReminderData> _pendingMessages = [];

  static final List<MessageReminderData> mockMessages = [
    MessageReminderData(
      title: '下班播报',
      time: '03-12 18:00',
      segments: [
        MessageReminderSegment(
          '您今天已完成 4 个任务。剩余 16 个任务，2 个已延期未汇报任务，请及时处理避免影响后续工作安排。',
        ),
      ],
      icon: Icons.campaign,
      iconColor: Color(0xFFFF7A1A),
      createdAt: DateTime(2026, 3, 12, 18),
    ),
    MessageReminderData(
      title: '每日播报',
      time: '03-13 09:00',
      segments: [
        MessageReminderSegment('您当前有 '),
        MessageReminderSegment('20', color: _OverlayColors.primary),
        MessageReminderSegment(' 个任务，新增 3 个任务，'),
        MessageReminderSegment(
          '2 个任务即将延期，4 个任务已延期',
          color: _OverlayColors.danger,
        ),
        MessageReminderSegment('，3 个任务已取消。请优先关注延期和即将延期任务。'),
      ],
      icon: Icons.event_note,
      iconColor: Color(0xFF19A7FF),
      createdAt: DateTime(2026, 3, 13, 9),
    ),
    MessageReminderData(
      title: '@我的',
      time: '03-12 18:00',
      segments: [
        MessageReminderSegment('张三：你的订单已经延期了，麻烦尽快安排 [图片]，如有异常请及时在任务中回复。'),
      ],
      icon: Icons.alternate_email,
      iconColor: Color(0xFFFF5A3D),
      createdAt: DateTime(2026, 3, 12, 18),
    ),
  ];

  static void showMock({VoidCallback? onTap}) {
    show(messages: mockMessages, onTap: onTap);
  }

  static void show({
    required List<MessageReminderData> messages,
    VoidCallback? onTap,
  }) {
    final overlayState = navigatorKey.currentState?.overlay;
    if (overlayState == null || messages.isEmpty) return;

    final currentState = _currentOverlayKey?.currentState;
    if (_currentEntry != null && currentState != null) {
      currentState.appendMessages(messages);
      return;
    }

    if (_currentEntry != null) {
      _pendingMessages.addAll(messages);
      return;
    }

    var removed = false;
    late final OverlayEntry entry;
    final overlayKey = GlobalKey<_MessageReminderOverlayState>();
    void close() {
      if (removed) return;
      removed = true;
      entry.remove();
      if (_currentEntry == entry) {
        _currentEntry = null;
        _currentOverlayKey = null;
      }
      _pendingMessages.clear();
    }

    entry = OverlayEntry(
      builder: (context) {
        return _MessageReminderOverlay(
          key: overlayKey,
          messages: messages,
          onClose: close,
          onTap: onTap,
        );
      },
    );

    _currentEntry = entry;
    _currentOverlayKey = overlayKey;
    overlayState.insert(entry);
  }

  static void _flushPendingMessages() {
    final currentState = _currentOverlayKey?.currentState;
    if (currentState == null || _pendingMessages.isEmpty) return;

    final messages = List<MessageReminderData>.from(_pendingMessages);
    _pendingMessages.clear();
    currentState.appendMessages(messages);
  }

  static void dismiss() {
    _currentEntry?.remove();
    _currentEntry = null;
    _currentOverlayKey = null;
    _pendingMessages.clear();
  }
}

class _MessageReminderOverlay extends StatefulWidget {
  const _MessageReminderOverlay({
    super.key,
    required this.messages,
    required this.onClose,
    this.onTap,
  });

  final List<MessageReminderData> messages;
  final VoidCallback onClose;
  final VoidCallback? onTap;

  @override
  State<_MessageReminderOverlay> createState() =>
      _MessageReminderOverlayState();
}

class _MessageReminderOverlayState extends State<_MessageReminderOverlay> {
  final Set<int> _expandedIndexes = {};
  late final List<MessageReminderData> _messages;

  @override
  void initState() {
    super.initState();
    _messages = [];
    for (final message in widget.messages) {
      _upsertMessage(message);
    }
    _sortMessages();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        MessageReminderOverlay._flushPendingMessages();
      }
    });
  }

  void appendMessages(List<MessageReminderData> messages) {
    if (messages.isEmpty) return;
    setState(() {
      for (final message in messages) {
        _upsertMessage(message);
      }
      _sortMessages();
    });
  }

  void _sortMessages() {
    _messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void _upsertMessage(MessageReminderData message) {
    final key = message.aggregateKey;
    if (key == null || key.isEmpty) {
      _messages.add(message);
      return;
    }

    final index = _messages.indexWhere((item) => item.aggregateKey == key);
    if (index == -1) {
      _messages.add(message);
      return;
    }

    _messages[index] = _messages[index].mergeWith(message);
  }

  void _toggleExpanded(int index) {
    setState(() {
      if (_expandedIndexes.contains(index)) {
        _expandedIndexes.remove(index);
      } else {
        _expandedIndexes.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, -18 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(color: const Color(0x99D8D8D8)),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(14, 18, 14, 20),
                        itemCount: _messages.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          return _ReminderCard(
                            message: message,
                            expanded: _expandedIndexes.contains(index),
                            onToggle: message.needsExpansion
                                ? () => _toggleExpanded(index)
                                : null,
                            onOpen: () {
                              widget.onTap?.call();
                              widget.onClose();
                            },
                          );
                        },
                      ),
                    ),
                    _BottomCloseButton(onTap: widget.onClose),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.message,
    required this.expanded,
    required this.onOpen,
    this.onToggle,
  });

  final MessageReminderData message;
  final bool expanded;
  final VoidCallback onOpen;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onOpen,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        constraints: const BoxConstraints(minHeight: 86),
        padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
        decoration: BoxDecoration(
          color: const Color(0xF7FFFFFF),
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: expanded
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            _MessageIcon(message: message),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TitleLine(message: message),
                  const SizedBox(height: 6),
                  RichText(
                    maxLines: expanded ? null : 1,
                    overflow: expanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                    text: TextSpan(
                      style: const TextStyle(
                        color: _OverlayColors.content,
                        fontSize: 14,
                        height: 1.3,
                      ),
                      children: message.segments
                          .map(
                            (segment) => TextSpan(
                              text: segment.text,
                              style: TextStyle(color: segment.color),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  if (expanded && message.hasMoreDetails) ...[
                    const SizedBox(height: 8),
                    _MoreMessagesButton(onTap: onOpen),
                  ],
                ],
              ),
            ),
            if (message.needsExpansion) ...[
              const SizedBox(width: 8),
              _ExpandButton(expanded: expanded, onTap: onToggle!),
            ],
          ],
        ),
      ),
    );
  }
}

class _MoreMessagesButton extends StatelessWidget {
  const _MoreMessagesButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '查看更多',
              style: TextStyle(
                color: _OverlayColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
            SizedBox(width: 2),
            Icon(Icons.chevron_right, color: _OverlayColors.primary, size: 16),
          ],
        ),
      ),
    );
  }
}

class _MessageIcon extends StatelessWidget {
  const _MessageIcon({required this.message});

  final MessageReminderData message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: message.iconColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(message.icon, color: Colors.white, size: 22),
    );
  }
}

class _TitleLine extends StatelessWidget {
  const _TitleLine({required this.message});

  final MessageReminderData message;

  @override
  Widget build(BuildContext context) {
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: const TextStyle(
          color: _OverlayColors.title,
          fontSize: 16,
          height: 1.2,
        ),
        children: [
          TextSpan(
            text: message.title,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(
            text: '  ·  ${message.time}',
            style: const TextStyle(
              color: _OverlayColors.time,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandButton extends StatelessWidget {
  const _ExpandButton({required this.expanded, required this.onTap});

  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 30,
        height: 40,
        child: AnimatedRotation(
          turns: expanded ? 0.5 : 0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: const Icon(
            Icons.keyboard_arrow_down,
            color: _OverlayColors.title,
            size: 26,
          ),
        ),
      ),
    );
  }
}

class _BottomCloseButton extends StatelessWidget {
  const _BottomCloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(Icons.close, color: Colors.black, size: 22),
      ),
    );
  }
}

class MessageReminderData {
  const MessageReminderData({
    required this.title,
    required this.time,
    required this.segments,
    required this.icon,
    required this.iconColor,
    required this.createdAt,
    this.category,
    this.aggregateKey,
    this.count = 1,
    this.detailLines = const [],
  });

  final String title;
  final String time;
  final List<MessageReminderSegment> segments;
  final IconData icon;
  final Color iconColor;
  final DateTime createdAt;
  final String? category;
  final String? aggregateKey;
  final int count;
  final List<String> detailLines;

  String get plainText => segments.map((segment) => segment.text).join();

  bool get needsExpansion => plainText.length > 28;

  bool get hasMoreDetails =>
      (aggregateKey == 'task_block' || aggregateKey == 'task_changed') &&
      detailLines.length > 1;

  MessageReminderData mergeWith(MessageReminderData other) {
    if (aggregateKey == 'new_task') {
      final total = count + other.count;
      return copyWith(
        title: other.title,
        time: other.time,
        createdAt: other.createdAt,
        segments: [
          const MessageReminderSegment('您有'),
          MessageReminderSegment('$total', color: _OverlayColors.primary),
          const MessageReminderSegment('条新任务，请及时查看'),
        ],
        count: total,
      );
    }

    if (aggregateKey == 'task_block') {
      final total = count + other.count;
      final lines = [...other.detailLines, ...detailLines];
      return copyWith(
        title: other.title,
        time: other.time,
        createdAt: other.createdAt,
        segments: _buildTaskBlockSegments(total, lines),
        count: total,
        detailLines: lines,
      );
    }

    if (aggregateKey == 'task_changed') {
      final total = count + other.count;
      final lines = [...other.detailLines, ...detailLines];
      return copyWith(
        title: other.title,
        time: other.time,
        createdAt: other.createdAt,
        segments: _buildTaskChangedSegments(total, lines),
        count: total,
        detailLines: lines,
      );
    }

    return other;
  }

  static List<MessageReminderSegment> _buildTaskChangedSegments(
    int total,
    List<String> lines,
  ) {
    final preview = lines.isEmpty ? '' : '\n${lines.first}';

    return [
      const MessageReminderSegment('您有'),
      MessageReminderSegment('$total', color: _OverlayColors.danger),
      const MessageReminderSegment('条任务产生变动，请及时处理'),
      if (preview.isNotEmpty) MessageReminderSegment(preview),
    ];
  }

  static List<MessageReminderSegment> _buildTaskBlockSegments(
    int total,
    List<String> lines,
  ) {
    final preview = lines.isEmpty ? '' : '\n${lines.first}';

    return [
      const MessageReminderSegment('您有'),
      MessageReminderSegment('$total', color: _OverlayColors.danger),
      const MessageReminderSegment('条任务阻塞提醒，请及时处理'),
      if (preview.isNotEmpty) MessageReminderSegment(preview),
    ];
  }

  MessageReminderData copyWith({
    String? title,
    String? time,
    List<MessageReminderSegment>? segments,
    IconData? icon,
    Color? iconColor,
    DateTime? createdAt,
    String? category,
    String? aggregateKey,
    int? count,
    List<String>? detailLines,
  }) {
    return MessageReminderData(
      title: title ?? this.title,
      time: time ?? this.time,
      segments: segments ?? this.segments,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      aggregateKey: aggregateKey ?? this.aggregateKey,
      count: count ?? this.count,
      detailLines: detailLines ?? this.detailLines,
    );
  }
}

class MessageReminderSegment {
  const MessageReminderSegment(
    this.text, {
    this.color = _OverlayColors.content,
  });

  final String text;
  final Color color;
}

class _OverlayColors {
  static const Color primary = Color(0xFF1D8BFF);
  static const Color danger = Color(0xFFF14F5E);
  static const Color title = Color(0xFF202124);
  static const Color content = Color(0xFF4F5359);
  static const Color time = Color(0xFF4F5359);
}
