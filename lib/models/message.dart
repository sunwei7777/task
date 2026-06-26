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

    final rawMessages = json['latestMessages'] as Map<String, dynamic>? ?? {};
    final latestMessages = <String, MessageItemModel>{};
    rawMessages.forEach((key, value) {
      if (value != null) {
        latestMessages[key] = MessageItemModel.fromJson(
          value as Map<String, dynamic>,
        );
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
      records:
          (json['records'] as List<dynamic>?)
              ?.map((e) => MessageItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['total'] ?? 0,
      size: json['size'] ?? 10,
      current: json['current'] ?? 1,
      pages: json['pages'] ?? 1,
    );
  }
}

// 备注处理 - 图片附件
class RemarkImage {
  final int id;
  final int attachmentType;
  final String fileName;
  final String fileNameOriginal;
  final String filePath;
  final int fileSize;
  final String mimeType;
  final String uploader;
  final String uploaderName;
  final String uploadTime;
  final String createTime;
  final String updateTime;

  RemarkImage({
    required this.id,
    required this.attachmentType,
    required this.fileName,
    required this.fileNameOriginal,
    required this.filePath,
    required this.fileSize,
    required this.mimeType,
    required this.uploader,
    required this.uploaderName,
    required this.uploadTime,
    required this.createTime,
    required this.updateTime,
  });

  factory RemarkImage.fromJson(Map<String, dynamic> json) {
    return RemarkImage(
      id: json['id'] ?? 0,
      attachmentType: json['attachmentType'] ?? 0,
      fileName: json['fileName'] ?? '',
      fileNameOriginal: json['fileNameOriginal'] ?? '',
      filePath: json['filePath'] ?? '',
      fileSize: json['fileSize'] ?? 0,
      mimeType: json['mimeType'] ?? '',
      uploader: json['uploader'] ?? '',
      uploaderName: json['uploaderName'] ?? '',
      uploadTime: json['uploadTime'] ?? '',
      createTime: json['createTime'] ?? '',
      updateTime: json['updateTime'] ?? '',
    );
  }
}

// 备注处理 - 意见
class RemarkComment {
  final int id;
  final String commenterName;
  final String content;
  final String createTime;

  RemarkComment({
    required this.id,
    required this.commenterName,
    required this.content,
    required this.createTime,
  });

  factory RemarkComment.fromJson(Map<String, dynamic> json) {
    return RemarkComment(
      id: json['id'] ?? 0,
      commenterName: json['commenterName'] ?? '',
      content: json['content'] ?? '',
      createTime: json['createTime'] ?? '',
    );
  }
}

// 备注处理 - 审批人
class RemarkReviewer {
  final int reviewId;
  final String reviewerName;
  final int readStatus;
  final String? readTime;
  final int commentCount;
  final String? latestComment;
  final String? latestCommentTime;
  final List<RemarkComment> comments;

  RemarkReviewer({
    required this.reviewId,
    required this.reviewerName,
    required this.readStatus,
    this.readTime,
    required this.commentCount,
    this.latestComment,
    this.latestCommentTime,
    required this.comments,
  });

  factory RemarkReviewer.fromJson(Map<String, dynamic> json) {
    return RemarkReviewer(
      reviewId: json['reviewId'] ?? 0,
      reviewerName: json['reviewerName'] ?? '',
      readStatus: json['readStatus'] ?? 0,
      readTime: json['readTime'],
      commentCount: json['commentCount'] ?? 0,
      latestComment: json['latestComment'],
      latestCommentTime: json['latestCommentTime'],
      comments:
          (json['comments'] as List<dynamic>?)
              ?.map((e) => RemarkComment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

// 备注处理 - 列表项
class RemarkReviewItem {
  final int reviewId;
  final int reportId;
  final int taskId;
  final String taskNo;
  final int taskType;
  final String submitTime;
  final String processName;
  final String taskStartTime;
  final String taskEndTime;
  final String reporterName;
  final String expectFinishDate;
  final String remark;
  final List<RemarkImage> images;
  final int readStatus;
  final String? readTime;
  final String? latestComment;
  final String? latestCommentTime;
  final int commentCount;
  final String styleCode;
  final String billNo;
  final String viewRole;
  final List<RemarkReviewer> reviewers;

  RemarkReviewItem({
    required this.reviewId,
    required this.reportId,
    required this.taskId,
    required this.taskNo,
    required this.taskType,
    required this.submitTime,
    required this.processName,
    required this.taskStartTime,
    required this.taskEndTime,
    required this.reporterName,
    required this.expectFinishDate,
    required this.remark,
    required this.images,
    required this.readStatus,
    this.readTime,
    this.latestComment,
    this.latestCommentTime,
    required this.commentCount,
    required this.styleCode,
    required this.billNo,
    required this.viewRole,
    required this.reviewers,
  });

  factory RemarkReviewItem.fromJson(Map<String, dynamic> json) {
    return RemarkReviewItem(
      reviewId: json['reviewId'] ?? 0,
      reportId: json['reportId'] ?? 0,
      taskId: json['taskId'] ?? 0,
      taskNo: json['taskNo'] ?? '',
      taskType: json['taskType'] ?? 0,
      submitTime: json['submitTime'] ?? '',
      processName: json['processName'] ?? '',
      taskStartTime: json['taskStartTime'] ?? '',
      taskEndTime: json['taskEndTime'] ?? '',
      reporterName: json['reporterName'] ?? '',
      expectFinishDate: json['expectFinishDate'] ?? '',
      remark: json['remark'] ?? '',
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => RemarkImage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      readStatus: json['readStatus'] ?? 0,
      readTime: json['readTime'],
      latestComment: json['latestComment'],
      latestCommentTime: json['latestCommentTime'],
      commentCount: json['commentCount'] ?? 0,
      styleCode: json['styleCode'] ?? '',
      billNo: json['billNo'] ?? '',
      viewRole: json['viewRole'] ?? '',
      reviewers:
          (json['reviewers'] as List<dynamic>?)
              ?.map((e) => RemarkReviewer.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

// 备注处理 - 分页结果
class RemarkReviewListResult {
  final List<RemarkReviewItem> records;
  final int total;
  final int size;
  final int current;
  final int pages;
  final int currentUnread;
  final Map<int, int> unreadByTaskType;

  RemarkReviewListResult({
    required this.records,
    required this.total,
    required this.size,
    required this.current,
    required this.pages,
    required this.currentUnread,
    required this.unreadByTaskType,
  });

  factory RemarkReviewListResult.fromJson(Map<String, dynamic> json) {
    final unreadStatsJson = json['unreadStats'] as Map<String, dynamic>? ?? {};
    final byTaskType = <int, int>{};
    (unreadStatsJson['byTaskType'] as Map<String, dynamic>? ?? {}).forEach((
      k,
      v,
    ) {
      byTaskType[int.tryParse(k) ?? 0] = (v as num).toInt();
    });

    return RemarkReviewListResult(
      records:
          (json['records'] as List<dynamic>?)
              ?.map((e) => RemarkReviewItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['total'] ?? 0,
      size: json['size'] ?? 20,
      current: json['current'] ?? 1,
      pages: json['pages'] ?? 1,
      currentUnread: json['currentUnread'] ?? 0,
      unreadByTaskType: byTaskType,
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
