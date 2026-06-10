import 'package:get/get.dart';
import '../models/message.dart';
import '../services/message_service.dart';

class MessageController extends GetxController {
  final MessageService _messageService = MessageService();

  var totalUnreadCount = 0.obs;
  var categoryStats = <String, int>{}.obs;
  var latestMessages = <String, MessageItemModel>{}.obs;
  var isLoading = false.obs;

  // 消息列表（分页）
  var messageList = <MessageItemModel>[].obs;
  var isLoadingMessages = false.obs;
  var isLoadingMore = false.obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var hasMore = true.obs;
  var currentCategory = ''.obs;

  Future<void> fetchUnreadCount() async {
    isLoading.value = true;
    try {
      final result = await _messageService.fetchUnreadCount();
      if (result != null) {
        totalUnreadCount.value = result.totalUnreadCount;
        categoryStats.value = result.categoryStats;
        latestMessages.value = result.latestMessages;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMessages(String category, {int current = 1}) async {
    currentCategory.value = category;
    if (current == 1) {
      isLoadingMessages.value = true;
    }
    try {
      final result = await _messageService.fetchMessageList(
        category: category,
        current: current,
      );
      if (result != null) {
        if (current == 1) {
          messageList.value = result.records;
        } else {
          messageList.addAll(result.records);
        }
        currentPage.value = result.current;
        totalPages.value = result.pages;
        hasMore.value = result.current < result.pages;
      }
    } finally {
      isLoadingMessages.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;
    await fetchMessages(currentCategory.value, current: currentPage.value + 1);
  }

  Future<bool> markAsRead(List<int> messageIds) async {
    final success = await _messageService.markAsRead(messageIds);
    if (success) {
      // 更新本地列表中的已读状态
      for (final msg in messageList) {
        if (messageIds.contains(msg.id) && msg.isRead == 0) {
          messageList[messageList.indexOf(msg)] = MessageItemModel(
            id: msg.id,
            messageType: msg.messageType,
            title: msg.title,
            content: msg.content,
            category: msg.category,
            businessId: msg.businessId,
            receiverId: msg.receiverId,
            receiverName: msg.receiverName,
            senderId: msg.senderId,
            senderName: msg.senderName,
            isRead: 1,
            readTime: msg.readTime,
            isPushed: msg.isPushed,
            pushTime: msg.pushTime,
            extraData: msg.extraData,
            createTime: msg.createTime,
            updateTime: msg.updateTime,
          );
        }
      }
      messageList.refresh();
    }
    return success;
  }

  Future<bool> markCategoryAsRead(String category) async {
    final success = await _messageService
        .markCategoryAsRead(category)
        .catchError((_) => false);
    if (!success) return false;

    final unreadCount = categoryStats[category] ?? 0;
    if (unreadCount > 0) {
      totalUnreadCount.value = (totalUnreadCount.value - unreadCount)
          .clamp(0, 1 << 31)
          .toInt();
    }
    categoryStats[category] = 0;
    categoryStats.refresh();

    final latest = latestMessages[category];
    if (latest != null && latest.isRead == 0) {
      latestMessages[category] = _copyMessageAsRead(latest);
      latestMessages.refresh();
    }

    for (var i = 0; i < messageList.length; i++) {
      final msg = messageList[i];
      if (msg.category == category && msg.isRead == 0) {
        messageList[i] = _copyMessageAsRead(msg);
      }
    }
    messageList.refresh();
    return true;
  }

  MessageItemModel _copyMessageAsRead(MessageItemModel msg) {
    return MessageItemModel(
      id: msg.id,
      messageType: msg.messageType,
      title: msg.title,
      content: msg.content,
      category: msg.category,
      businessId: msg.businessId,
      receiverId: msg.receiverId,
      receiverName: msg.receiverName,
      senderId: msg.senderId,
      senderName: msg.senderName,
      isRead: 1,
      readTime: msg.readTime,
      isPushed: msg.isPushed,
      pushTime: msg.pushTime,
      extraData: msg.extraData,
      createTime: msg.createTime,
      updateTime: msg.updateTime,
    );
  }
}
