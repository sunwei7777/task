class MessageItemModel {
  final int id;
  final int messageType;
  final String title;
  final String content;
  final String category;
  final dynamic businessId;
  final String receiverId;
  final String receiverName;
  final dynamic senderId;
  final dynamic senderName;
  final int isRead;
  final dynamic readTime;
  final int isPushed;
  final String? pushTime;
  final dynamic extraData;
  final String? createTime;
  final dynamic updateTime;

  MessageItemModel({
    required this.id,
    required this.messageType,
    required this.title,
    required this.content,
    required this.category,
    this.businessId,
    required this.receiverId,
    required this.receiverName,
    this.senderId,
    this.senderName,
    required this.isRead,
    this.readTime,
    required this.isPushed,
    this.pushTime,
    this.extraData,
    this.createTime,
    this.updateTime,
  });

  factory MessageItemModel.fromJson(Map<String, dynamic> json) {
    return MessageItemModel(
      id: json['id'] ?? 0,
      messageType: json['messageType'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? '',
      businessId: json['businessId'],
      receiverId: json['receiverId'] ?? '',
      receiverName: json['receiverName'] ?? '',
      senderId: json['senderId'],
      senderName: json['senderName'],
      isRead: json['isRead'] ?? 0,
      readTime: json['readTime'],
      isPushed: json['isPushed'] ?? 1,
      pushTime: json['pushTime'],
      extraData: json['extraData'],
      createTime: json['createTime'],
      updateTime: json['updateTime'],
    );
  }
}

class MessageUnreadResult {
  final Map<String, int> categoryStats;
  final int totalUnreadCount;
  final Map<String, MessageItemModel> latestMessages;

  MessageUnreadResult({
    required this.categoryStats,
    required this.totalUnreadCount,
    required this.latestMessages,
  });

  factory MessageUnreadResult.fromJson(Map<String, dynamic> json) {
    final rawStats = json['categoryStats'] as Map<String, dynamic>? ?? {};
    final categoryStats = <String, int>{};
    rawStats.forEach((key, value) {
      categoryStats[key] = (value as num).toInt();
    });

    final rawMessages =
        json['latestMessages'] as Map<String, dynamic>? ?? {};
    final latestMessages = <String, MessageItemModel>{};
    rawMessages.forEach((key, value) {
      if (value != null) {
        latestMessages[key] =
            MessageItemModel.fromJson(value as Map<String, dynamic>);
      }
    });

    return MessageUnreadResult(
      categoryStats: categoryStats,
      totalUnreadCount: json['totalUnreadCount'] ?? 0,
      latestMessages: latestMessages,
    );
  }
}

class MessageListResult {
  final List<MessageItemModel> records;
  final int total;
  final int size;
  final int current;
  final int pages;

  MessageListResult({
    required this.records,
    required this.total,
    required this.size,
    required this.current,
    required this.pages,
  });

  factory MessageListResult.fromJson(Map<String, dynamic> json) {
    return MessageListResult(
      records: (json['records'] as List<dynamic>?)
              ?.map((e) =>
                  MessageItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['total'] ?? 0,
      size: json['size'] ?? 10,
      current: json['current'] ?? 1,
      pages: json['pages'] ?? 1,
    );
  }
}

class WorkTimeReport {
  final String userName;
  final String userId;
  final int completedTasks;
  final int remainingTasks;
  final int overdueTasks;
  final String? createTime;

  WorkTimeReport({
    required this.userName,
    required this.userId,
    required this.completedTasks,
    required this.remainingTasks,
    required this.overdueTasks,
    this.createTime,
  });

  factory WorkTimeReport.fromJson(Map<String, dynamic> json) {
    return WorkTimeReport(
      userName: json['userName'] ?? '',
      userId: json['userId'] ?? '',
      completedTasks: json['completedTasks'] ?? 0,
      remainingTasks: json['remainingTasks'] ?? 0,
      overdueTasks: json['overdueTasks'] ?? 0,
      createTime: json['createTime'],
    );
  }
}
