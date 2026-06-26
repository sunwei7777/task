import 'package:get/get.dart';
import '../models/message.dart';
import '../services/message_service.dart';

class RemarkController extends GetxController {
  final MessageService _messageService = MessageService();

  var remarkList = <RemarkReviewItem>[].obs;
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var hasMore = true.obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;

  // 筛选条件
  var currentTaskType = Rxn<int>(); // null=全部, 1=项目集, 2=项目管理, 9=打样
  var currentReadStatus = Rxn<int>(); // null=全部, 0=未读, 1=已读
  var currentBillNo = ''.obs;
  var currentStyleCode = ''.obs;
  var currentExpectFinishDate = ''.obs;

  // 未读数量
  var currentUnread = 0.obs;
  // 按任务类型的未读数量：{1: 3, 2: 5, 9: 2}
  var unreadByTaskType = <int, int>{}.obs;

  // 批量选择
  var selectedReviewIds = <int>{}.obs;

  bool isSelected(int reviewId) => selectedReviewIds.contains(reviewId);

  void toggleSelection(int reviewId) {
    if (selectedReviewIds.contains(reviewId)) {
      selectedReviewIds.remove(reviewId);
    } else {
      selectedReviewIds.add(reviewId);
    }
    selectedReviewIds.refresh();
  }

  void clearSelection() {
    selectedReviewIds.clear();
  }

  Future<void> batchMarkReadSelected() async {
    if (selectedReviewIds.isEmpty) return;
    final ids = selectedReviewIds.toList();
    await batchMarkRead(ids);
    clearSelection();
  }

  Future<void> _doFetch({int current = 1}) async {
    if (current == 1) {
      isLoading.value = true;
    }
    try {
      final result = await _messageService.fetchRemarkReviewList(
        taskType: currentTaskType.value,
        readStatus: currentReadStatus.value,
        billNo:
            currentBillNo.value.isEmpty ? null : currentBillNo.value,
        styleCode:
            currentStyleCode.value.isEmpty ? null : currentStyleCode.value,
        expectFinishDate: currentExpectFinishDate.value.isEmpty
            ? null
            : currentExpectFinishDate.value,
        current: current,
      );
      if (result != null) {
        if (current == 1) {
          remarkList.value = result.records;
        } else {
          remarkList.addAll(result.records);
        }
        currentPage.value = result.current;
        totalPages.value = result.pages;
        hasMore.value = result.current < result.pages;
        currentUnread.value = result.currentUnread;
        unreadByTaskType.value = result.unreadByTaskType;
      }
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;
    await _doFetch(current: currentPage.value + 1);
  }

  Future<void> refresh() async {
    await _doFetch();
  }

  /// 切换顶部任务类型 tab
  void selectTaskType(int? taskType) {
    currentTaskType.value = taskType;
    _doFetch();
  }

  /// 发送意见
  Future<bool> submitComment(int reviewId, String comment) async {
    final success = await _messageService.submitRemarkComment(reviewId, comment);
    if (success) {
      // 成功后标记已读
      await _messageService.batchMarkRemarkRead([reviewId]);
      await refresh();
    }
    return success;
  }

  /// 标记已读
  Future<bool> batchMarkRead(List<int> reviewIds) async {
    final success = await _messageService.batchMarkRemarkRead(reviewIds);
    if (success) {
      await refresh();
    }
    return success;
  }

  /// 底部筛选弹窗确定后调用
  void applyFilter({
    int? readStatus,
    String billNo = '',
    String styleCode = '',
    String expectFinishDate = '',
  }) {
    currentReadStatus.value = readStatus;
    currentBillNo.value = billNo;
    currentStyleCode.value = styleCode;
    currentExpectFinishDate.value = expectFinishDate;
    _doFetch();
  }
}
