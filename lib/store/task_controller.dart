import 'package:get/get.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class TaskController extends GetxController {
  final TaskService _taskService = TaskService();

  var allTasks = <Task>[].obs;
  var filteredTasks = <Task>[].obs;
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var hasMore = true.obs;

  // 当前筛选条件
  var currentStatus = Rxn<String>();
  var currentTaskType = Rxn<int>();
  var currentStyleCode = Rxn<String>();
  var currentBillNo = Rxn<String>();
  var currentTaskNo = Rxn<String>();
  var currentTaskName = Rxn<String>();
  var currentStartTime = Rxn<String>();
  var currentEndTime = Rxn<String>();
  var currentOperator = Rxn<String>();
  var currentOperator1 = Rxn<String>();
  var sortField = Rxn<String>();
  var sortOrder = Rxn<String>();
  // 当前任务
  var currentTask = Rxn<Task>();

  // 统计数据
  var totalCount = 0.obs;
  var pendingCount = 0.obs;
  var completedCount = 0.obs;
  var cancelledCount = 0.obs;
  var overtimeCount = 0.obs;

  // 按任务类型缓存统计数据
  final taskTypeCounts = <int, TaskListResult>{}.obs;

  // 其他任务统计
  final otherTaskCounts = OtherTaskCounts().obs;

  // 分页
  var currentPage = 1.obs;
  var totalPages = 1.obs;

  void setCurrentTask(Task task) {
    currentTask.value = task;
  }

  void clearCurrentTask() {
    currentTask.value = null;
  }

  void updateTaskProgress(int taskId, double newProgress) {
    final idx = allTasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      allTasks[idx] = Task(
        id: allTasks[idx].id,
        taskNo: allTasks[idx].taskNo,
        billNo: allTasks[idx].billNo,
        styleCode: allTasks[idx].styleCode,
        taskType: allTasks[idx].taskType,
        taskTypeDesc: allTasks[idx].taskTypeDesc,
        companyName: allTasks[idx].companyName,
        companyId: allTasks[idx].companyId,
        taskName: allTasks[idx].taskName,
        taskContent: allTasks[idx].taskContent,
        startTime: allTasks[idx].startTime,
        endTime: allTasks[idx].endTime,
        principalsList: allTasks[idx].principalsList,
        collaboratorsList: allTasks[idx].collaboratorsList,
        ccPersonsList: allTasks[idx].ccPersonsList,
        contactPhonesList: allTasks[idx].contactPhonesList,
        contactAddressesList: allTasks[idx].contactAddressesList,
        status: allTasks[idx].status,
        statusDesc: allTasks[idx].statusDesc,
        progress: newProgress,
        reportMethod: allTasks[idx].reportMethod,
        creatorName: allTasks[idx].creatorName,
        principals: allTasks[idx].principals,
      );
      allTasks.refresh();
    }
    if (currentTask.value?.id == taskId) {
      currentTask.value = Task(
        id: currentTask.value!.id,
        taskNo: currentTask.value!.taskNo,
        billNo: currentTask.value!.billNo,
        styleCode: currentTask.value!.styleCode,
        taskType: currentTask.value!.taskType,
        taskTypeDesc: currentTask.value!.taskTypeDesc,
        companyName: currentTask.value!.companyName,
        companyId: currentTask.value!.companyId,
        taskName: currentTask.value!.taskName,
        taskContent: currentTask.value!.taskContent,
        startTime: currentTask.value!.startTime,
        endTime: currentTask.value!.endTime,
        principalsList: currentTask.value!.principalsList,
        collaboratorsList: currentTask.value!.collaboratorsList,
        ccPersonsList: currentTask.value!.ccPersonsList,
        contactPhonesList: currentTask.value!.contactPhonesList,
        contactAddressesList: currentTask.value!.contactAddressesList,
        status: currentTask.value!.status,
        statusDesc: currentTask.value!.statusDesc,
        progress: newProgress,
        reportMethod: currentTask.value!.reportMethod,
        creatorName: currentTask.value!.creatorName,
        principals: currentTask.value!.principals,
      );
      currentTask.refresh();
    }
  }

  Future<void> fetchTasks({
    String? statusTab,
    int? taskType,
    String? styleCode,
    String? billNo,
    String? taskNo,
    String? taskName,
    String? startTime,
    String? endTime,
    String? operator,
    String? operator1,
    String? sortField,
    String? sortOrder,
  }) async {
    currentStatus.value = statusTab;
    currentTaskType.value = taskType;
    currentStyleCode.value = styleCode;
    currentBillNo.value = billNo;
    currentTaskNo.value = taskNo;
    currentTaskName.value = taskName;
    currentStartTime.value = startTime;
    currentEndTime.value = endTime;
    currentOperator.value = operator;
    currentOperator1.value = operator1;
    this.sortField.value = sortField;
    this.sortOrder.value = sortOrder;

    isLoading.value = true;
    try {
      final result = await _taskService.fetchTaskList(
        statusTab: statusTab,
        taskType: taskType,
        styleCode: styleCode,
        billNo: billNo,
        taskNo: taskNo,
        taskName: taskName,
        startTime: startTime,
        endTime: endTime,
        operator: operator,
        operator1: operator1,
        sortField: sortField,
        sortOrder: sortOrder,
      );
      allTasks.value = result.records;
      totalCount.value = result.totalCount;
      pendingCount.value = result.pendingCount;
      completedCount.value = result.completedCount;
      cancelledCount.value = result.cancelledCount;
      overtimeCount.value = result.overtimeCount;
      currentPage.value = result.page.current;
      totalPages.value = result.page.pages;
      hasMore.value = result.page.current < result.page.pages;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshTaskList() async {
    await fetchTasks(
      statusTab: currentStatus.value,
      taskType: currentTaskType.value,
      styleCode: currentStyleCode.value,
      billNo: currentBillNo.value,
      taskNo: currentTaskNo.value,
      taskName: currentTaskName.value,
      startTime: currentStartTime.value,
      endTime: currentEndTime.value,
      sortField: sortField.value,
      sortOrder: sortOrder.value,
    );
  }

  Future<void> fetchTaskTypeCounts(int taskType) async {
    final result = await _taskService.fetchTaskList(taskType: taskType);
    taskTypeCounts[taskType] = result;
    taskTypeCounts.refresh();
  }

  Future<void> fetchOtherTaskCounts({
    required String startTime,
    required String endTime,
  }) async {
    final result = await _taskService.fetchOtherTaskCounts(
      startTime: startTime,
      endTime: endTime,
    );
    otherTaskCounts.value = result;
  }

  Future<void> fetchAllTaskTypeCounts({
    required String startTime,
    required String endTime,
  }) async {
    await Future.wait([
      fetchTaskTypeCounts(1),
      fetchTaskTypeCounts(2),
      fetchTaskTypeCounts(9),
      fetchOtherTaskCounts(startTime: startTime, endTime: endTime),
    ]);
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;

    final nextPage = currentPage.value + 1;
    isLoadingMore.value = true;
    try {
      final result = await _taskService.fetchTaskList(
        statusTab: currentStatus.value,
        taskType: currentTaskType.value,
        styleCode: currentStyleCode.value,
        billNo: currentBillNo.value,
        taskNo: currentTaskNo.value,
        taskName: currentTaskName.value,
        startTime: currentStartTime.value,
        endTime: currentEndTime.value,
        operator: currentOperator.value,
        operator1: currentOperator1.value,
        currentPage: nextPage,
        sortField: sortField.value,
        sortOrder: sortOrder.value,
      );
      allTasks.addAll(result.records);
      currentPage.value = result.page.current;
      totalPages.value = result.page.pages;
      hasMore.value = result.page.current < result.page.pages;
    } finally {
      isLoadingMore.value = false;
    }
  }
}
