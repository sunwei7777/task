import 'package:flutter/material.dart';
import 'package:flutter_application_1/assets/app_styles.dart';
import 'package:flutter_application_1/services/storage_service.dart';
import 'package:flutter_application_1/task/create_task.dart';
import 'package:flutter_application_1/utils/dialog_custom.dart';
import 'package:flutter_application_1/report/report_progress.dart';
import 'package:flutter_application_1/task/select_principal.dart';
import 'package:flutter_application_1/task/select_principal_more.dart';
import 'package:flutter_application_1/task/select_task_bottom.dart';
import 'package:flutter_application_1/task/task_look_bottom.dart';
import 'package:flutter_application_1/utils/voice_recorder.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/report/report_form_shared.dart';
import 'package:flutter_application_1/report/progress_exceed_dialog.dart';
import 'package:flutter_application_1/services/task_service.dart';
import 'package:flutter_application_1/store/task_controller.dart';
import 'package:flutter_application_1/individual_statistics.dart';
import 'package:flutter_application_1/utils/top_notification.dart';
import 'package:flutter_application_1/models/task.dart';

class ReportDetails extends StatefulWidget {
  final String? status;
  const ReportDetails(this.status, {super.key});

  @override
  State<ReportDetails> createState() => _ReportDetailsState();
}

class _ReportDetailsState extends State<ReportDetails> {
  List<String> _selectedPersons = [];
  // 从 TaskController 获取当前任务
  late TaskController _taskController;
  final TaskService _taskService = TaskService();
  Map<String, dynamic>? _timerStatus;
  String? _applicant;
  String _selectedProgress = '';
  List<Map<String, dynamic>> _customReportItems = [];
  String? _expectedCompletionDate;
  final TextEditingController _remarkController = TextEditingController();
  List<int> _mediaIds = [];
  List<int> _attachmentIds = [];
  bool _isMediaUploading = false;
  bool _isAttachmentUploading = false;
  String? _recordId;
  late Task newTask;

  // 语音录制器
  VoiceRecorder _voiceRecorder = VoiceRecorder();
  final GlobalKey<CreateTaskState> _createTaskKey =
      GlobalKey<CreateTaskState>();

  String _formatTimerDuration() {
    final status = _timerStatus;
    if (status == null) return '--';
    final startTime = _roundDateTime(status['startTime'], roundDown: true);
    final endTimeHour = _roundHour(status['endTime'], roundDown: false);
    final accumulatedSeconds = status['accumulatedSeconds'];
    final totalSeconds = accumulatedSeconds is int
        ? accumulatedSeconds
        : int.tryParse(accumulatedSeconds?.toString() ?? '') ?? 0;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    return '$startTime~$endTimeHour (${hours}小时${minutes.toString().padLeft(2, '0')}分)';
  }

  String _roundDateTime(dynamic dateTimeStr, {bool roundDown = true}) {
    if (dateTimeStr == null) return '--';
    try {
      final str = dateTimeStr.toString();
      if (str.length < 16) return str;
      final month = str.substring(5, 7);
      final day = str.substring(8, 10);
      int hour = int.parse(str.substring(11, 13));
      if (!roundDown) {
        hour += 1;
        if (hour >= 24) hour = 23;
      }
      return '$month-$day ${hour.toString().padLeft(2, '0')}:00';
    } catch (_) {
      return '--';
    }
  }

  String _roundHour(dynamic dateTimeStr, {bool roundDown = true}) {
    if (dateTimeStr == null) return '--';
    try {
      final str = dateTimeStr.toString();
      if (str.length < 13) return '--';
      int hour = int.parse(str.substring(11, 13));
      if (!roundDown) {
        hour += 1;
        if (hour >= 24) hour = 23;
      }
      return '${hour.toString().padLeft(2, '0')}:00';
    } catch (_) {
      return '--';
    }
  }

  @override
  void initState() {
    super.initState();
    _taskController = Get.find<TaskController>();
    _loadTimerStatus();
    _loadUserInfo();
  }

  Future<void> _loadTimerStatus() async {
    final status = await _taskService.getTimerStatus();
    if (mounted) {
      setState(() {
        _timerStatus = status;
        _recordId = status?['recordId']?.toString();
      });
    }
  }

  Future<void> _loadUserInfo() async {
    final userInfo = await StorageService.getUserInfo();
    if (mounted) {
      setState(() {
        _applicant =
            '${userInfo?['realName']?.toString() ?? userInfo?['userName']?.toString()}(我)';
      });
    }
  }

