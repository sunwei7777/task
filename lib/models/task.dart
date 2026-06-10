class Task {
  final int id;
  final String taskNo;
  final String? billNo;
  final String? styleCode;
  final int taskType;
  final String taskTypeDesc;
  final String companyName;
  final String companyId;
  final String taskName;
  final String? taskContent;
  final String? startTime;
  final String? endTime;
  final List<String> principalsList;
  final List<String> collaboratorsList;
  final List<String> ccPersonsList;
  final String? principals;
  final String? collaborators;
  final String? ccPersons;
  final List<dynamic>? relatedCompaniesList;
  final String? relatedProjectOrder;
  final String? contactPerson;
  final String? contactPhones;
  final String? contactAddresses;
  final List<String> contactPhonesList;
  final List<String> contactAddressesList;
  final String status;
  final String statusDesc;
  final String? taskSource;
  final String? actualStartTime;
  final String? actualCompletionTime;
  final double progress;
  final String? creator;
  final String? creatorName;
  final String? createTime;
  final String? updater;
  final String? updaterName;
  final String? updateTime;
  final List<Attachment>? attachments;
  final String? cycleConfig;
  final String? cycleTaskNo;
  final String? reportMethod;
  final int? originTaskId;

  Task({
    required this.id,
    required this.taskNo,
    this.billNo,
    this.styleCode,
    required this.taskType,
    required this.taskTypeDesc,
    required this.companyName,
    required this.companyId,
    required this.taskName,
    this.taskContent,
    this.startTime,
    this.endTime,
    required this.principalsList,
    required this.collaboratorsList,
    required this.ccPersonsList,
    this.principals,
    this.collaborators,
    this.ccPersons,
    this.relatedCompaniesList,
    this.relatedProjectOrder,
    this.contactPerson,
    this.contactPhones,
    this.contactAddresses,
    required this.contactPhonesList,
    required this.contactAddressesList,
    required this.status,
    required this.statusDesc,
    this.taskSource,
    this.actualStartTime,
    this.actualCompletionTime,
    required this.progress,
    this.creator,
    this.creatorName,
    this.createTime,
    this.updater,
    this.updaterName,
    this.updateTime,
    this.attachments,
    this.cycleConfig,
    this.cycleTaskNo,
    this.reportMethod,
    this.originTaskId,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? 0,
      taskNo: json['taskNo'] ?? '',
      billNo: json['billNo'],
      styleCode: json['styleCode'],
      taskType: json['taskType'] ?? 0,
      taskTypeDesc: json['taskTypeDesc'] ?? '',
      companyName: json['companyName'] ?? '',
      companyId: json['companyId']?.toString() ?? '',
      taskName: json['taskName'] ?? '',
      taskContent: json['taskContent'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      principalsList:
          (json['principalsList'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      collaboratorsList:
          (json['collaboratorsList'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      ccPersonsList:
          (json['ccPersonsList'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      principals: json['principals'],
      collaborators: json['collaborators'],
      ccPersons: json['ccPersons'],
      relatedCompaniesList: json['relatedCompaniesList'],
      relatedProjectOrder: json['relatedProjectOrder'],
      contactPerson: json['contactPerson'],
      contactPhones: json['contactPhones'],
      contactAddresses: json['contactAddresses'],
      contactPhonesList:
          (json['contactPhonesList'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      contactAddressesList:
          (json['contactAddressesList'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      status: json['status'] ?? '',
      statusDesc: json['statusDesc'] ?? '',
      taskSource: json['taskSource'],
      actualStartTime: json['actualStartTime'],
      actualCompletionTime: json['actualCompletionTime'],
      progress: (json['progress'] ?? 0).toDouble(),
      creator: json['creator']?.toString(),
      creatorName: json['creatorName'],
      createTime: json['createTime'],
      updater: json['updater']?.toString(),
      updaterName: json['updaterName'],
      updateTime: json['updateTime'],
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => Attachment.fromJson(e as Map<String, dynamic>))
          .toList(),
      cycleConfig: json['cycleConfig'],
      cycleTaskNo: json['cycleTaskNo'],
      reportMethod: json['reportMethod'] ?? '整体汇报',
      originTaskId: json['originTaskId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskNo': taskNo,
      'billNo': billNo,
      'styleCode': styleCode,
      'taskType': taskType,
      'taskTypeDesc': taskTypeDesc,
      'companyName': companyName,
      'companyId': companyId,
      'taskName': taskName,
      'taskContent': taskContent,
      'startTime': startTime,
      'endTime': endTime,
      'principalsList': principalsList,
      'collaboratorsList': collaboratorsList,
      'ccPersonsList': ccPersonsList,
      'principals': principals,
      'collaborators': collaborators,
      'ccPersons': ccPersons,
      'contactPhonesList': contactPhonesList,
      'contactAddressesList': contactAddressesList,
      'status': status,
      'statusDesc': statusDesc,
      'taskSource': taskSource,
      'actualStartTime': actualStartTime,
      'actualCompletionTime': actualCompletionTime,
      'progress': progress,
      'creator': creator,
      'creatorName': creatorName,
      'createTime': createTime,
      'updater': updater,
      'updaterName': updaterName,
      'updateTime': updateTime,
    };
  }
}

class Attachment {
  final int id;
  final int attachmentType;
  final String attachmentTypeDesc;
  final String fileName;
  final String filePath;
  final int fileSize;
  final String uploader;
  final String uploaderName;
  final String uploadTime;
  final String fileNameOriginal;

  Attachment({
    required this.id,
    required this.attachmentType,
    required this.attachmentTypeDesc,
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.uploader,
    required this.uploaderName,
    required this.uploadTime,
    required this.fileNameOriginal,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'] ?? 0,
      attachmentType: json['attachmentType'] ?? 0,
      attachmentTypeDesc: json['attachmentTypeDesc'] ?? '',
      fileName: json['fileName'] ?? '',
      filePath: json['filePath'] ?? '',
      fileSize: json['fileSize'] ?? 0,
      uploader: json['uploader']?.toString() ?? '',
      uploaderName: json['uploaderName'] ?? '',
      uploadTime: json['uploadTime'] ?? '',
      fileNameOriginal: json['fileNameOriginal'] ?? '',
    );
  }

  bool get isImage => attachmentType == 1;
  bool get isVideo => attachmentType == 3;
}

// 分页信息
class PageInfo {
  final int total;
  final int size;
  final int current;
  final int pages;

  PageInfo({
    required this.total,
    required this.size,
    required this.current,
    required this.pages,
  });

  factory PageInfo.fromJson(Map<String, dynamic> json) {
    return PageInfo(
      total: json['total'] ?? 0,
      size: json['size'] ?? 20,
      current: json['current'] ?? 1,
      pages: json['pages'] ?? 1,
    );
  }
}

// 接口返回的 result
class TaskListResult {
  final List<Task> records;
  final PageInfo page;
  final int totalCount;
  final int pendingCount;
  final int completedCount;
  final int cancelledCount;
  final int overtimeCount;

  TaskListResult({
    required this.records,
    required this.page,
    required this.totalCount,
    required this.pendingCount,
    required this.completedCount,
    required this.cancelledCount,
    required this.overtimeCount,
  });

  factory TaskListResult.fromJson(Map<String, dynamic> json) {
    final pageData = json['page'] as Map<String, dynamic>;
    return TaskListResult(
      records:
          (pageData['records'] as List<dynamic>?)
              ?.map((e) => Task.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      page: PageInfo.fromJson(pageData),
      totalCount: json['totalCount'] ?? 0,
      pendingCount: json['pendingCount'] ?? 0,
      completedCount: json['completedCount'] ?? 0,
      cancelledCount: json['cancelledCount'] ?? 0,
      overtimeCount: json['overtimeCount'] ?? 0,
    );
  }
}

class ReportHistoryItem {
  final int id;
  final String taskNo;
  final int applyType;
  final String applyReason;
  final String? remark;
  final String? workTime;
  final String? content;
  final String? formattedProgress;
  final String? reportMethod;
  final String? createTime;
  final String? createUser;
  final double progress;
  final String? startTime;
  final String? endTime;
  final List<dynamic> attachmentList;
  final List<dynamic> videoList;
  final List<dynamic> imageList;
  final List<dynamic> styleDetailList;
  final List<dynamic> skuDetailList;

  ReportHistoryItem({
    required this.id,
    required this.taskNo,
    required this.applyType,
    required this.applyReason,
    this.remark,
    this.workTime,
    this.content,
    this.formattedProgress,
    this.reportMethod,
    this.createTime,
    this.createUser,
    required this.progress,
    this.startTime,
    this.endTime,
    required this.attachmentList,
    required this.videoList,
    required this.imageList,
    required this.styleDetailList,
    required this.skuDetailList,
  });

  factory ReportHistoryItem.fromJson(Map<String, dynamic> json) {
    return ReportHistoryItem(
      id: json['id'] ?? 0,
      taskNo: json['taskNo'] ?? '',
      applyType: json['applyType'] ?? 0,
      applyReason: json['applyReason'] ?? '',
      remark: json['remark'],
      workTime: json['workTime'],
      content: json['content'],
      formattedProgress: json['formattedProgress'],
      reportMethod: json['reportMethod'],
      createTime: json['createTime'],
      createUser: json['createUser'],
      progress: (json['progress'] ?? 0).toDouble(),
      startTime: json['startTime'],
      endTime: json['endTime'],
      attachmentList: json['attachmentList'] ?? [],
      videoList: json['videoList'] ?? [],
      imageList: json['imageList'] ?? [],
      styleDetailList: json['styleDetails'] ?? [],
      skuDetailList: json['skuDetails'] ?? [],
    );
  }
}

class SkuItem {
  final int id;
  final String? color;
  final String? size;
  final double qty;
  final double reportedQty;
  double reportQty;
  final String? unit;

  SkuItem({
    required this.id,
    this.color,
    this.size,
    required this.qty,
    required this.reportedQty,
    required this.reportQty,
    this.unit,
  });

  factory SkuItem.fromJson(Map<String, dynamic> json) {
    return SkuItem(
      id: json['id'] ?? 0,
      color: json['color'],
      size: json['size'],
      qty: (json['qty'] ?? 0).toDouble(),
      reportedQty: (json['reportedQty'] ?? 0).toDouble(),
      reportQty: (json['reportQty'] ?? 0).toDouble(),
      unit: json['unit'],
    );
  }
}

class MyReportResult {
  final TimeStats timeStats;
  final DailyStats dailyStats;
  final List<CalendarDay> calendarData;
  final List<ReportDataItem> reportDataList;

  MyReportResult({
    required this.timeStats,
    required this.dailyStats,
    required this.calendarData,
    required this.reportDataList,
  });

  factory MyReportResult.fromJson(Map<String, dynamic> json) {
    return MyReportResult(
      timeStats: TimeStats.fromJson(json['timeStats'] as Map<String, dynamic>),
      dailyStats: DailyStats.fromJson(json['dailyStats'] as Map<String, dynamic>),
      calendarData: (json['calendarData'] as List<dynamic>?)
              ?.map((e) => CalendarDay.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      reportDataList: (json['reportDataList'] as List<dynamic>?)
              ?.map((e) => ReportDataItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class TimeStats {
  final int totalOnlineTime;
  final int reportedTime;
  final int reportedTasks;
  TimeStats({
    required this.totalOnlineTime,
    required this.reportedTime,
    required this.reportedTasks,
  });
  factory TimeStats.fromJson(Map<String, dynamic> json) {
    return TimeStats(
      totalOnlineTime: json['totalOnlineTime'] ?? 0,
      reportedTime: json['reportedTime'] ?? 0,
      reportedTasks: json['reportedTasks'] ?? 0,
    );
  }
}

class DailyStats {
  final int onlineTime;
  final String? loginTime;
  final String? logoutTime;
  final int reportedTime;
  final int reportCount;
  final int completedCount;
  final int inProgressCount;
  final int delayedCount;
  DailyStats({
    required this.onlineTime,
    this.loginTime,
    this.logoutTime,
    required this.reportedTime,
    required this.reportCount,
    required this.completedCount,
    required this.inProgressCount,
    required this.delayedCount,
  });
  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      onlineTime: json['onlineTime'] ?? 0,
      loginTime: json['loginTime'],
      logoutTime: json['logoutTime'],
      reportedTime: json['reportedTime'] ?? 0,
      reportCount: json['reportCount'] ?? 0,
      completedCount: json['completedCount'] ?? 0,
      inProgressCount: json['inProgressCount'] ?? 0,
      delayedCount: json['delayedCount'] ?? 0,
    );
  }
  String get formattedOnlineTime {
    final hours = onlineTime ~/ 3600;
    final minutes = (onlineTime % 3600) ~/ 60;
    return '${hours}小时${minutes}分';
  }
}

class CalendarDay {
  final String date;
  final bool hasReport;
  CalendarDay({required this.date, required this.hasReport});
  factory CalendarDay.fromJson(Map<String, dynamic> json) {
    return CalendarDay(
      date: json['date'] ?? '',
      hasReport: json['hasReport'] ?? false,
    );
  }
}

class ReportDataItem {
  final int taskId;
  final String? taskName;
  final String? createTime;
  final String? createUser;
  final String? totalProgress;
  final String? reportedProgress;
  final String? applyType;
  final String? workTime;
  final String? formattedWorkTime;
  final String? reportUser;
  final String? reportTime;

  ReportDataItem({
    required this.taskId,
    this.taskName,
    this.createTime,
    this.createUser,
    this.totalProgress,
    this.reportedProgress,
    this.applyType,
    this.workTime,
    this.formattedWorkTime,
    this.reportUser,
    this.reportTime,
  });

  factory ReportDataItem.fromJson(Map<String, dynamic> json) {
    return ReportDataItem(
      taskId: json['taskId'] ?? 0,
      taskName: json['taskName'],
      createTime: json['createTime'],
      createUser: json['createUser'],
      totalProgress: json['totalProgress']?.toString(),
      reportedProgress: json['reportedProgress']?.toString(),
      applyType: json['applyType'],
      workTime: json['workTime'],
      formattedWorkTime: json['formattedWorkTime'],
      reportUser: json['reportUser'],
      reportTime: json['reportTime'],
    );
  }
}

class OtherTaskCounts {
  final int periodic;
  final int temporary;
  final int meeting;
  final int dispatch;

  OtherTaskCounts({
    this.periodic = 0,
    this.temporary = 0,
    this.meeting = 0,
    this.dispatch = 0,
  });

  factory OtherTaskCounts.fromJson(Map<String, dynamic> json) {
    return OtherTaskCounts(
      periodic: json['periodic'] ?? 0,
      temporary: json['temporary'] ?? 0,
      meeting: json['meeting'] ?? 0,
      dispatch: json['dispatch'] ?? 0,
    );
  }
}

class ReportItem {
  final int id;
  final String? materialName;
  final String? spec1;
  final String? spec2;
  final String? supplier;
  final String? remark;
  final double qty;
  final String? unit;
  final int? taskId;
  final double completeNum;
  double currentReportNum;

  ReportItem({
    required this.id,
    this.materialName,
    this.spec1,
    this.spec2,
    this.supplier,
    this.remark,
    required this.qty,
    this.unit,
    this.taskId,
    required this.completeNum,
    required this.currentReportNum,
  });

  factory ReportItem.fromJson(Map<String, dynamic> json) {
    return ReportItem(
      id: json['id'] ?? 0,
      materialName: json['materialName'],
      spec1: json['spec1'],
      spec2: json['spec2'],
      supplier: json['supplier'],
      remark: json['remark'],
      qty: (json['qty'] ?? 0).toDouble(),
      unit: json['unit'],
      taskId: json['taskId'],
      completeNum: (json['completeNum'] ?? 0).toDouble(),
      currentReportNum: (json['currentReportNum'] ?? 0).toDouble(),
    );
  }
}

class PreTaskDetail {
  final int node;
  final String taskName;
  final int progress;
  final String director;

  PreTaskDetail({
    required this.node,
    required this.taskName,
    required this.progress,
    required this.director,
  });

  factory PreTaskDetail.fromJson(Map<String, dynamic> json) {
    return PreTaskDetail(
      node: json['node'] ?? 0,
      taskName: json['taskName'] ?? '',
      progress: (json['progress'] ?? 0) as int,
      director: json['director'] ?? '',
    );
  }
}

class PreTaskCheckResult {
  final String checkStatus;
  final String? message;
  final List<PreTaskDetail> preTaskDetails;

  PreTaskCheckResult({
    required this.checkStatus,
    this.message,
    required this.preTaskDetails,
  });

  factory PreTaskCheckResult.fromJson(Map<String, dynamic> json) {
    return PreTaskCheckResult(
      checkStatus: json['checkStatus'] ?? 'pass',
      message: json['message'],
      preTaskDetails: (json['preTaskDetails'] as List<dynamic>?)
              ?.map((e) => PreTaskDetail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