  int _normalizedProgressValue() {
    final raw = _selectedProgress.replaceAll('%', '');
    final parsed = double.tryParse(raw) ?? 0;
    return parsed.clamp(0, 100).toInt();
  }

  Future<void> _submit() async {
    final task = _taskController.currentTask.value;
    if (task == null) {
      if (!_createTaskKey.currentState!.validateFields()) return;
      try {
        await _createTaskKey.currentState!.submitTask();
      } catch (_) {
        return;
      }
      _submitWithTask(newTask);
      return;
    }
    _submitWithTask(task);
  }

  Future<void> _submitWithTask(Task task) async {
    final reportMethodMap = {
      '整体汇报': 'slider',
      'SKU汇报': 'sku',
      '自定义汇报': 'style',
    };
    final remark = _remarkController.text.trim();
    final hasRemark = remark.isNotEmpty;
    final hasExpectedDate =
        _expectedCompletionDate != null && _expectedCompletionDate!.isNotEmpty;
    if (hasRemark != hasExpectedDate) {
      TopNotification.show(
        context,
        message: '备注和预计完成时间必须同时填写或同时不填',
        backgroundColor: Colors.orange,
      );
      return;
    }

    if (_selectedProgress.isEmpty) {
      TopNotification.show(
        context,
        message: '请选择汇报进度',
        backgroundColor: Colors.orange,
      );
      return;
    }

    if (_isMediaUploading) {
      TopNotification.show(
        context,
        message: '图片/视频正在上传中，请稍候',
        backgroundColor: Colors.orange,
      );
      return;
    }

    if (_isAttachmentUploading) {
      TopNotification.show(
        context,
        message: '附件正在上传中，请稍候',
        backgroundColor: Colors.orange,
      );
      return;
    }

    final data = <String, dynamic>{
      'taskId': task.id,
      'taskNo': task.taskNo,
      'applyType': 1,
      'remark': remark,
      'reportMethod': reportMethodMap[task.reportMethod] ?? 'slider',
      'progress': _normalizedProgressValue(),
      'startTime': _timerStatus?['startTime'],
      'endTime': _timerStatus?['endTime'],
      'imageList': _mediaIds,
      'attachmentList': _attachmentIds,
      'recordId': _recordId,
      'mayFinishDate': _expectedCompletionDate,
    };
    final reportCode = reportMethodMap[task.reportMethod] ?? 'slider';
    if ((reportCode == 'sku' || reportCode == 'style') &&
        _customReportItems.isEmpty) {
      TopNotification.show(
        context,
        message: '汇报明细不能为空',
        backgroundColor: Colors.orange,
      );
      return;
    }
    if (reportCode == 'sku') {
      data['taskReportSkuDetailDTOList'] = _customReportItems;
    } else if (reportCode == 'style') {
      data['taskReportStyleDetailDTOList'] = _customReportItems;
    }

    const validTaskTypes = {1, 2, 9}; // 项目、订单、打样
    if (validTaskTypes.contains(task.taskType) &&
        task.billNo != null &&
        task.billNo!.isNotEmpty &&
        task.originTaskId != null) {
      final checkResult = await _taskService.checkPreTaskReport(
        billNo: task.billNo!,
        progress: int.tryParse(data['progress'].toString()) ?? 0,
        taskId: task.originTaskId!,
      );
      if (!mounted) return;
      if (checkResult.checkStatus != 'pass') {
        ProgressExceedDialog.show(
          context,
          processes: checkResult.preTaskDetails
              .map(
                (d) => ProcessProgress(name: d.taskName, progress: d.progress),
              )
              .toList(),
          onConfirm: () async {
            try {
              final msg = await _taskService.savePendingReport(data);
              if (!mounted) return;
              final nav = Navigator.of(context);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('暂存提交'),
                  content: Text(msg),
                  titleTextStyle: TextStyle(fontSize: 20, color: Colors.black),
                  actions: [
                    TextButton(
                      onPressed: () {
                        nav.pop(); // 关闭弹窗
                        nav.pop(); // 关闭汇报页面
                      },
                      child: Text('确定'),
                    ),
                  ],
                ),
              );
            } catch (_) {}
          },
        );
        return;
      }
    }

    final progress = await _taskService.submitReport(data);
    if (!mounted) return;
    // _taskController.updateTaskProgress(task.id, progress ?? 0);
    if (progress == 100) {
      _taskController.currentTask.value = null;
    }
    Navigator.pop(context);
    final rootNav = Navigator.of(context, rootNavigator: true);
    showDialog(
      context: context,
      builder: (context) => DialogCustom(
        title: '提交成功！',
        description: '您可以在首页-汇报统计，查看历史提交',
        iconColor: Color(0xFF04C15F),
        onRightButtonPressed: () {
          rootNav.push(
            MaterialPageRoute(builder: (_) => IndividualStatistics()),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _voiceRecorder.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(
          widget.status == 'dynamic' ? '任务汇报' : '汇报详情',
          style: TextStyle(fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Obx(
        () => GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Container(
            color: Colors.grey[50],
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                children: [
                  // 任务信息部分
                  (_taskController.currentTask.value == null)
                      ? CreateTask(
                          wherePage: 'report',
                          key: _createTaskKey,
                          onTaskCreated: (result) {
                            final taskId = result is int
                                ? result
                                : int.tryParse('$result') ?? 0;
                            if (taskId > 0) {
                              newTask = Task(
                                id: taskId,
                                taskNo:
                                    _createTaskKey.currentState?.taskNo ?? '',
                                taskType: 3,
                                taskTypeDesc: '',
                                companyName: '',
                                companyId: '',
                                taskName: '',
                                principalsList: [],
                                collaboratorsList: [],
                                ccPersonsList: [],
                                contactPhonesList: [],
                                contactAddressesList: [],
                                status: '',
                                statusDesc: '',
                                progress: 0,
                                reportMethod: '整体汇报',
                              );
                            }
                          },
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          margin: const EdgeInsets.symmetric(vertical: 12.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 任务标题
                              widget.status == 'static'
                                  ? buildTaskItem(
                                      '任务标题',
                                      _taskController
                                              .currentTask
                                              .value
                                              ?.taskName ??
                                          '',
                                    )
                                  : Container(
                                      padding: const EdgeInsets.only(top: 12.0),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            // ignore: deprecated_member_use
                                            color: Colors.grey.withOpacity(0.2),
                                            width: 0.5,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            children: [
                                              Row(
                                                children: [
                                                  // 左侧图标
                                                  Icon(
                                                    Icons.assignment,
                                                    color: Colors.grey,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  // 标签（带红色星号）
                                                  RichText(
                                                    text: TextSpan(
                                                      style: const TextStyle(
                                                        color: Color(
                                                          0xFF010101,
                                                        ),
                                                      ),
                                                      children: [
                                                        TextSpan(text: '任务标题'),
                                                        TextSpan(
                                                          text: '*',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              // 蓝色选择按钮
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.blue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  minimumSize: const Size(
                                                    0,
                                                    28,
                                                  ),
                                                ),
                                                onPressed: () => {
                                                  showModalBottomSheet(
                                                    context: context,
                                                    isScrollControlled: true,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    builder: (cotext) {
                                                      return SelectTaskBottom(
                                                        onTaskSelected: (int index) {
                                                          // 设置当前任务
                                                          _taskController
                                                              .setCurrentTask(
                                                                _taskController
                                                                    .allTasks[index],
                                                              );
                                                        },
                                                      );
                                                    },
                                                  ),
                                                },
                                                child: const Text(
                                                  '选择',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              // 任务标题文本
                                              Text(
                                                _taskController
                                                        .currentTask
                                                        .value
                                                        ?.taskName ??
                                                    '',
                                                style: TextStyle(
                                                  color: Color(0xFF444444),
                                                ),
                                              ),
                                              // 右侧关闭按钮
                                              IconButton(
                                                onPressed: () => {
                                                  _taskController
                                                      .clearCurrentTask(),
                                                  setState(() {}),
                                                },
                                                icon: Icon(
                                                  Icons.close,
                                                  size: 16,
                                                  color: Colors.grey,
                                                ),
                                                style: ButtonStyle(
                                                  padding:
                                                      WidgetStateProperty.all(
                                                        const EdgeInsets.all(0),
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                              // 单据编号
                              buildTaskItem(
                                '单据编号',
                                _taskController.currentTask.value?.taskNo ?? '',
                              ),
                              // 任务类型
                              buildTaskItem(
                                '任务类型',
                                _taskController
                                        .currentTask
                                        .value
                                        ?.taskTypeDesc ??
                                    '',
                              ),
                              buildTaskItem(
                                '当前进度',
                                _taskController.currentTask.value != null
                                    ? '${_taskController.currentTask.value!.progress.toString()}%'
                                    : '',
                                isStatus: true,
                              ),
                              // 关联订单
                              if (_taskController
                                      .currentTask
                                      .value
                                      ?.relatedProjectOrder
                                      ?.isNotEmpty ==
                                  true)
                                buildTaskItem(
                                  '关联订单',
                                  _taskController
                                      .currentTask
                                      .value!
                                      .relatedProjectOrder!,
                                  isOrder: true,
                                ),
                              // 任务详情按钮
                              Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFEEEEEE),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    minimumSize: const Size(0, 32),
                                  ),
                                  onPressed: () => showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (cotext) {
                                      final task =
                                          _taskController.currentTask.value;
                                      return TaskLookBottom(
                                        taskId: task?.id ?? 0,
                                        task: task,
                                        isHasDetail: !const ['项目', '订单', '打样']
                                            .any(
                                              (t) =>
                                                  task?.taskTypeDesc.startsWith(
                                                    t,
                                                  ) ==
                                                  true,
                                            ),
                                      );
                                    },
                                  ),
                                  child: const Text(
                                    '任务详情',
                                    style: TextStyle(
                                      color: Color(0xFF333333),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                  // 汇报信息部分
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 12.0,
                    ),
                    margin: const EdgeInsets.only(bottom: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 持续时间
                        buildTaskItem('持续时间', _formatTimerDuration()),
                        // 汇报进度
                        // buildTaskItem('汇报进度', '100% → 100%', isOrder: true),
                        ReportProgress(
                          key: ValueKey(
                            _taskController.currentTask.value?.id ?? 0,
                          ),
                          reportMethod:
                              _taskController.currentTask.value?.reportMethod ??
                              '整体汇报',
                          onProgressChanged: (v) => _selectedProgress = v,
                          onCustomDataChanged: (v) => _customReportItems = v,
                          taskNo: _taskController.currentTask.value?.taskNo,
                          task: _taskController.currentTask.value,
                        ),
                        // 汇报人
                        buildTaskItem(
                          '汇报人',
                          _applicant ?? '',
                          // onTap: () => showModalBottomSheet(
                          //   context: context,
                          //   isScrollControlled: true,
                          //   backgroundColor: Colors.transparent,
                          //   builder: (cotext) {
                          //     return SelectPrincipal(
                          //       '汇报人',
                          //       onConfirm: (selectedPersons) {
                          //         setState(() {
                          //           _selectedPersons = selectedPersons;
                          //         });
                          //       },
                          //     );
                          //   },
                          // ),
                        ),
                        // 汇报人标签
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ..._selectedPersons.map(
                              (person) => buildUserTag(person),
                            ),
                          ],
                        ),
                        Container(
                          // ignore: deprecated_member_use
                          color: Colors.grey.withOpacity(0.2),
                          height: 0.5,
                          margin: _selectedPersons.isNotEmpty
                              ? const EdgeInsets.only(top: 8)
                              : EdgeInsets.zero,
                        ),
                        ReportRemarkSection(
                          controller: _remarkController,
                          readOnly: widget.status == 'static',
                          maxLines: null,
                          minLines: 2,
                        ),
                        if (widget.status != 'static')
                          ReportExpectedCompletionSection(
                            onChanged: (v) => _expectedCompletionDate = v,
                          ),
                      ],
                    ),
                  ),

                  // 图片/视频 & 附件
                  if (widget.status != 'static')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      margin: const EdgeInsets.only(bottom: 12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          ReportMediaSection(
                            onMediaChanged: (ids) => _mediaIds = ids,
                            onUploadingChanged: (v) => _isMediaUploading = v,
                          ),
                          ReportAttachmentSection(
                            onAttachmentChanged: (ids) => _attachmentIds = ids,
                            onUploadingChanged: (v) =>
                                _isAttachmentUploading = v,
                          ),
                        ],
                      ),
                    ),

                  // 底部信息部分
                  ?widget.status == 'static'
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          margin: const EdgeInsets.only(bottom: 12.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 汇报类型
                              buildTaskItem('汇报类型', '正常', isStatus: true),
                              // 提交人
                              buildTaskItem('提交人', '陈圆圆'),
                              // 汇报时间
                              buildTaskItem('汇报时间', '11-02 06: 00: 31'),
                            ],
                          ),
                        )
                      : null,
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: widget.status == 'dynamic'
          ? Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(width: 20, height: 20),
                  // GestureDetector(
                  //   onTap: () {
                  //     showModalBottomSheet(
                  //       context: context,
                  //       isScrollControlled: true,
                  //       builder: (context) => SelectPrincipalMore('汇报多人'),
                  //     );
                  //   },
                  //   child: SizedBox(
                  //     width: 50,
                  //     height: 40,
                  //     child: Column(
                  //       children: [
                  //         Icon(Icons.group, size: 16, color: Color(0xFF477DF3)),
                  //         Text(
                  //           '汇报多人',
                  //           style: TextStyle(
                  //             fontSize: 12,
                  //             color: Color(0xFF080808),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text(
                          '取消',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF080808),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0073FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text(
                          '确定提交',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : null,
    );
  }

  // 通用任务项构建方法
  Widget buildTaskItem(
    String label,
    String value, {
    bool isOrder = false,
    bool isStatus = false,
    void Function()? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          border: value.isEmpty
              ? null
              : Border(
                  bottom: BorderSide(
                    // ignore: deprecated_member_use
                    color: Colors.grey.withOpacity(0.2),
                    width: 0.5,
                  ),
                ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(_getIconForLabel(label), color: Colors.grey, size: 16),
            const SizedBox(width: 8),
            // 左侧标签
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Color(0xFF010101)),
                children: [
                  TextSpan(text: label),
                  if (label == '汇报进度')
                    TextSpan(
                      text: '  整体',
                      style: TextStyle(color: Color(0xFF1BA17D), fontSize: 12),
                    ),
                ],
              ),
            ),
            // 右侧值
            label == '备注'
                ? Expanded(child: Text(''))
                // 语音消息按钮
                // ? Expanded(
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.end,
                //       children: [
                //         //语音按钮
                //         GestureDetector(
                //           onTap: () {
                //             // 语音消息功能
                //             _showVoiceRecorder(context);
                //           },
                //           child: Container(
                //             padding: EdgeInsets.symmetric(
                //               horizontal: 12,
                //               vertical: 6,
                //             ),
                //             decoration: BoxDecoration(
                //               color: Color(0xFFE6F2FF),
                //               borderRadius: BorderRadius.circular(4),
                //             ),
                //             child: Row(
                //               children: [
                //                 Icon(
                //                   Icons.mic,
                //                   size: 16,
                //                   color: Color(0xFF0073FF),
                //                 ),
                //                 SizedBox(width: 4),
                //                 Text('语首消息', style: TextStyle(fontSize: 14)),
                //               ],
                //             ),
                //           ),
                //         ),
                //       ],
                //     ),
                //   )
                : Expanded(
                    child: Text(
                      value,
                      style: TextStyle(
                        color: isOrder
                            ? Colors.blue
                            : isStatus
                            ? Colors.green
                            : Color(0xFF444444),
                        fontWeight: isOrder
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
            if (label == '汇报进度' && widget.status == 'dynamic')
              Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  // 根据标签获取对应图标
  IconData _getIconForLabel(String label) {
    switch (label) {
      case '任务标题':
        return Icons.assignment;
      case '单据编号':
        return Icons.receipt;
      case '任务类型':
        return Icons.category;
      case '当前进度':
        return Icons.percent;
      case '关联订单':
        return Icons.shopping_cart;
      case '持续时间':
        return Icons.access_time;
      case '汇报进度':
        return Icons.timeline;
      case '汇报人':
        return Icons.person;
      case '备注':
        return Icons.notes;
      case '图片/视频':
        return Icons.image;
      case '附件':
        return Icons.attach_file;
      case '汇报类型':
        return Icons.type_specimen;
      case '提交人':
        return Icons.person;
      case '汇报时间':
        return Icons.access_time;
      default:
        return Icons.info;
    }
  }

  // 用户标签构建方法
  Widget buildUserTag(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Color(0xFFE9F0FD),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        name,
        style: const TextStyle(color: Color(0xFF010101), fontSize: 12),
      ),
    );
  }

  // 显示语音录制界面
  void _showVoiceRecorder(BuildContext context) {
    _voiceRecorder.showVoiceRecorder(context);
  }
}
